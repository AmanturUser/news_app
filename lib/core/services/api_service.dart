import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:test_work/core/const/const.dart';

class ApiService {

  Uri _getUri(String endpoint) {
    return Uri.parse('${ApiUrl.baseUrl}$endpoint');
  }

  String _accessToken() {
    return '';
  }

  Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      "token": _accessToken(),
    };
  }

  Future<http.Response> _sendRequest(
      Future<http.Response> Function() requestFunc, Uri uri,
      {dynamic body}) async {
    try {
      _logRequest(uri, body);
      final response = await requestFunc();
      _logResponse(uri, response);
      if (_isUnauthorized(response.statusCode)) {
        _handleUnauthorizedAccess();
      }
      final fixedResponse = _fixResponseEncoding(response);
      return fixedResponse;
    } catch (e) {
      log("Error during API call to $uri: $e");
      rethrow;
    }
  }

  http.Response _fixResponseEncoding(http.Response response) {
    try {
      if (response.body.isEmpty) return response;

      if (_containsEncodingIssues(response.body)) {
        final fixedBody = _fixEncoding(response.body);

        return http.Response(
          fixedBody,
          response.statusCode,
          headers: response.headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase,
          request: response.request,
        );
      }

      return response;
    } catch (e) {
      log("Error fixing encoding: $e");
      return response;
    }
  }

  bool _containsEncodingIssues(String text) {
    return text.contains('Ð') || text.contains('Ñ') || text.contains('Â');
  }

  String _fixEncoding(String text) {
    try {
      List<int> latin1Bytes = latin1.encode(text);
      return utf8.decode(latin1Bytes, allowMalformed: true);
    } catch (e) {
      log("Error fixing encoding for text: $e");
      return text;
    }
  }

  dynamic _fixJsonEncoding(dynamic json) {
    if (json is String) {
      return _fixEncoding(json);
    } else if (json is Map) {
      Map<String, dynamic> result = {};
      json.forEach((key, value) {
        if (key is String) {
          key = _fixEncoding(key);
        }
        result[key] = _fixJsonEncoding(value);
      });
      return result;
    } else if (json is List) {
      return json.map((item) => _fixJsonEncoding(item)).toList();
    }
    return json;
  }

  void _logRequest(Uri uri, dynamic body) {
    log("Request URL: $uri");
    if (body != null) log("Request Body: ${jsonEncode(body)}");
  }

  void _logResponse(Uri uri, http.Response response) {
    log("Response for URL: $uri");
    log("Status Code: ${response.statusCode}");
    log("Response Body: ${response.body}");
  }

  bool _isUnauthorized(int statusCode) {
    return statusCode == 401 || statusCode == 403;
  }

  void _handleUnauthorizedAccess() {
    log("Unauthorized access detected.");
  }

  dynamic parseJson(String jsonString) {
    try {
      final parsed = jsonDecode(jsonString);
      return _fixJsonEncoding(parsed);
    } catch (e) {
      log("Error parsing JSON: $e");
      try {
        final fixedString = _fixEncoding(jsonString);
        return jsonDecode(fixedString);
      } catch (e) {
        log("Error parsing JSON after encoding fix: $e");
        rethrow;
      }
    }
  }

  Future<http.Response> get(String endpoint) async {
    Uri uri = _getUri(endpoint);
    return _sendRequest(() => http.get(uri, headers: _headers()), uri);
  }

  Future<http.Response> post(String endpoint, dynamic body) async {
    Uri uri = _getUri(endpoint);
    return _sendRequest(
            () => http.post(uri, headers: _headers(), body: jsonEncode(body)), uri,
        body: body);
  }

  Future<http.Response> put(String endpoint, dynamic body) async {
    Uri uri = _getUri(endpoint);
    return _sendRequest(
            () => http.put(uri, headers: _headers(), body: jsonEncode(body)), uri,
        body: body);
  }

  Future<http.Response> patch(String endpoint, dynamic body) async {
    Uri uri = _getUri(endpoint);
    return _sendRequest(
            () => http.patch(uri, headers: _headers(), body: jsonEncode(body)), uri,
        body: body);
  }

  Future<http.Response> delete(String endpoint, {dynamic body}) async {
    Uri uri = _getUri(endpoint);
    return _sendRequest(
            () => http.delete(uri, headers: _headers(), body: body != null ? jsonEncode(body) : null),
        uri,
        body: body);
  }

  Future<Map<String, dynamic>> getJsonData(String endpoint) async {
    final response = await get(endpoint);
    if (response.statusCode == 200) {
      return parseJson(response.body);
    } else {
      throw Exception('Failed to load data from $endpoint: ${response.statusCode}');
    }
  }
}