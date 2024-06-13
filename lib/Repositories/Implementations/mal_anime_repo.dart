import 'dart:convert';
import 'package:anime_discovery/Entities/anime_and_status.dart';
import 'package:anime_discovery/Entities/user_anime_watch_status.dart';
import 'package:anime_discovery/Entities/user_entity.dart';
import 'package:anime_discovery/Repositories/anime_repo.dart';
import 'package:anime_discovery/Services/auth_service.dart';
import 'package:anime_discovery/Services/custom_http_client.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:jikan_api/jikan_api.dart';

class MalAnimeRepo implements AnimeRepo {
  final AuthService authService = AuthService.getAuthService();
  final InterceptedClient http = CustomHttpClient.getClient();

  // We should try not to use jikan api
  final jikan = Jikan();

  @override
  Future<List<AnimeMeta>> getAnimeSuggestions(int limit) async {
    Uri suggestionsUri = Uri.https("api.myanimelist.net",
        "/v2/anime/suggestions", {"limit": limit.toString(), "fields": "id"});

    var response =
        await http.get(suggestionsUri, headers: {"Authorized": 'true'});
    Map<String, dynamic> decoded = jsonDecode(response.body);

    List<dynamic> data = decoded["data"];
    return await Future.wait(data.map((node) async {
      return AnimeMeta.fromJson({
        "mal_id": node["node"]["id"],
        "url": '',
        "image_url": node["node"]["main_picture"]["large"],
        "title": node["node"]["title"]
      });
    }));
  }

  @override
  Future<Anime> getAnimeDetailsEntityById(int id) async {
    return jikan.getAnime(id);
  }

  @override
  Future<List<AnimeAndStatus>> getUserAnimeAndStatusList(UserAnimeWatchStatusEnum? userAnimeStatus) async {

    Map<String,String> queryParams = {
      "fields" : "list_status",
      "limit" : "150",
    };
    if(userAnimeStatus!=null){
      queryParams["status"] = userAnimeStatus.status;
    }
    Uri userAnimeList = Uri.https("api.myanimelist.net",
        "/v2/users/@me/animelist", queryParams);

    var response =
        await http.get(userAnimeList, headers: {"Authorized": 'true'});

    Map<String, dynamic> decoded = jsonDecode(response.body);
    List<dynamic> animelist = decoded["data"];

    return await Future.wait(animelist.map((dataItem) async {
      var node = dataItem["node"];
      var listStatus = dataItem["list_status"];
      var animeMeta = AnimeMeta.fromJson({
        "mal_id": node["id"],
        "url": '',
        "image_url": node["main_picture"]["large"],
        "title": node["title"]
      });
      var userAnimeStatus = UserAnimeStatus(malId: node["id"], status: UserAnimeWatchStatusEnum.getEnumFromString(listStatus["status"]),
      score: listStatus["score"],
        episodesSeen: listStatus["num_watched_episodes"]
      );

      return AnimeAndStatus(animeMeta: animeMeta, userAnimeStatus: userAnimeStatus);
    }));
  }

  @override
  Future<UserAnimeWatchStatusEnum> updateAnimeWatchStatus(
      int malId, UserAnimeWatchStatusEnum watchStatus) async {
    Uri updateStatusUri =
        Uri.https('api.myanimelist.net', '/v2/anime/$malId/my_list_status');
    var response = await http.put(updateStatusUri,
        headers: {"Authorized": "true"}, body: {"status": watchStatus.status});
    Map<String, dynamic> decoded = jsonDecode(response.body);

    String status = decoded["status"];

    return UserAnimeWatchStatusEnum.getEnumFromString(status);
  }

  @override
  Future<List<AnimeMeta>> getAnimesFromSearchString(String query) async {
    if (query.length < 3) {
      return [];
    }
    return jikan.searchAnime(query: query).then((animesList) => animesList
        .map((anime) => AnimeMeta.fromJson({
              "mal_id": anime.malId,
              "url": anime.url,
              "image_url": anime.imageUrl,
              "title": anime.title
            }))
        .toList());
  }

  @override
  Future<List<AnimeMeta>> getRelatedAnime(int malId) async {
    Uri relatedAnimeUri = Uri.https(
        "api.myanimelist.net", "/v2/anime/$malId", {"fields": "related_anime"});
    var response =
        await http.get(relatedAnimeUri, headers: {"Authorized": "true"});
    var decoded = jsonDecode(response.body);
    return (decoded["related_anime"] as List<dynamic>)
        .map((element) => AnimeMeta.fromJson({
              "mal_id": element["node"]["id"],
              "url": '',
              "image_url": element["node"]["main_picture"]["large"],
              "title": element["node"]["title"]
            }))
        .toList();
  }

  @override
  Future<List<AnimeMeta>> getSimilarAnime(int malId) async {
    Uri relatedAnimeUri = Uri.https("api.myanimelist.net", "/v2/anime/$malId",
        {"fields": "recommendations"});
    var response =
        await http.get(relatedAnimeUri, headers: {"Authorized": "true"});
    var decoded = jsonDecode(response.body);
    return (decoded["recommendations"] as List<dynamic>)
        .map((element) => AnimeMeta.fromJson({
              "mal_id": element["node"]["id"],
              "url": '',
              "image_url": element["node"]["main_picture"]["large"],
              "title": element["node"]["title"]
            }))
        .toList();
  }

  @override
  Future<UserAnimeWatchStatusEnum> getAnimeWatchStatus(int malId) async {
    Uri animeStatusUri = Uri.https("api.myanimelist.net","/v2/anime/$malId",{
      "fields" : "my_list_status"
    });

    var response = await http.get(animeStatusUri,headers: {"Authorized" : "true"});

    Map<String,dynamic> decoded = jsonDecode(response.body);
    String? status = decoded["my_list_status"]?["status"];

    if(status==null){
      return UserAnimeWatchStatusEnum.unknown;
    }

    return UserAnimeWatchStatusEnum.getEnumFromString(status);


  }

  @override
  Future<int> getUserRating(int malId) async {
    Uri animeStatusUri = Uri.https("api.myanimelist.net","/v2/anime/$malId",{
      "fields" : "my_list_status"
    });

    var response = await http.get(animeStatusUri,headers: {"Authorized" : "true"});
    Map<String,dynamic> decoded = jsonDecode(response.body);
    int? score = decoded["my_list_status"]?["score"];

    if(score==null){
      return -1;
    }

    return score;
  }

  @override
  Future<int> updateUserRating(int malId, int newRating) async {
    Uri updateStatusUri =
    Uri.https('api.myanimelist.net', '/v2/anime/$malId/my_list_status');
    var response = await http.put(updateStatusUri,
        headers: {"Authorized": "true"}, body: {"score": newRating.toString()});
    Map<String, dynamic> decoded = jsonDecode(response.body);

    int score = decoded["score"];

    return score;
  }
}
