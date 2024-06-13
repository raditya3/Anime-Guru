import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:jikan_api/jikan_api.dart';

RatingData convertRatingToDescription(String? rating) {
  // Define the mapping from rating value to description
  Map<String, RatingData> ratingDescriptions = {
    "unknown":
        RatingData(color: Colors.grey, short: "N/A", description: "Unknown"),
    'G': RatingData(
      color: Colors.green,
      short: 'G',
      description: 'G - All Ages',
    ),
    'PG': RatingData(
      color: Colors.blue,
      short: 'PG',
      description: 'PG - Children',
    ),
    'PG-13': RatingData(
      color: Colors.orange,
      short: 'PG-13',
      description: 'PG-13 - Teens 13 and Older',
    ),
    'R': RatingData(
      color: Colors.red,
      short: 'R',
      description: 'R - 17+ (violence & profanity)',
    ),
    'R+': RatingData(
      color: Colors.purple,
      short: 'R+',
      description: 'R+ - Profanity & Mild Nudity',
    ),
    'Rx': RatingData(
      color: Colors.black,
      short: 'Rx',
      description: 'Rx - Hentai',
    ),
  };

  // Return the corresponding description or a default value if the rating is not found
  String identifiedRating = ratingDescriptions.keys.firstWhere((ratingKey) => rating?.contains(ratingKey) ?? false, orElse: () => "unknown");
  return ratingDescriptions[identifiedRating]!;
}

class RatingData {
  final Color color;
  final String short;
  final String description;

  RatingData(
      {required this.color, required this.short, required this.description});
}

class AnimeDetailsArt extends StatelessWidget {
  const AnimeDetailsArt({super.key, required this.animeDetailsEntity});

  final Anime animeDetailsEntity;

  @override
  Widget build(BuildContext context) {
    var placeholder = const SizedBox(
      height: 1,
      width: double.infinity,
      child: LinearProgressIndicator(color: Colors.white,),
    );

    String? imageUri = animeDetailsEntity.imageUrl;

    Future<Uint8List> imageBytes = http.get(Uri.parse(imageUri)).then((response) => response.bodyBytes);
    return FutureBuilder<Uint8List>(
        future: imageBytes,
        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
          if (snapshot.hasData) {

            final Uint8List imageBytes = snapshot.data!;
            final img.Image? image = img.decodeImage(imageBytes);
            if (image != null) {
              int imHeight = image.height;
              return Stack(
                children: [
                  // Image
                  SizedBox(
                    width: double.infinity,
                    height: imHeight.toDouble(),
                    child: FittedBox(
                        fit: BoxFit.fill, child: Image.memory(imageBytes)
                        ),
                  ),

                  // Info overlay
                  Container(
                    width: double.infinity,
                    height: imHeight.toDouble(),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            animeDetailsEntity.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),

                          // rating and score
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.yellowAccent,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                animeDetailsEntity.score?.toString() ?? 'N/A',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  color: convertRatingToDescription(
                                          animeDetailsEntity.rating)
                                      .color,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      convertRatingToDescription(
                                              animeDetailsEntity.rating)
                                          .short,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }
          }
          return placeholder;
        });
  }
}
