import 'package:anime_discovery/Services/auth_service.dart';
import 'package:http_interceptor/http_interceptor.dart';

class CustomHttpClient extends InterceptorContract {
  final AuthService authService = AuthService.getAuthService();

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    String? isAuthorized = request.headers["Authorized"];
    request.headers.remove("Authorized");
    if (isAuthorized == "true") {
      String token = await authService.getAuthToken();
      request.headers["Authorization"] = "Bearer $token";
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    if (response.statusCode == 401) {
      authService.logout();
    }
    return response;
  }

  static InterceptedClient getClient() {
    return InterceptedClient.build(interceptors: [CustomHttpClient()]);
  }
}
