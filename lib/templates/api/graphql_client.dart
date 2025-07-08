String graphqlClientRequest(String name) => '''

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:$name/lib/core/network/response_handler.dart';

class GraphQLClient {
  final String baseUrl;
  final String endpoint;
  final String? token;

  GraphQLClient({
    required this.baseUrl,
    this.endpoint = '/graphql',
    this.token,
  });

  Uri get _uri => Uri.parse('\$baseUrl\$endpoint');

  Map<String, String> get _headers {
    final h = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token!.isNotEmpty) {
      h['Authorization'] = 'Bearer \$token';
    }
    return h;
  }

  Future<Response> query(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    return _send(query: query, variables: variables);
  }

  Future<Response> mutate(
    String mutation, {
    Map<String, dynamic>? variables,
    Map<String, File>? files, // for uploads, uses multipart
  }) async {
    return _send(query: mutation, variables: variables, files: files);
  }

  Future<Response> _send({
    required String query,
    Map<String, dynamic>? variables,
    Map<String, File>? files,
  }) async {
    try {
      if (files != null && files.isNotEmpty) {
        final req = http.MultipartRequest('POST', _uri);
        req.headers.addAll(_headers);

        final operations = jsonEncode({
          'query': query,
          'variables': variables ?? {},
        });
        req.fields['operations'] = operations;

        final map = <String, dynamic>{};
        int i = 0;
        files.forEach((key, file) {
          map['\$i'] = ['variables.\$key'];
          req.files.add(http.MultipartFile(
            '\$i',
            file.openRead(),
            file.lengthSync(),
            filename: file.path.split('/').last,
          ));
          i++;
        });
        req.fields['map'] = jsonEncode(map);

        final streamed = await req.send();
        final resp = await http.Response.fromStream(streamed);
        return _handleResponse(resp);
      } else {
        final body = jsonEncode({
          'query': query,
          if (variables != null) 'variables': variables,
        });

        final resp = await http.post(_uri, headers: _headers, body: body);
        return _handleResponse(resp);
      }
    } catch (e) {
      return Response(
        status: 500,
        data: {'error': 'Network error', 'detail': e.toString()},
        message: 'Network error',
        body: '',
      );
    }
  }

  Response _handleResponse(http.Response resp) {
    final status = resp.statusCode;
    late Map<String, dynamic> jsonBody;

    try {
      jsonBody = jsonDecode(resp.body);
    } catch (_) {
      return Response(
        status: status,
        data: {'error': 'Invalid JSON', 'body': resp.body},
        message: resp.reasonPhrase,
        body: resp.body,
      );
    }

    if (status ~/ 100 == 2) {
      if (jsonBody.containsKey('errors')) {
        return Response(
          status: status,
          data: {
            'errors': jsonBody['errors'],
            'data': jsonBody['data'],
          },
          message: 'GraphQL errors',
          body: resp.body,
        );
      }
      return Response(
        status: status,
        data: jsonBody['data'] ?? {},
        message: resp.reasonPhrase,
        body: resp.body,
      );
    }

    return Response(
      status: status,
      data: {'error': 'HTTP \${resp.statusCode}', 'body': jsonBody},
      message: resp.reasonPhrase,
      body: resp.body,
    );
  }
}

''';
