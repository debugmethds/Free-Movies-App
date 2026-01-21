import 'base_dao.dart';
import '../entity/movie_db_entity.dart';
import 'package:sqflite/sqflite.dart';

class MoviesDao extends BaseDao {
  Future<List<MovieDbEntity>> selectAll({
    int? limit,
    int? offset,
  }) async {
    final Database db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      BaseDao.moviesTableName,
      limit: limit,
      offset: offset,
      orderBy: '${MovieDbEntity.fieldId} ASC',
    );
    return List.generate(maps.length, (i) {
      return MovieDbEntity.fromJson(maps[i]);
    });
  }

  Future<void> insert(MovieDbEntity entity) async {
    final Database db = await getDb();
    await db.insert(BaseDao.moviesTableName, entity.toJson());
  }

  Future<void> insertAll(List<MovieDbEntity> entities) async {
    final Database db = await getDb();
    await db.transaction((transaction) async {
      for (final entity in entities) {
        transaction.insert(BaseDao.moviesTableName, entity.toJson());
      }
    });
  }

  Future<void> deleteAll() async {
    final Database db = await getDb();
    await db.delete(BaseDao.moviesTableName);
  }
}
