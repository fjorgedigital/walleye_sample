import 'dart:io';

import 'package:http/http.dart' as http;

class Api {
  //base URL from the env vars
  static const String baseUrl = String.fromEnvironment('STRAPI_BASE_URL');

  //default headers
  static Map<String, String> defaultHeader = {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
  };

  //get method
  static Future<http.Response> get(url, body, [headers]) {
    if (headers != null) {
      headers.addEntries(defaultHeader.entries);
    } else {
      headers = defaultHeader;
    }
    return http.get(
      Uri.parse('$baseUrl$url'),
      headers: headers,
    );
  }

  //put method
  static Future<http.Response> put(url, body, [headers]) {
    if (headers != null) {
      headers.addEntries(defaultHeader.entries);
    } else {
      headers = defaultHeader;
    }
    return http.put(Uri.parse('$baseUrl$url'), headers: headers, body: body);
  }

  //post method
  static Future<http.Response> post(url, body, [headers]) {
    if (headers != null) {
      headers.addEntries(defaultHeader.entries);
    } else {
      headers = defaultHeader;
    }
    return http.post(Uri.parse('$baseUrl$url'), headers: headers, body: body);
  }

  //delete method
  static Future<http.Response> delete(url, [headers]) {
    if (headers != null) {
      headers.addEntries(defaultHeader.entries);
    } else {
      headers = defaultHeader;
    }
    return http.delete(Uri.parse('$baseUrl$url'), headers: headers);
  }
}
