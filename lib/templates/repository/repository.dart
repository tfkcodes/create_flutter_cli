/******
 *  Add your provider setuos here
 * class, getter and setter should be placed here
 * 
 * [example]
 * 
 * 
 */

String exampleRepository(String name) => '''

import 'package:either_dart/either.dart';
import 'package:\$name/core/network/error_map.dart';
import 'package:\$name/data/models/example_model.dart';
import 'package:\$name/core/network/request.dart';
import 'package:\$name/core/network/endpoints.dart';


class ExampleRepository{
Future<Either<ExampleModel, ErrorMap>> exampleRequest(
      {required Map<String, dynamic> params,
      token = "",
      String id = ""}) async {
    return await ApplicationBaseRequest.get(
      Endpoints.baseUrl,
      Endpoints.getExampleEndpoint,
      token: token,
    ).request().then((response) {
      if (response.status ~/ 100 == 2) {
        bool status = response.data["success"];

        if (status) {
          return Left(ExampleModel.fromJson(response.data["data"]));
        } else {
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
