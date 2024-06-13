import 'package:anime_discovery/Entities/user_entity.dart';
import 'package:jikan_api/jikan_api.dart';

class AnimeAndStatus {
  final AnimeMeta animeMeta;
  final UserAnimeStatus userAnimeStatus;

  AnimeAndStatus({required this.animeMeta, required this.userAnimeStatus});
}