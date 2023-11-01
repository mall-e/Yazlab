import 'package:postgres/postgres.dart';

Future<bool> checkCredentials(String username, String password, String table) async {
  var connection = PostgreSQLConnection(
    'localhost', // Sunucu adresi
    5432,        // Port numarası
    'yazlab',    // Veritabanı adı
    username: 'postgres', // PostgreSQL kullanıcı adı
    password: 'password', // PostgreSQL şifresi
  );

  await connection.open();

  List<Map<String, Map<String, dynamic>>> results = await connection.mappedResultsQuery(
    'SELECT username, password FROM $table WHERE username = @u AND password = @p',
    substitutionValues: {
      'u': username,
      'p': password,
    }
  );

  await connection.close();

  if (results.isNotEmpty) {
    return true;
  } else {
    return false;
  }
}

Future<PostgreSQLConnection> connect() async {
    var connection = PostgreSQLConnection(
      'localhost',
      5432,
      'yazlab',
      username: 'postgres',
      password: 'password',
    );
    await connection.open();
    return connection;
}
