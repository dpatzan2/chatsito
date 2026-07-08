import 'dart:convert';
import 'dart:io';

/// URL del backend. Emulador Android: --dart-define=API_URL=http://10.0.2.2:3000
const defaultApiBase = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');

class ApiException implements Exception {
  final int status;
  final String code, message;
  ApiException(this.status, this.code, this.message);
  @override
  String toString() => 'ApiException($status $code: $message)';
}

typedef HttpCall = Future<(int, String)> Function(
    String method, Uri url, Map<String, String> headers, String? body);

Future<(int, String)> _ioHttp(
    String method, Uri url, Map<String, String> headers, String? body) async {
  final client = HttpClient();
  try {
    final req = await client.openUrl(method, url);
    headers.forEach(req.headers.set);
    if (body != null) req.write(body);
    final res = await req.close();
    return (res.statusCode, await res.transform(utf8.decoder).join());
  } finally {
    client.close();
  }
}

/// Cliente JSON con tokens. Reintenta una vez tras refrescar si el access caducó.
/// ponytail: tokens solo en memoria — persistir (shared_preferences) si molesta re-loguear.
class ApiClient {
  final String baseUrl;
  final HttpCall _http;
  String? access, refresh;

  ApiClient(this.baseUrl, {HttpCall? http}) : _http = http ?? _ioHttp;

  bool get loggedIn => access != null;

  Future<dynamic> send(String method, String path,
      {Object? body, Map<String, String>? query}) async {
    var (status, text) = await _raw(method, path, body, query);
    if (status == 401 && refresh != null && path != '/auth/refresh') {
      await _refresh();
      (status, text) = await _raw(method, path, body, query);
    }
    final json = text.isEmpty ? null : jsonDecode(text);
    if (status >= 400) {
      final err = (json is Map ? json['error'] : null) as Map?;
      throw ApiException(status, (err?['code'] as String?) ?? 'INTERNAL',
          (err?['message'] as String?) ?? text);
    }
    return json;
  }

  Future<(int, String)> _raw(
      String method, String path, Object? body, Map<String, String>? query) {
    var url = Uri.parse('$baseUrl$path');
    if (query != null) url = url.replace(queryParameters: query);
    return _http(method, url, {
      if (body != null) 'content-type': 'application/json',
      if (access != null) 'authorization': 'Bearer $access',
    }, body == null ? null : jsonEncode(body));
  }

  Future<void> _refresh() async {
    final (status, text) = await _raw('POST', '/auth/refresh', {'refresh': refresh}, null);
    if (status >= 400) {
      access = null;
      refresh = null;
      return;
    }
    final json = jsonDecode(text) as Map<String, dynamic>;
    access = json['access'] as String;
    refresh = json['refresh'] as String;
  }
}
