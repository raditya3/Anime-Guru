import 'package:anime_discovery/Pages/Anime_details_page/anime_details_page.dart';
import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';

class AnimeCard extends StatelessWidget {
  final AnimeMeta animeEntity;
  final double height;
  final textHeight = 20;
  String getTruncatedTitle(String title){
    if(title.length>15){
      return "${title.substring(0,15)}...";
    }
    return title;
  }

  const AnimeCard({super.key, required this.animeEntity, required this.height});

  void _tapped(BuildContext context, int id) {
    Navigator.pushNamed(
      context,
      AnimeDetailsPage.routeName,
      arguments: {
        "id": id
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double imageCardHeight = height-textHeight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            SizedBox(
              width: (225 * imageCardHeight/ 320),
              height: imageCardHeight,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Image.network(animeEntity.imageUrl),
              ),
            ),
            SizedBox(
              width: (225 * imageCardHeight / 320),
              height: imageCardHeight,
              child: Material(
                color: const Color.fromARGB(50, 0, 0, 0),
                child: InkWell(
                  onTap: () => _tapped(context,animeEntity.malId),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(getTruncatedTitle(animeEntity.title),style: Theme.of(context).textTheme.labelSmall,)
          ],
        )
      ],
    );
  }
}
