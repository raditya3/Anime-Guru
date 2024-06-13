import 'package:anime_discovery/Pages/Anime_details_page/anime_rating_dialog.dart';
import 'package:flutter/material.dart';
import 'package:anime_discovery/Components/album_details_art.dart';
import 'package:anime_discovery/Entities/user_anime_watch_status.dart';
import 'package:anime_discovery/Repositories/Implementations/mal_anime_repo.dart';
import 'package:anime_discovery/Repositories/anime_repo.dart';
import 'package:jikan_api/jikan_api.dart';
import '../../Components/anime_list_scroller.dart';

class AnimeDetailsPage extends StatefulWidget {
  final int id;

  const AnimeDetailsPage({super.key, required this.id});

  static String routeName = "/anime-details";

  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  final AnimeRepo _animeRepo = MalAnimeRepo();
  Anime? _animeDetailsEntity;
  bool _isDataLoaded = false;
  bool isArtLoaded = false;
  UserAnimeWatchStatusEnum _watchStatus = UserAnimeWatchStatusEnum.unknown;
  bool _isWatchStatusUpdating = false;
  List<AnimeMeta> _relatedAnime = [];
  List<AnimeMeta> _similarAnime = [];
  UserAnimeWatchStatusEnum _newWatchStatus = UserAnimeWatchStatusEnum.unknown;
  bool _showUpdateStatusWidget = false;
  int _animeUserRating = -1;
  bool _isScoreUpdating = false;

  void toggleWatchStatus() async {
    setState(() {
      _isWatchStatusUpdating = true;
    });

    if (_newWatchStatus == UserAnimeWatchStatusEnum.unknown) {
      return;
    }

    UserAnimeWatchStatusEnum status = await _animeRepo.updateAnimeWatchStatus(
        _animeDetailsEntity!.malId, _newWatchStatus);
    setState(() {
      _newWatchStatus = UserAnimeWatchStatusEnum.unknown;
      _watchStatus = status;
      _isWatchStatusUpdating = false;
    });
  }

  void initialize(BuildContext context) async {
    var animeDetailsEntity =
        await _animeRepo.getAnimeDetailsEntityById(widget.id);

    var relatedAnime =
        await _animeRepo.getRelatedAnime(animeDetailsEntity.malId);

    UserAnimeWatchStatusEnum userAnimeStatus =
        await _animeRepo.getAnimeWatchStatus(animeDetailsEntity.malId);

    int score = await _animeRepo.getUserRating(animeDetailsEntity.malId);

    var similarAnime =
        await _animeRepo.getSimilarAnime(animeDetailsEntity.malId);
    setState(() {
      _animeUserRating = score;
      _animeDetailsEntity = animeDetailsEntity;
      _watchStatus = userAnimeStatus;
      _relatedAnime = relatedAnime;
      _isDataLoaded = true;
      _similarAnime = similarAnime;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initialize(context);
    });
  }

  String getTruncatedTitle(String title) {
    if (title.length > 20) {
      return "${title.substring(0, 20)}...";
    }
    return title;
  }

  void _onGenrePress() {}

  void updateRadioGroup(UserAnimeWatchStatusEnum? watchStatus) {
    if (watchStatus != null) {
      setState(() {
        _newWatchStatus = watchStatus;
      });
    }
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AnimeRatingDialog(initialRating:_animeUserRating, submit: (int newRating) {
          setState(() {
            _isScoreUpdating = true;
          });
          _animeRepo.updateUserRating(_animeDetailsEntity!.malId, newRating).then((newScore) {
            setState(() {
              _isScoreUpdating = false;
              _animeUserRating = newScore;
            });
          });


        },);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: _isDataLoaded
            ? Stack(
                children: [
                  ListView(
                    children: [
                      // Cover Art
                      AnimeDetailsArt(
                        animeDetailsEntity: _animeDetailsEntity!,
                      ),
                      const SizedBox(height: 10),

                      // Synopsis
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _animeDetailsEntity?.synopsis ?? '',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign
                                  .justify, // Ensures text is justified and wraps properly
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      Row(
                        children: [
                          // Watch Status
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _newWatchStatus = _watchStatus;
                                      _showUpdateStatusWidget = true;
                                    });
                                  },
                                  child: _isWatchStatusUpdating
                                      ? SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: CircularProgressIndicator(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ))
                                      : UserAnimeWatchStatusEnum
                                          .getWatchStatusWidget(_watchStatus),
                                )
                              ],
                            ),
                          ),

                          // User score
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                _isScoreUpdating
                                    ? SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: CircularProgressIndicator(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ))
                                    : OutlinedButton(
                                        onPressed: () {
                                          _showRatingDialog();
                                        },
                                        style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                            shape:
                                                const BeveledRectangleBorder()),
                                        child: Text(
                                          "Your Rating: $_animeUserRating",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                      )
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Widget to update status
                      _showUpdateStatusWidget
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...UserAnimeWatchStatusEnum.values
                                    .where((watchStatus) =>
                                        watchStatus !=
                                        UserAnimeWatchStatusEnum.unknown)
                                    .map((watchStatus) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
                                        RadioListTile<UserAnimeWatchStatusEnum>(
                                      tileColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      title: Text(watchStatus.status),
                                      value: watchStatus,
                                      groupValue: _newWatchStatus,
                                      onChanged: updateRadioGroup,
                                    ),
                                  );
                                }),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                          onPressed: () {
                                            toggleWatchStatus();
                                            _showUpdateStatusWidget = false;
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Update",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium,
                                            ),
                                          )),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                          onPressed: () {
                                            setState(() {
                                              _showUpdateStatusWidget = false;
                                              _newWatchStatus = _watchStatus;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Cancel",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium,
                                            ),
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            )
                          : Container(),

                      // Genre
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Genre",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 25,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      _animeDetailsEntity?.genres.length ?? 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var genre =
                                        _animeDetailsEntity!.genres[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                width: 1.0,
                                                color: Colors.white),
                                          ),
                                          onPressed: _onGenrePress,
                                          child: Text(
                                            genre.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          )),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _relatedAnime.isNotEmpty
                          ? AnimeListScroller(
                              headerText: "Related", animes: _relatedAnime)
                          : Container(),
                      const SizedBox(height: 15),

                      _similarAnime.isNotEmpty
                          ? AnimeListScroller(
                              headerText: "More like this",
                              animes: _similarAnime)
                          : Container(),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      iconTheme: const IconThemeData(color: Colors.white),
                    ),
                  ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: CircularProgressIndicator(color: Colors.white)),
                ],
              ));
  }
}
