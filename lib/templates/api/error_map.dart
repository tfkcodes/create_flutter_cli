/// Returns a stub for the `ErrorMap` class definition.
/// A class representing error information received from API responses.
///
/// This is useful for capturing structured error data including
/// [status] codes, [messages], response [body], and any field-level [errors].
/// Factory constructor for returning an empty [ErrorMap] instance.
///
/// Useful as a fallback when no error data is available.
String errorMapperStub() => '''


class ErrorMap {
  int? status;
  String? message;
  String? body;
  Map<String, dynamic>? errorMap;
  ErrorMap({this.body, this.message, this.status, this.errorMap});

  factory ErrorMap.empty() {
    return ErrorMap();
  }
}
''';
