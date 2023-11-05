import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:yazlab/sqloperations.dart';

class Professor with ChangeNotifier {
  int id;
  String username;
  String password;
  String name;
  String surname;
  String interest;
  int quota;
  List<String> ocourses;
  List<String> critcourses;
  List<String> courses;

  Professor({
    this.id = 0,
    this.username = "",
    this.password = "",
    this.name = "",
    this.surname = "",
    this.interest = "",
    this.quota = 0,
    List<String>? ocourses,
    List<String>? critcourses,
    List<String>? courses,
  })  : ocourses = ocourses ?? [],
        critcourses = critcourses ?? [],
        courses = courses ?? [];

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
        this.password = row[4] ?? "null";
        this.interest = row[5] ?? "null";
        this.quota = row[6] ?? 0;
        this.ocourses = row[7] != null ? (row[7] as List).cast<String>() : [];
        this.critcourses =
            row[8] != null ? (row[8] as List).cast<String>() : [];
        this.courses =
            row[9] != null ? (row[9] as List).cast<String>() : [];

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
      password: map['password'],
      name: map['name'],
      surname: map['surname'] ?? "",
      interest: map['interest'] ?? "",
      quota: map['quota'] ?? 0,
      ocourses: map['ocourses'] ?? [],
      critcourses: map['critcourses'] ?? [],
      courses: map['courses'] ?? [],
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
      'password': row[2],
      'name': row[3],
      'surname': row[4],
      'interest': row[5],
      'quota': row[6],
      'ocourses': row[7],
      'critcourses': row[8],
      'courses' : row[9],
    };
    return Professor.fromMap(map);
  } else {
    return null;
  }
}

Future<Professor?> getProfessorByName(String name) async {
  final connection = connect();

  await connection.open();

  final result = await connection.query(
    'SELECT * FROM hoca WHERE first_name = @first_name',
    substitutionValues: {
      'first_name': name,
    },
  );

  await connection.close();

  if (result.isNotEmpty) {
    final row = result.first;
    final map = {
      'id' : row[0],
      'name': row[1],
      'surname': row[2],
      'username': row[3],
      'password': row[4],
      'interest': row[5],
      'quota': row[6],
      'ocourses': row[7],
      'critcourses': row[8],
      'courses' : row[9],
    };
    return Professor.fromMap(map);
  } else {
    return null;
  }
}
