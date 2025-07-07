/// Returns an example Dart model using Equatable for value comparison.
///
/// This model includes utility methods like `.fromJson`, `.toJson`,
/// `.empty`, `.isEmpty`, and a `.toList` mapper.
String exampleModel() => '''

import 'package:equatable/equatable.dart';

/// A simple data model representing an example entity with an [id].
///
/// Implements [Equatable] to allow value comparison.
class ExampleModel extends Equatable {
  /// The unique identifier for the model.
  final String id;

  /// Constructor for creating an [ExampleModel] instance.
  const ExampleModel({
    required this.id,
  });

  /// Returns an empty [ExampleModel] with default values.
  factory ExampleModel.empty() {
    return ExampleModel(
      id: "",
    );
  }

  /// Checks whether the model is considered empty.
  bool get isEmpty => id.isEmpty;

  /// Checks whether the model contains data (is not empty).
  bool get isNotEmpty => !isEmpty;

  /// Factory constructor to create an [ExampleModel] from a JSON map.
  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id'] ?? '',
    );
  }

  /// Converts this model into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  /// Converts a list of JSON maps into a list of [ExampleModel] instances.
  static List<ExampleModel> toList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ExampleModel.fromJson(json))
        .toList();
  }

  /// Required override for Equatable to compare values.
  @override
  List<Object?> get props => [
        id,
      ];
}
''';
