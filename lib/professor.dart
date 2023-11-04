import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:yazlab/sqloperations.dart';

class Professor with ChangeNotifier {
  int id;
  String username;
  String pass;
  String name;
  String surname;
  String interest;
  int quota;
  List<String> ocourses;
  List<String> critcourses;

  Professor({
    this.id = 0,
    this.username = "",
    this.pass = "",
    this.name = "",
    this.surname = "",
    this.interest = "",
    this.quota = 0,
    List<String>? ocourses,
    List<String>? critcourses,
  })  : ocourses = ocourses ?? [],
        critcourses = critcourses ?? [];

  Future<void> fetchFromDatabase(String username) async {
    var connection = connect();
    try {
      await connection.open();
      List<List<dynamic>> results = await connection.query(
        'SELECT * FROM hoca WHERE username = @username',
        substitutionValues: {'username': username},
      );

      if (results.isNotEmpty) {
        var row = results.first;
        this.id = row[0] ?? 0;
        this.name = row[1] ?? "null";
        this.surname = row[2] ?? "null";
        this.username = row[3] ?? "null";
        this.pass = row[4] ?? "null";
        this.interest = row[5] ?? "null";
        this.quota = row[6] ?? 0;
        this.ocourses = row[7] != null ? (row[7] as List).cast<String>() : [];
        this.critcourses =
            row[8] != null ? (row[8] as List).cast<String>() : [];

        // Değişiklikleri dinleyen widget'lara bildir
        notifyListeners();
      }
    } catch (e) {
      print('Veritabanından veri çekilirken hata oluştu: $e');
    } finally {
      await connection.close();
    }
    notifyListeners(); // Durumu güncelledikten sonra bu metod çağırılmalıdır.
  }

    factory Professor.fromMap(Map<String, dynamic> map) {
    return Professor(
      id: map['id'],
      username: map['username'],
      pass: map['username'],
      name: map['name'],
      surname: map['username'],
      interest: map['username'],
      quota: map['username'],
      ocourses: map['ocourses'],
      critcourses: map['critcourses'],
    );
  }
}

Future<Professor?> getProfessor(int id) async {
  final connection = connect();

  await connection.open();

  final result = await connection.query(
    'SELECT * FROM hoca WHERE id = @id',
    substitutionValues: {
      'id': id,
    },
  );

  await connection.close();

  if (result.isNotEmpty) {
    final row = result.first;
    final map = {
      'id' : row[0],
      'username': row[1],
      'pass': row[2],
      'name': row[3],
      'surname': row[4],
      'interest': row[5],
      'quota': row[6],
      'ocourses': row[7],
      'critcourses': row[8],
    };
    return Professor.fromMap(map);
  } else {
    return null;
  }
}
