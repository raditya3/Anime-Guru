import 'package:anime_discovery/Entities/anime_and_status.dart';
import 'package:anime_discovery/Entities/user_anime_watch_status.dart';
import 'package:jikan_api/jikan_api.dart';

abstract class AnimeRepo {
  Future<List<AnimeMeta>> getAnimeSuggestions(int limit);
  Future<Anime> getAnimeDetailsEntityById(int id);
  Future<List<AnimeAndStatus>> getUserAnimeAndStatusList(UserAnimeWatchStatusEnum? userAnimeStatus);
  Future<UserAnimeWatchStatusEnum> getAnimeWatchStatus(int malId);
  Future<int> getUserRating(int malId);
  Future<int> updateUserRating(int malId, int newRating);
  Future<UserAnimeWatchStatusEnum> updateAnimeWatchStatus(int malId, UserAnimeWatchStatusEnum watchStatus);
  Future<List<AnimeMeta>> getAnimesFromSearchString(String query);
  Future<List<AnimeMeta>> getRelatedAnime(int malId);
  Future<List<AnimeMeta>> getSimilarAnime(int malId);
}