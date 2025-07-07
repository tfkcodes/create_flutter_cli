/******
 *  Add your provider setuos here
 * class, getter and setter should be placed here
 * 
 * [example]
 * 
 * 
 */

String exampleProvider(String name) => '''

import 'package:name/data/models/example_model.dart';
class ExampleProvider extends ChangeNotifier {

bool _exampleLoading = false;
  bool get exampleLoading => _exampleLoading;
  ExampleModel _exampleModel = ExampleModel.empty();
  ExampleModel get exampleModel => _exampleModel;
  Future<void> getExampleData(
      Map<String, dynamic> params, String token) async {
    _exampleLoading = true;
    notifyListeners();
    final value = await ExampleRepository()
        .exampleRequest(params: params, token: token);
    if (value.isLeft) {
      _exampleModel = value.left;
      _exampleLoading = false;
      notifyListeners();
    } else {
      _exampleModel = ExampleModel.empty();
      _exampleLoading = false;
      notifyListeners();
    }
  }
  
  }

''';
