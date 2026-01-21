import '../database/dao/movies_dao.dart';
import '../database/database_mapper.dart';
import '../network/client/api_client.dart';
import '../network/network_mapper.dart';
import '../../domain/model/movie.dart';

class MoviesRepository {
  final ApiClient apiClient;
  final NetworkMapper networkMapper;
  final MoviesDao moviesDao;
  final DatabaseMapper databaseMapper;

  MoviesRepository({
    required this.apiClient,
    required this.networkMapper,
    required this.moviesDao,
    required this.databaseMapper,
  });

  Future<List<Movie>> getUpcomingMovies({
    required int limit,
    required int page,
  }) async {
    // Try to load the movies from the database
    final dbEntities =
        await moviesDao.selectAll(limit: limit, offset: (page * limit) - limit);

    if (dbEntities.isNotEmpty) {
      return databaseMapper.toMovies(dbEntities);
    }

    // Fetch movies from remote API
    final entities = await apiClient.getUpcomingMovies(page: page);
    final movies = networkMapper.toMovies(entities.results);

    // Save movies to database
    moviesDao.insertAll(databaseMapper.toMovieDbEntities(movies));

    return movies;
  }

  Future<void> deleteAll() async => moviesDao.deleteAll();

  Future<bool> checkNewData() async {
    final entities = await moviesDao.selectAll(limit: 1);

    if (entities.isEmpty) {
      return false;
    }

    final entity = entities.first;

    final movies = await apiClient.getUpcomingMovies(page: 1, limit: 1);

    if (entity.movieId == movies.results.first.id) {
      return false;
    } else {
      return true;
    }
  }
}
