import 'package:flutter/material.dart';
import '../../data/repository/movies_repository.dart';
import '../../domain/model/movie.dart';
import '../../domain/service/app_service.dart';
import 'movie_preview.dart';
import 'movies_list_model.dart';
import '../../util/l10n/app_localizations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class MoviesListScreen extends StatefulWidget {
  @override
  State<MoviesListScreen> createState() => _MoviesListScreenState();
}

class _MoviesListScreenState extends State<MoviesListScreen> {
  late final AppService _appService;
  late final MoviesListModel _model;

  late final PagingController<int, Movie> _pagingController;
  late final Future<void> _future;

  @override
  void initState() {
    super.initState();

    _appService = Provider.of<AppService>(context, listen: false);

    _model = MoviesListModel(
      log: Provider.of<Logger>(context, listen: false),
      moviesRepo: Provider.of<MoviesRepository>(context, listen: false),
    );

    _pagingController = PagingController(
      getNextPageKey: (state) {
        final lastKey = state.keys?.last;
        return lastKey == null ? 1 : lastKey + 1;
      },
      fetchPage: (pageKey) async {
        return await _model.fetchPage(pageKey);
      },
    );

    _future = _checkNewData();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).upcomingMovies),
        actions: [
          IconButton(
            onPressed: () {
              _appService.themeMode = _appService.themeMode == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
            tooltip: AppLocalizations.of(context).toggleLightDart,
            icon: Icon(
              _appService.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) => RefreshIndicator(
            onRefresh: _refresh,
            child: PagingListener<int, Movie>(
              controller: _pagingController,
              builder: (context, state, fetchNextPage) {
                return PagedListView<int, Movie>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate<Movie>(
                    itemBuilder: (context, movie, index) =>
                        MoviePreview(movie: movie),
                  ),
                );
              },
            )
            // child: PagedListView<int, Movie>(
            //   pagingController: _pagingController,
            //   builderDelegate: PagedChildBuilderDelegate<Movie>(
            //     itemBuilder: (context, movie, index) => Padding(
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 12,
            //         vertical: 6,
            //       ),
            //       child: MoviePreview(movie: movie),
            //     ),
            //   ),
            // ),
            ),
      ),
    );
  }

  Future<void> _refresh() async {
    await _model.deletePersistedMovies();
    _pagingController.refresh();
  }

  Future<void> _checkNewData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final appLocalizations = AppLocalizations.of(context);
      final hasNewData = await _model.hasNewData();

      if (hasNewData) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(appLocalizations.getNewData),
            action: SnackBarAction(
              label: appLocalizations.refresh,
              onPressed: _refresh,
            ),
          ),
        );
      }
    });
  }
}
