
import 'dart:async';

import 'package:anime_discovery/Pages/Anime_details_page/anime_details_page.dart';
import 'package:anime_discovery/Repositories/Implementations/mal_anime_repo.dart';
import 'package:anime_discovery/Repositories/anime_repo.dart';
import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  static const String routeName = "/search";

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final AnimeRepo _animeRepo = MalAnimeRepo();
  List<AnimeMeta> _animeSearchResult = [];
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();


  void onTap(int malId) {
    Navigator.pushNamed(
      context,
      AnimeDetailsPage.routeName,
      arguments: {
        "id": malId
      },
    );
  }

  void _queryCallBack(String query) async {
    List<AnimeMeta> result = await _animeRepo.getAnimesFromSearchString(query);
    setState(() {
      
      _animeSearchResult = result;
      _scrollController.animateTo(0.0,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,);
    });
  }

  void _querySearch(String? _){
    if(_debounce?.isActive ?? false){
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 1000), (){
      String searchText = _controller.value.text;
      _queryCallBack(searchText);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),),
      body: SafeArea(
        child: Column(
          children: [
            // Search text field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:  20.0, vertical: 10),
              child: TextField(
                controller: _controller,
                style: Theme.of(context).textTheme.labelLarge,
                onChanged: (String text){

                  setState(() {
                    _querySearch(text);
                  });
                },
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary,),
                  hintText: "Search...",

                  suffixIcon: _controller.text.isNotEmpty?IconButton(onPressed: (){
                    _controller.clear();
                    setState(() {});
                  }, icon: Icon(Icons.close, color: Theme.of(context).colorScheme.secondary)):null,
                  focusedBorder: OutlineInputBorder(
                    borderSide:BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ),
                  ),

                  hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary
                  ),
                ),
              ),
            ),

            // Results area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                  itemCount: _animeSearchResult.length,
                  itemBuilder: (BuildContext context, int index) {
                    AnimeMeta anime = _animeSearchResult[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                          color: const Color.fromARGB(50, 0, 0, 0),
                        child: InkWell(
                          onTap: () => onTap(anime.malId),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(anime.imageUrl, width: 120,),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                      
                                  SizedBox(width:200, child: Text(anime.title, style: Theme.of(context).textTheme.headlineLarge,))
                                ],
                              )
                      
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
