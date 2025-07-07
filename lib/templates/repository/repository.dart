/******
 *  Add your repository setups here
 *  This repository handles API requests and returns either data or error responses.
 * 
 *  [ExampleRepository]
 *  This example demonstrates using `Either` to handle success/failure cases cleanly.
 */

String exampleRepository(String name) => '''

import 'package:either_dart/either.dart';
import 'package:$name/core/network/error_mapper.dart';
import 'package:$name/data/models/example_model.dart';
import 'package:$name/core/network/api_client.dart';
import 'package:$name/core/network/endpoints.dart';

/// A repository responsible for handling ExampleModel-related API calls.
///
/// Uses `ApplicationBaseRequest` to perform HTTP requests and returns
/// an `Either<ExampleModel, ErrorMap>` for structured success/error handling.
class ExampleRepository {

  /// Sends a GET request to retrieve example data.
  ///
  /// Parameters:
  /// - [params]: Query parameters for the request.
  /// - [token]: Optional auth token (defaults to empty string).
  /// - [id]: Optional identifier (not used in this implementation).
  ///
  /// Returns:
  /// - `Left(ExampleModel)` on success.
  /// - `Right(ErrorMap)` on failure.
  Future<Either<ExampleModel, ErrorMap>> exampleRequest({
    required Map<String, dynamic> params,
    String token = "",
    String id = "",
  }) async {
    return await ApplicationBaseRequest.get(
      Endpoints.baseUrl,
      Endpoints.getExampleEndpoint,
      params: params,
      token: token,
    ).request().then((response) {
      // Check if the HTTP status is successful (2xx)
      if (response.status ~/ 100 == 2) {
        bool status = response.data["success"];

        if (status) {
          // Successful API response
          return Left(ExampleModel.fromJson(response.data["data"]));
        } else {
          // API returned success=false but status code is 200
          return Right(
            ErrorMap(
              status: response.status,
              message: response.data['message'],
              body: response.body,
              errorMap: response.data,
            ),
          );
        }
      } else {
        // API returned an error (non-2xx status)
        return Right(
          ErrorMap(
            status: response.status,
            message: response.message,
            body: response.body,
            errorMap: response.data,
          ),
        );
      }
    });
  }
}
''';
