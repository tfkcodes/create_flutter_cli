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
