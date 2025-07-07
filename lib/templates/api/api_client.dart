/// Generates the boilerplate rewuest file for the provider state management strategy.
///
/// A class representing a base [HTTP] request for the application.
/// It supports [GET], [POST], [PUT], [DELETE], [PATCH] requests with optional
/// authentication tokens and multipart form-data handling.
///
/// This class uses the `[http]` package to perform network operations.
/// The request can optionally include files (via `[PlatformFile]` or `[File]`).
///
/// The data payload for the request. For [GET], treated as query params.
/// For [POST]/[PUT]/[DELETE], treated as form fields or multipart fields.
///  Factory method to create an instance of [ApplicationBaseRequest],
/// initializing the `[getUri]` function based on environment.
///
String requestProvider(String name) => '''

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:$name/core/network/response_handler.dart';

class ApplicationBaseRequest {
  final String baseUrl;

  final String endpoint;

  final String method;

  final Map<String, dynamic>? data;

  /// Optional Bearer token for Authorization header.
  final String? token;

  /// Function to build a Uri from baseUrl, endpoint, and optional params.
  final Uri Function(String, String, [Map<String, dynamic>?]) getUri;

  /// Private constructor used by factory constructors.
  ApplicationBaseRequest._({
    required this.baseUrl,
    required this.endpoint,
    required this.method,
    this.data,
    this.token,
    required this.getUri,
  });

  factory ApplicationBaseRequest.bootstrap({
    required String baseUrl,
    required String endpoint,
    required String method,
    Map<String, dynamic>? data,
    String? token,
  }) {
    // Function to create a Uri for HTTPS requests with optional query parameters.
    Uri getUri(String baseUrl, String endpoint, [Map<String, dynamic>? params]) {
      // In non-release mode, could modify Uri building for testing/debugging.
      if (!kReleaseMode) {
        // Example: Could use Uri.http(...) for local dev, commented out here.
      }
      return Uri.https(baseUrl, endpoint, params);
    }

    return ApplicationBaseRequest._(
      baseUrl: baseUrl,
      endpoint: endpoint,
      method: method,
      data: data,
      token: token,
      getUri: getUri,
    );
  }

  /// Factory for creating a GET request.
  /// [params] are query parameters.
  /// [token] is optional auth token.
  factory ApplicationBaseRequest.get(
    String baseUrl,
    String endpoint, {
    Map<String, dynamic>? params,
    String token = "",
  }) =>
      ApplicationBaseRequest.bootstrap(
        baseUrl: baseUrl,
        endpoint: endpoint,
        method: 'get',
        data: params,
        token: token,
      );

  /// Factory for creating a DELETE request.
  /// [params] are optional parameters sent as form fields.
  /// [token] is optional auth token.
  factory ApplicationBaseRequest.delete(
    String baseUrl,
    String endpoint, {
    Map<String, dynamic>? params,
    String token = "",
  }) =>
      ApplicationBaseRequest.bootstrap(
        baseUrl: baseUrl,
        endpoint: endpoint,
        method: 'delete',
        data: params,
        token: token,
      );

  /// Factory for creating a POST request.
  /// [payload] is the data sent in the request body.
  /// [token] is optional auth token.
  factory ApplicationBaseRequest.post(
    String baseUrl,
    String endpoint,
    Map<String, dynamic> payload, {
    String token = "",
  }) =>
      ApplicationBaseRequest.bootstrap(
        baseUrl: baseUrl,
        endpoint: endpoint,
        method: 'post',
        data: payload,
        token: token,
      );

  /// Factory for creating a PATCH request.
  /// Note: This actually uses HTTP PUT with _method override.
  /// [payload] is the data sent in the request body.
  /// [token] is optional auth token.
  factory ApplicationBaseRequest.patch(
    String baseUrl,
    String endpoint,
    Map<String, dynamic> payload, {
    String token = "",
  }) =>
      ApplicationBaseRequest.bootstrap(
        baseUrl: baseUrl,
        endpoint: endpoint,
        method: "put",
        data: payload,
        token: token,
      );

  /// Executes the HTTP request asynchronously and returns a [Response].
  ///
  /// Handles different HTTP methods and supports multipart/form-data uploads.
  /// Errors during the request or response parsing are caught and handled gracefully.
  Future<Response> request() async {
    late http.Response response;

    try {
      if (method.toLowerCase() == "get") {
        // Convert data to Map<String, String> for query parameters.
        final Map<String, String?> params = data != null
            ? data!.map((key, value) => MapEntry(key, value?.toString()))
            : {};
        final Uri requestUrl = getUri(baseUrl, endpoint, params);

        // Debug: Print the GET request URL.
        print("GET Request URL: \$requestUrl");

        // Perform HTTP GET with headers.
        response = await http.get(requestUrl, headers: _getHeaders());
      }

      if (method.toLowerCase() == "delete") {
        final Uri requestUrl = getUri(baseUrl, endpoint);

        // Debug: Print the DELETE request URL.
        print("DELETE Request URL: \$requestUrl");

        var req = http.MultipartRequest(method.toUpperCase(), requestUrl);

        // Add fields or files to the multipart request.
        data!.forEach((key, value) async {
          if (value is String) {
            req.fields[key] = value;
          }
          if (value is double || value is int) {
            req.fields[key] = value.toString();
          }
          if (value is PlatformFile) {
            req.files.add(
              http.MultipartFile.fromBytes(key, value.bytes!.toList()),
            );
          }
        });

        req.headers.addAll(_getHeaders());

        // Send request and wait for response stream.
        response = await http.Response.fromStream(await req.send());
      }

      if (method.toLowerCase() == "post") {
        final Uri requestUrl = getUri(baseUrl, endpoint);

        // Debug: Print the POST request URL.
        print("POST Request URL: \$requestUrl");

        var req = http.MultipartRequest(method.toUpperCase(), requestUrl);

        // Add fields and files to multipart request.
        data!.forEach((key, value) async {
          if (value is String) {
            req.fields[key] = value;
          }
          if (value is DateTime) {
            req.fields[key] = value.toString();
          }
          if (value is double || value is int) {
            req.fields[key] = value.toString();
          }
          if (value is List) {
            // Serialize list elements with indexed keys.
            int i = 0;
            for (dynamic v in value) {
              req.fields["\$key[\$i]"] = v.toString();
              i++;
            }
          }
          if (value is Map) {
            // Serialize map entries with keys.
            for (dynamic v in value.keys) {
              req.fields["\$key[\$v]"] = value[v].toString();
            }
          }
          if (value is PlatformFile) {
            // Add file from path.
            req.files.add(await http.MultipartFile.fromPath(key, value.path!));
          }
          if (value is File) {
            // Add file from path.
            req.files.add(await http.MultipartFile.fromPath(key, value.path));
          }
        });

        req.headers.addAll(_getHeaders());

        // Send request and await response.
        response = await http.Response.fromStream(await req.send());
      }

      if (method.toLowerCase() == "put") {
        final Uri requestUrl = getUri(baseUrl, endpoint);

        // Debug: Print the PUT request URL.
        print("PUT Request URL: \$requestUrl");

        var req = http.MultipartRequest(method.toUpperCase(), requestUrl);

        // Add _method override for PUT (if needed by backend).
        req.fields['_method'] = "PUT";

        // Add fields to request.
        data!.forEach((key, value) async {
          if (value is String) {
            req.fields[key] = value;
          }
          if (value is double || value is int) {
            req.fields[key] = value.toString();
          }
        });

        req.headers.addAll(_getHeaders());

        // Send request and await response.
        response = await http.Response.fromStream(await req.send());
      }
    } catch (e) {
      // If any error occurs, return a 404 response with unknown error message.
      response = http.Response("{\\\"message\\\":\\\"Unknown Error\\\"}", 404);

    }

    Map<String, dynamic> apiResponse = {};

    try {
      // Try decoding JSON response on successful or expected error codes.
      if (response.statusCode ~/ 100 == 2) {
        apiResponse = jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        apiResponse = jsonDecode(response.body);
      } else if (response.statusCode == 502) {
        apiResponse =jsonDecode("{\\\"message\\\":\\\"Process Failed\\\"}");
;
      } else {
        // For other status codes, return a Response with raw data.
        return Response(
          status: response.statusCode,
          data: jsonDecode(response.body) as Map<String, dynamic>,
          message: response.reasonPhrase,
          body: response.body,
        );
      }
    } catch (e) {
      // Handle JSON decoding errors.
      apiResponse = {"error": "Decoding Error", "response": response.body};
      return Response(
        status: response.statusCode,
        data: apiResponse,
        message: response.reasonPhrase,
        body: response.body,
      );
    }

    // Return the parsed response wrapped in Response class.
    return Response(
      status: response.statusCode,
      data: apiResponse,
      message: response.reasonPhrase,
      body: response.body,
    );
  }

  /// Helper method to generate the headers for the HTTP request.
  ///
  /// Sets CORS, content type, accept, and authorization headers.
  Map<String, String> _getHeaders() {
    return <String, String>{
      'access-control-allow-origin': '*',
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': '*/*',
      'Authorization': 'Bearer \$token',
    };
  }
}

''';
