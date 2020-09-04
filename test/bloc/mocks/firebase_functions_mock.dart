import 'package:cloud_functions/cloud_functions.dart';
import 'package:mockito/mockito.dart';

class FirebaseFunctionsMock extends Mock implements CloudFunctions{
  @override
  HttpsCallable getHttpsCallable({String functionName}) {
    return HttpsCallableMock();
  }
}

class HttpsCallableMock extends Mock implements HttpsCallable{
 @override
  Future<HttpsCallableResult> call([parameters]) {
    return Future.value(HttpsCallableResultMock());
  }
}

class HttpsCallableResultMock extends Mock implements HttpsCallableResult{

}