

import 'package:anime_discovery/Components/anime_card.dart';
import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';

class AnimeListScroller extends StatelessWidget {
  const AnimeListScroller({super.key, required this.headerText, required this.animes});

  final String headerText;
  final List<AnimeMeta> animes;
  final double height = 200;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Text(headerText, style: Theme.of(context).textTheme.headlineLarge,),
            ],
          ),
        ),
        const SizedBox(height: 10,),
        SizedBox(
          height: height,
          child: ListView.builder(

            scrollDirection: Axis.horizontal,
              itemCount: animes.length+1,
                itemBuilder:   (context,index) {
            if(index==0){
              return const SizedBox(width: 10);
            } else {
              return Padding(
                padding: const EdgeInsets.only(right:2.0),
                child: AnimeCard(animeEntity: animes[index-1],height: height),
              );
            }
          }),
        )
      ],
    );
  }
}
