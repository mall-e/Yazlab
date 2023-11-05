import 'package:yazlab/sqloperations.dart';
import 'package:yazlab/transciprtrow.dart';



Future<void> insertTranscriptRows(List<TranscriptRow> rows) async {
  var connection = connect();

  await connection.open();

  try {
    await connection.transaction((ctx) async {
      for (var row in rows) {
        await ctx.query('''
          INSERT INTO courses (kod, isim, status, dil, t, u, uk, akts)
          VALUES (@kod, @isim, @status, @dil, @t, @u, @uk, @akts)
        ''', substitutionValues: {
          'kod': row.kod,
          'isim': row.isim,
          'status': row.status,
          'dil': row.dil,
          't': row.t,
          'u': row.u,
          'uk': row.uk,
          'akts': row.akts,
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

Future<void> updateProfessorInterest(int professorId, String newInterest) async {
  var connection = connect();

  try {
    await connection.open();
    await connection.query(
      'UPDATE hoca SET interests = @newInterest WHERE professor_id = @id',
      substitutionValues: {
        'newInterest': newInterest,
        'id': professorId,
      },
    );

    print('Güncelleme başarılı.');
  } catch (e) {
    print('Veritabanı işlemi sırasında bir hata oluştu: $e');
  } finally {
    await connection.close();
  }
}


  Future<List<Map<String, dynamic>>> fetchStudents() async {
    var connection = connect();
    await connection.open();
    List<Map<String, Map<String, dynamic>>> results = await connection.mappedResultsQuery(
      'SELECT ad, soyad, username FROM ogrenciler;',
    );
    await connection.close();

    return results.map((row) => row['ogrenciler']!).toList();
  }
