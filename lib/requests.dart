import 'package:yazlab/sqloperations.dart';

class Request {
  int professor_id;
  int student_id;
  String coursename;
  int status;

  Request({required this.professor_id, required this.student_id, required this.coursename, required this.status});

  static Future<List<Request>> fetchAllRequests() async {
    var conn = connect();

    List<Request> requestsList = [];

    try {
      await conn.open();
      String sql = 'SELECT professor_id, student_id, coursename, status FROM requests';

      List<Map<String, Map<String, dynamic>>> results = await conn.mappedResultsQuery(sql);

      for (final row in results) {
        var request = row['requests']!;

        requestsList.add(Request(
          professor_id: request['professor_id'],
          student_id: request['student_id'],
          coursename: request['coursename'],
          status: request['status'],
        ));
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
    } finally {
      await conn.close();
    }

    return requestsList;
  }

   Future<void> updateStatus(int newStatus) async {
    var conn = connect();

    try {
      await conn.open();

      String sql = '''
        UPDATE requests
        SET status = @newStatus
        WHERE professor_id = @professorId AND student_id = @studentId AND coursename = @courseName;
      ''';

      int updatedRows = await conn.execute(sql, substitutionValues: {
        'newStatus': newStatus,
        'professorId': this.professor_id,
        'studentId': this.student_id,
        'courseName': this.coursename
      });

      if (updatedRows > 0) {
        this.status = newStatus;
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
    } finally {
      await conn.close();
    }
  }

  Future<void> deleteRequest() async {
  var conn = connect();

  try {
    await conn.open();

    String sql = '''
      DELETE FROM requests
      WHERE professor_id = @professorId AND student_id = @studentId AND coursename = @courseName;
    ''';

    int deletedRows = await conn.execute(sql, substitutionValues: {
      'professorId': this.professor_id,
      'studentId': this.student_id,
      'courseName': this.coursename
    });

    if (deletedRows > 0) {
      print('$deletedRows satır başarıyla silindi.');
    } else {
      print('Silinecek kayıt bulunamadı.');
    }
  } catch (e) {
    print('Bir hata oluştu: $e');
  } finally {
    await conn.close();
  }
}


  static Future<void> createRequest(
    int professorId, int studentId, String coursename, int status) async {
  var connection = connect();

  await connection.open();

  await connection.transaction((ctx) async {
    await ctx.query(
        'INSERT INTO requests (professor_id, student_id, coursename, status) VALUES (@a, @b, @c, @d)',
        substitutionValues: {
          'a': professorId,
          'b': studentId,
          'c': coursename,
          'd': status
        });
  });

  await connection.close();
}
}


Future<List<Map<String, dynamic>>> fetchStudentsWithoutAgreement() async {
  var connection = connect();
  await connection.open();
  List<Map<String, dynamic>> students = [];

  try {
    var results = await connection.query(
      'SELECT * FROM ogrenciler WHERE anlasma_durumu = false'
    );
    for (final row in results) {
      students.add(row.toColumnMap());
    }
  } catch (e) {
    print('An error occurred: $e');
  } finally {
    await connection.close();
  }

  return students;
}

