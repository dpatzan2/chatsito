import 'dart:convert';
import 'package:chatsito/data/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildMultipart arma el cuerpo con headers y bytes', () {
    final body = buildMultipart('B', 'a.png', 'image/png', utf8.encode('XY'));
    final s = utf8.decode(body, allowMalformed: true);
    expect(s, contains('--B\r\n'));
    expect(s, contains('filename="a.png"'));
    expect(s, contains('Content-Type: image/png'));
    expect(s, contains('XY'));
    expect(s, endsWith('--B--\r\n'));
  });
}
