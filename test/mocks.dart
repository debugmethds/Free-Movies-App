import '../lib/data/database/dao/movies_dao.dart';
import '../lib/data/database/database_mapper.dart';
import '../lib/data/datasource/preferences.dart';
import '../lib/data/network/client/api_client.dart';
import '../lib/data/network/network_mapper.dart';
import 'package:mocktail/mocktail.dart';

class ApiClientMock extends Mock implements ApiClient {}

class NetworkMapperMock extends Mock implements NetworkMapper {}

class MoviesDaoMock extends Mock implements MoviesDao {}

class DatabaseMapperMock extends Mock implements DatabaseMapper {}

class PreferencesMock extends Mock implements Preferences {}
