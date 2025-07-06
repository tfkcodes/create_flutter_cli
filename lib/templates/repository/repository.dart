/******
 *  Add your provider setuos here
 * class, getter and setter should be placed here
 * 
 * [example]
 * 
 * 
 */

String exampleRepository() => '''

import 'package:either_dart/either.dart';
import 'package:create_flutter_cli/src/api/error_map.dart';
import 'package:create_flutter_cli/src/templates/models/example_model.dart';
import 'package:create_flutter_cli/src/api/request.dart';


class ExampleRepository{
Future<Either<ExampleModel, ErrorMap>> exampleRequest(
      {required Map<String, dynamic> params,
      token = "",
      String id = ""}) async {
    return await ApplicationBaseRequest.get(
      AppAssets.baseUrl,
      AppAssets.getExampleEndpoint,
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
