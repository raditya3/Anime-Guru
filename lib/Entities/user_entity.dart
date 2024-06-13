import 'package:anime_discovery/Entities/user_anime_watch_status.dart';

class UserAnimeStatus {
  final int malId;
  final UserAnimeWatchStatusEnum status;
  int? score;
  int? episodesSeen;

  UserAnimeStatus(
      {required this.malId,
      required this.status,
      this.score,
      this.episodesSeen});
}

class UserEntity {
  final int id;
  final String name;
  final String pictureUrl;
  final String? gender;
  final String? birthday;
  final String? location;
  final String? joinedAt;
  final AnimeStats? animeStatistics;
  final String? timeZone;
  final bool? isSupporter;

  UserEntity(
      {required this.id,
      required this.name,
      required this.pictureUrl,
      required this.gender,
      required this.birthday,
      required this.location,
      required this.joinedAt,
      required this.animeStatistics,
      required this.timeZone,
      required this.isSupporter});

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
        id: json["id"],
        name: json["name"],
        pictureUrl: json["pictureurl"] ?? '',
        gender: json["gender"],
        birthday: json["birthday"],
        location: json["location"],
        joinedAt: json["joined_at"],
        animeStatistics: AnimeStats.fromJson(json["anime_statistics"]),
        timeZone: json["time_zone"],
        isSupporter: json["is_supporter"]);
  }
}

class AnimeStats {
  final int numItemsWatching;

  final int numItemsCompleted;
  final int numItemsOnHold;

  final int numItemsDropped;

  final int numItemsPlanToWatch;

  final int numItems;

  final double numDaysWatched;

  final double numDaysWatching;

  final double numDaysCompleted;

  final double numDaysOnHold;

  final double numDaysDropped;

  final double numDays;

  final int numEpisodes;
  final int numTimesReWatched;

  final double meanScore;

  AnimeStats(
      {required this.numItemsWatching,
      required this.numItemsCompleted,
      required this.numItemsOnHold,
      required this.numItemsDropped,
      required this.numItemsPlanToWatch,
      required this.numItems,
      required this.numDaysWatched,
      required this.numDaysWatching,
      required this.numDaysCompleted,
      required this.numDaysOnHold,
      required this.numDaysDropped,
      required this.numDays,
      required this.numEpisodes,
      required this.numTimesReWatched,
      required this.meanScore});

  factory AnimeStats.fromJson(Map<String, dynamic> json) {
    json["num_days_watched"] = json["num_days_watched"] * 1.0;
    json["num_days_watching"] = json["num_days_watching"] * 1.0;
    json["num_days_completed"] = json["num_days_completed"] * 1.0;
    json["num_days_on_hold"] = json["num_days_on_hold"] * 1.0;
    json["num_days_dropped"] = json["num_days_dropped"] * 1.0;
    json["num_days"] = json["num_days"] * 1.0;
    return AnimeStats(
        numItemsWatching: json["num_items_watching"],
        numItemsCompleted: json["num_items_completed"],
        numItemsOnHold: json["num_items_on_hold"],
        numItemsDropped: json["num_items_dropped"],
        numItemsPlanToWatch: json["num_items_plan_to_watch"],
        numItems: json["num_items"],
        numDaysWatched: json["num_days_watched"],
        numDaysWatching: json["num_days_watching"],
        numDaysCompleted: json["num_days_completed"],
        numDaysOnHold: json["num_days_on_hold"],
        numDaysDropped: json["num_days_dropped"],
        numDays: json["num_days"],
        numEpisodes: json["num_episodes"],
        numTimesReWatched: json["num_times_rewatched"],
        meanScore: json["mean_score"]);
  }
}
