String exampleModel() => '''

import 'package:equatable/equatable.dart';

class ExampleModel extends Equatable {
  final String id;


  const ExampleModel({
    required this.id,
  });
  factory ExampleModel.empty() {
    return ExampleModel(
      id: "",
    );
  }

  bool get isEmpty =>
      id.isEmpty

  bool get isNotEmpty => !isEmpty;
  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

    static List<ExampleModel> toList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ExampleModel.fromJson(json))
        .toList();
  }

  @override
  List<Object?> get props => [
        id,
      ];
}
''';
