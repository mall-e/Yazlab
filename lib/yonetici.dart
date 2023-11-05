import 'dart:math';
import 'package:flutter/material.dart';
import 'package:googleapis/vision/v1.dart';
import 'package:postgres/postgres.dart';
import 'package:yazlab/screentemplate.dart';
import 'package:yazlab/sqloperations.dart';

class YoneticiScreen extends StatefulWidget {
  const YoneticiScreen({Key? key}) : super(key: key);

  @override
  _YoneticiScreenState createState() => _YoneticiScreenState();
}

class _YoneticiScreenState extends State<YoneticiScreen> {
  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      buttons: [
        Icon(
          Icons.home,
          color: Colors.white,
        ),
        Icon(
          Icons.search,
          color: Colors.white,
        ),
        Icon(
          Icons.settings,
          color: Colors.white,
        ),

      ],
       pages: {

         0: MyApp(),
         1: MyApp(),
         2: MyApp(),
       },
    );
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RandomStudentGenerator(),
    );
  }
}

class RandomStudentGenerator extends StatefulWidget {
  @override
  _RandomStudentGeneratorState createState() => _RandomStudentGeneratorState();
}

class _RandomStudentGeneratorState extends State<RandomStudentGenerator> {
  int studentCount = 0;
  List<String> studentNames = [
    'Alparslan',
    'Kagan',
    'Muhammet',
    'Irfancan',
    'Efe',
    'Gurkan',
    'Irem',
    'Melisa',
    'Ayse',
    'Aslı',
    'Gonul',
    'Jale',
  ];
  List<String> studentSurnames = [
    'Culfa',
    'Kocman',
    'Yazici',
    'Yilmaz',
    'Durucan',
    'Yildiz',
    'Kahveci',
    'Guler',
    'Gok',
    'Yuksek',
    'Sahan',
    'Under',
  ];

  Random _random = Random();
  List<String> generatedStudents = [];

  int generateRandomNumericGrade() {
    return _random.nextInt(101);
  }

  String calculateLetterGrade(int numericGrade) {
    if (numericGrade >= 90) {
      return 'AA';
    } else if (numericGrade >= 80) {
      return 'BA';
    } else if (numericGrade >= 70) {
      return 'BB';
    } else if (numericGrade >= 60) {
      return 'CB';
    } else if (numericGrade >= 50) {
      return 'CC';
    } else if (numericGrade >= 40) {
      return 'DC';
    } else if (numericGrade >= 30) {
      return 'DD';
    } else {
      return 'FF';
    }
  }

  String generateRandomInterest() {
    final interests = ['Web programlama', 'Mobil', 'Arayüz', 'Yapay zeka'];
    return interests[_random.nextInt(interests.length)];
  }

double generateRandomAGNO() {

    return _random.nextDouble() * 4.0;
  }

  Future<void> generateStudentsInDatabase() async {
    final connection = connect();

    await connection.open();

    for (int i = 0; i < studentCount; i++) {
      final randomName = studentNames[_random.nextInt(studentNames.length)];
      final randomSurname = studentSurnames[_random.nextInt(studentSurnames.length)];
      final randomNumericGrade = generateRandomNumericGrade();
      final randomAGNO = generateRandomAGNO().toStringAsFixed(2); // AGNO'yu 2
      final randomGrade = calculateLetterGrade(randomNumericGrade);
      final randomInterest = generateRandomInterest();

      await connection.query(
        'INSERT INTO yoneticistudent (student_id, student_name_surname, student_notes, student_grade, student_ilgi, course_credits) VALUES (@studentId, @nameSurname, @notes, @grade, @interest, @course_credits)',
        substitutionValues: {
          'studentId': i + 1,
          'nameSurname': '$randomName $randomSurname',
          'notes': randomNumericGrade,
          'grade': randomGrade,
          'interest': randomInterest,
          'course_credits': randomAGNO,
        },
      );
    }

    await connection.close();
  }

  Future<void> clearStudentsFromDatabase() async {
    final connection = connect();

    await connection.open();

    await connection.query('DELETE FROM yoneticistudent');

    await connection.close();

    setState(() {
      generatedStudents.clear();
    });
  }

  void generateStudents() async {
    generatedStudents.clear();
    for (int i = 0; i < studentCount; i++) {
      final randomName = studentNames[_random.nextInt(studentNames.length)];
      final randomSurname = studentSurnames[_random.nextInt(studentSurnames.length)];
      final randomNumericGrade = generateRandomNumericGrade();
      final randomGrade = calculateLetterGrade(randomNumericGrade);
      final randomInterest = generateRandomInterest();
      final randomAgno = generateRandomAGNO();
      generatedStudents.add('$randomName $randomSurname|$randomNumericGrade|$randomGrade|$randomInterest|$randomAgno');
    }
    await generateStudentsInDatabase();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return UITemplate(
      page: Scaffold(
        appBar: AppBar(
          title: Text('Rastgele Öğrenci Atama'),
        ),
        body: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Kişi Sayısı'),
                      content: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          studentCount = int.tryParse(value) ?? 0;
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            generateStudents();
                            Navigator.of(context).pop();
                          },
                          child: Text('Tamam'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Kişi Sayısını Belirle'),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Öğrencileri Temizle'),
                      content: Text('Tüm öğrenci kayıtlarını silmek istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            clearStudentsFromDatabase();
                            Navigator.of(context).pop();
                          },
                          child: Text('Evet'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Hayır'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Öğrencileri Temizle'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: generatedStudents.isNotEmpty
                  ? ListView(
                      children: generatedStudents
                          .map((student) {
                            final studentData = student.split('|');
                            return Card(
                              child: ListTile(
                                title: Text(studentData[0]),
                                subtitle: Column(
                                  children: [
                                    Text('Notlar: ${studentData[1]}'),
                                    Text('Harf Notu: ${studentData[2]}'),
                                    Text('İlgi Alanı: ${studentData[3]}'),
                                    Text('AGNO: ${studentData[4]}'),
                                  ],
                                ),
                              ),
                            );
                          })
                          .toList(),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
