import 'package:anime_discovery/Components/anime_list_scroller.dart';
import 'package:anime_discovery/Entities/user_anime_watch_status.dart';
import 'package:anime_discovery/Pages/Home/drawer_layout.dart';
import 'package:anime_discovery/Pages/search_page.dart';
import 'package:anime_discovery/Repositories/Implementations/mal_anime_repo.dart';
import 'package:anime_discovery/Repositories/anime_repo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/user_provider.dart';
import 'package:jikan_api/jikan_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AnimeRepo _animeRepo = MalAnimeRepo();
  List<AnimeMeta> _animesRecommended = [];
  List<AnimeMeta> _animeCurrentlyWatching=  [];
  List<AnimeMeta> _animeCompleted = [];
  bool _isDataReady = false;


  Future<void> _updateData() async {

    setState(() {
      _isDataReady = false;
    });

    List<AnimeMeta> recommendedAnimes = await _animeRepo.getAnimeSuggestions(15);

    List<AnimeMeta> userAnimesWatching = (await _animeRepo.getUserAnimeAndStatusList(UserAnimeWatchStatusEnum.watching)).map((animeAndStatus) => animeAndStatus.animeMeta).toList();
    List<AnimeMeta> userAnimesCompleted = (await _animeRepo.getUserAnimeAndStatusList(UserAnimeWatchStatusEnum.completed)).map((animeAndStatus) => animeAndStatus.animeMeta).toList();


    setState(() {
      _animesRecommended = recommendedAnimes;
      _animeCurrentlyWatching = userAnimesWatching;
      _animeCompleted = userAnimesCompleted;
      _isDataReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateData();
    });

  }



  void _onSearchIconPress(){

    Navigator.pushNamed(
      context,
      SearchPage.routeName,
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.secondary
        ),
          title: Row(children: [
            const Spacer(),
            IconButton(onPressed: _onSearchIconPress, icon: Icon(Icons.search,color: Theme.of(context).colorScheme.secondary,))
    ],),),
      drawer: const DrawerLayout(),

      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _updateData,
          child: _isDataReady?ListView(
            children: [
              const SizedBox(
                height: 20,
              ),

              // Welcome
              Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, ",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      Provider.of<UserProvider>(context).user?.name ?? 'Unknown',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50,),

              // Personal Recommendation
              AnimeListScroller(
                  headerText: "Recommended For You", animes: _animesRecommended),
              const SizedBox(height: 8),

              // Currently Watching
              _animeCurrentlyWatching.isNotEmpty?AnimeListScroller(headerText: "Currently Watching", animes: _animeCurrentlyWatching):Container(),
              const SizedBox(height: 8),


              _animeCompleted.isNotEmpty?AnimeListScroller(headerText: "Completed Watching", animes: _animeCompleted):Container(),
            ],
          ): Center(child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ),),
        ),
      ),
    );
  }
}
