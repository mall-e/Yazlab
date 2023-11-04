import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:yazlab/sqloperations.dart';

class Student with ChangeNotifier {
  String username;
  String password;
  int studentId;
  String ad;
  String soyad;
  String ilgiAlani;
  int anlasmaTalepSayisi;
  bool anlasmaDurumu;
  String notDurumBelgesi;
  String dersBilgileri;
  double genelNotOrtalamasi;

  Student({
    this.username = "",
    this.password = "",
    this.studentId = 0,
    this.ad = "",
    this.soyad = "",
    this.ilgiAlani = "",
    this.anlasmaTalepSayisi = 0,
    this.anlasmaDurumu = false,
    this.notDurumBelgesi = "",
    this.dersBilgileri = "",
    this.genelNotOrtalamasi = 0.0,
  });

  factory Student.fromMap(Map<String, dynamic> data) {
    return Student(
      username: data['username'],
      password: data['password'],
      studentId: data['student_id'],
      ad: data['ad'],
      soyad: data['soyad'],
      ilgiAlani: data['ilgi_alani'],
      anlasmaTalepSayisi: data['anlasma_talep_sayisi'],
      anlasmaDurumu: data['anlasma_durumu'],
      notDurumBelgesi: data['not_durum_belgesi'],
      dersBilgileri: data['ders_bilgileri'],
      genelNotOrtalamasi: (data['genel_not_ortalamasi'] as num).toDouble(),
    );
  }

  Future<void> fetchStudentFromDatabase(String username) async {
    var connection = connect();
    await connection.open();
    try {
      List<List<dynamic>> results = await connection.query(
        'SELECT * FROM ogrenciler WHERE username = @username',
        substitutionValues: {'username': username},
      );

      if (results.isNotEmpty) {
        var row = results.first;
        this.username = row[0] ?? "";
        this.password = row[1] ?? "";
        this.studentId = row[2] ?? 0;
        this.ad = row[3] ?? "";
        this.soyad = row[4] ?? "";
        this.ilgiAlani = row[5] ?? "";
        this.anlasmaTalepSayisi = row[6] ?? 0;
        this.anlasmaDurumu = row[7] ?? false;
        this.notDurumBelgesi = row[8] ?? "";
        this.dersBilgileri = row[9] ?? "";
        this.genelNotOrtalamasi =
            row[10] != null ? (row[10] as num).toDouble() : 0.0;

        notifyListeners();
      } else {
        throw Exception('Öğrenci bulunamadı.');
      }
    } catch (e) {
      print('Veritabanından veri çekilirken hata oluştu: $e');
    } finally {
      await connection.close();
    }
  }

  static Future<Student?> getStudent(int studentId) async {
    final connection = connect();
    await connection.open();
    try {
      final result = await connection.query(
        'SELECT * FROM ogrenciler WHERE student_id = @studentId',
        substitutionValues: {'studentId': studentId},
      );

      if (result.isNotEmpty) {
        final row = result.first;
        final map = {
          'username': row[0],
          'password': row[1],
          'student_id': row[2],
          'ad': row[3],
          'soyad': row[4],
          'ilgi_alani': row[5],
          'anlasma_talep_sayisi': row[6],
          'anlasma_durumu': row[7],
          'not_durum_belgesi': row[8],
          'ders_bilgileri': row[9],
          'genel_not_ortalamasi': row[10],
        };
        return Student.fromMap(map);
      } else {
        return null;
      }
    } catch (e) {
      print('Veritabanından öğrenci çekilirken hata oluştu: $e');
      return null;
    } finally {
      await connection.close();
    }
  }
}
