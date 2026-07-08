import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'api_client.dart';

/// Socket mínimo para poder fakear dart:io WebSocket en tests.
abstract class WsSocket {
  Stream<dynamic> get stream;
  void send(String data);
  Future<void> close();
}

class _IoSocket implements WsSocket {
  final WebSocket _ws;
  _IoSocket(this._ws);
  @override
  Stream<dynamic> get stream => _ws;
  @override
  void send(String data) => _ws.add(data);
  @override
  Future<void> close() => _ws.close();
}

typedef WsConnect = Future<WsSocket> Function(String url, String jwt);

Future<WsSocket> _ioConnect(String url, String jwt) async =>
    _IoSocket(await WebSocket.connect(url, protocols: ['bearer', jwt]));

class WsEvent {
  final String op;
  final Map<String, dynamic> d;
  const WsEvent(this.op, this.d);
}

/// Protocolo v1: {v,op,seq,d} ↔ sys.ack/sys.error por seq + eventos push.
class WsClient {
  final String baseUrl;
  final String Function() jwt; // access vigente al (re)conectar
  final WsConnect _connect;
  final Duration reconnectDelay;
  final _events = StreamController<WsEvent>.broadcast();
  final _pending = <int, Completer<Map<String, dynamic>>>{};
  WsSocket? _socket;
  int _seq = 0;
  bool _closed = false;

  WsClient(this.baseUrl, this.jwt,
      {WsConnect? connect, this.reconnectDelay = const Duration(seconds: 3)})
      : _connect = connect ?? _ioConnect;

  Stream<WsEvent> get events => _events.stream;
  bool get connected => _socket != null;

  Future<void> connect() async {
    if (_closed || _socket != null) return;
    _socket = await _connect('$baseUrl/ws', jwt());
    _socket!.stream.listen(_onFrame, onDone: _onDone, onError: (_) => _onDone());
    _events.add(const WsEvent('sys.open', {}));
  }

  void _onFrame(dynamic raw) {
    final f = jsonDecode(raw as String) as Map<String, dynamic>;
    final d = ((f['d'] as Map?) ?? const {}).cast<String, dynamic>();
    final op = f['op'] as String;
    if (op == 'sys.ack' || op == 'sys.error') {
      final c = _pending.remove(d['seq']);
      if (c == null) return;
      if (op == 'sys.ack') {
        c.complete(d);
      } else {
        c.completeError(ApiException(
            0, (d['code'] as String?) ?? 'WS', (d['message'] as String?) ?? ''));
      }
      return;
    }
    _events.add(WsEvent(op, d));
  }

  void _onDone() {
    if (_socket == null) return;
    _socket = null;
    for (final c in _pending.values) {
      c.completeError(ApiException(0, 'WS', 'connection lost'));
    }
    _pending.clear();
    if (_closed) return;
    // ponytail: reconexión fija; backoff exponencial si algún día hace falta
    Timer(reconnectDelay, () => connect().catchError((_) => _onDone()));
  }

  Future<Map<String, dynamic>> request(String op, Map<String, dynamic> d) {
    final socket = _socket;
    if (socket == null) return Future.error(ApiException(0, 'WS', 'not connected'));
    final seq = ++_seq;
    final completer = Completer<Map<String, dynamic>>();
    _pending[seq] = completer;
    socket.send(jsonEncode({'v': 1, 'op': op, 'seq': seq, 'd': d}));
    return completer.future;
  }

  Future<void> close() async {
    _closed = true;
    final s = _socket;
    _socket = null;
    await s?.close();
  }
}
