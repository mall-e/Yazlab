import 'package:yazlab/sqloperations.dart';
import 'package:yazlab/student.dart';
import 'package:yazlab/transciprtrow.dart';



Future<void> insertTranscriptRows(List<TranscriptRow> rows) async {
  var connection = connect();

  await connection.open();

  try {
    await connection.transaction((ctx) async {
      for (var row in rows) {
        await ctx.query('''
          INSERT INTO courses (kod, isim, status, dil, t, u, uk, akts, puan)
          VALUES (@kod, @isim, @status, @dil, @t, @u, @uk, @akts, @puan)
        ''', substitutionValues: {
          'kod': row.kod,
          'isim': row.isim,
          'status': row.status,
          'dil': row.dil,
          't': row.t,
          'u': row.u,
          'uk': row.uk,
          'akts': row.akts,
          'puan': row.puan,
        });
      }
    });
  } catch (e) {
    print('An error occurred while inserting rows: $e');
    rethrow; // Hata bilgisini üst katmana aktarmak için
  } finally {
    await connection.close();
  }
}

void resetTable() async {
  var connection = connect();

  await connection.open();
  try {
    connection.query("TRUNCATE TABLE courses");
  } catch (e) {
    print('An error occurred while inserting rows: $e');
  }
}
