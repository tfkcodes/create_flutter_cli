/******
 *  Add your provider setups here
 *  Include class, getters, setters, and methods to manage state.
 * 
 *  [ExampleProvider]
 *  This is a sample implementation of a ChangeNotifier Provider for Flutter
 *  using a repository and model structure.
 */

String exampleProvider(String name) => '''

import 'package:$name/data/models/example_model.dart';
import 'package:flutter/foundation.dart'; // for ChangeNotifier
import 'package:$name/data/repositories/example_repository.dart';

/// A ChangeNotifier-based provider that manages the state of [ExampleModel].
///
/// Includes loading state, data fetching, and model exposure.
class ExampleProvider extends ChangeNotifier {

  /// Private flag indicating if data is currently being loaded.
  bool _exampleLoading = false;

  /// Public getter to check if the provider is loading data.
  bool get exampleLoading => _exampleLoading;

  /// Private variable to hold the fetched model data.
  ExampleModel _exampleModel = ExampleModel.empty();

  /// Public getter to access the current [ExampleModel].
  ExampleModel get exampleModel => _exampleModel;

  /// Fetches data from the ExampleRepository and updates state accordingly.
  ///
  /// [params] - Query parameters or body data required for the request.
  /// [token] - Optional authentication token used in the request header.
  Future<void> getExampleData(
      Map<String, dynamic> params, String token) async {
    _exampleLoading = true;
    notifyListeners(); // Notify UI to reflect loading state

    final value = await ExampleRepository()
        .exampleRequest(params: params, token: token);

    if (value.isLeft) {
      // Success case: update the model with received data
      _exampleModel = value.left;
    } else {
      // Failure case: reset to empty model
      _exampleModel = ExampleModel.empty();
    }

    _exampleLoading = false;
    notifyListeners(); // Notify UI to reflect new state
  }
}
''';
