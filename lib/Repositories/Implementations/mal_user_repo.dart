import 'dart:convert';

import 'package:anime_discovery/Entities/user_entity.dart';
import 'package:anime_discovery/Repositories/user_repo.dart';
import 'package:anime_discovery/Services/custom_http_client.dart';
import 'package:http_interceptor/http/intercepted_client.dart';

class MalUserRepo implements UserRepo {
  final InterceptedClient http = CustomHttpClient.getClient();

  @override
  Future<UserEntity> getMyUserInfo() async {
    Uri meUri = Uri.https(
        "api.myanimelist.net", "/v2/users/@me",{"fields" : "anime_statistics"});
    var meResponse = await http.get(meUri, headers: {"Authorized": 'true'});
    dynamic decoded = jsonDecode(meResponse.body);
    return UserEntity.fromJson(decoded);
  }
}
