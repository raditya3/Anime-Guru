import 'package:flutter/material.dart';

Widget _getStatusWidget(String text, Color color) {
  return Container(
    decoration: BoxDecoration(
        color: color
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal:  15.0, vertical: 10.0),
      child: Text(text, style: const TextStyle(color: Colors.white),),
    ),
  );
}

enum UserAnimeWatchStatusEnum {
  unknown("unknown"),
  dropped("dropped"),
  completed("completed"),
  watching("watching"),
  planToWatch("plan_to_watch");

  const UserAnimeWatchStatusEnum(this.status);
  final String status;
  static UserAnimeWatchStatusEnum getEnumFromString(String literal) {
    return UserAnimeWatchStatusEnum.values.firstWhere((statusEnum) => literal.toLowerCase().contains(statusEnum.status), orElse: () => UserAnimeWatchStatusEnum.unknown);
  }
  static Widget getWatchStatusWidget(UserAnimeWatchStatusEnum userAnimeWatchStatusEnum){
    switch(userAnimeWatchStatusEnum){
      case UserAnimeWatchStatusEnum.completed:
        return _getStatusWidget("Completed", Colors.green);
      case UserAnimeWatchStatusEnum.dropped:
        return _getStatusWidget("Dropped", Colors.red);
      case UserAnimeWatchStatusEnum.watching:
        return _getStatusWidget("Watching", Colors.yellow.shade900);
      case UserAnimeWatchStatusEnum.planToWatch:
        return _getStatusWidget("Plan To Watch", Colors.teal.shade600);
      default:
        return _getStatusWidget("Not Started", Colors.grey);
    }
  }
}