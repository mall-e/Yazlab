import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazlab/chatscreen.dart';
import 'package:yazlab/professor.dart';
import 'package:yazlab/requests.dart';
import 'package:yazlab/sqloperations.dart';
import 'package:yazlab/student.dart';

class Course {
  final int id;
  final String name;
  final int credit;
  final List<String> professors;

  Course(
      {required this.id,
      required this.name,
      required this.credit,
      required this.professors});

  // Veritabanından gelen veriyi kullanarak bir Course nesnesi oluşturmak için factory constructor.
  factory Course.fromMap(Map<String, dynamic> data) {
    return Course(
      id: data['ders_id'],
      name: data['ders_isim'],
      credit: data['ders_kredi'],
      professors: List<String>.from(data['hocalar']),
    );
  }
}

Future<List<Course>> fetchCourses() async {
  var connection = connect();

  await connection.open();
  List<List<dynamic>> results = await connection
      .query('SELECT ders_id, ders_isim, ders_kredi, hocalar FROM aders');

  // Dönüşümleri gerçekleştirerek Course listesini oluşturun.
  List<Course> courses = results.map((row) {
    var hocalarListesi = row[3] != null
        ? List<String>.from((row[3] as List).map((item) => item.toString()))
        : <String>[];

    return Course(
      id: row[0] as int,
      name: row[1] as String,
      credit: row[2] as int,
      professors: hocalarListesi,
    );
  }).toList();

  await connection.close();

  return courses;
}

class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  Course? selectedCourse;
  String? selectedProfessor;
  int? selectedProfessorId;

  @override
  Widget build(BuildContext context) {
    final student = Provider.of<Student>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Ders ve Hoca Seçimi'),
      ),
      floatingActionButton: selectedProfessor != null
          ? FloatingActionButton(
              onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(student_id: selectedProfessorId!, sender: 1,)));},
              child: Icon(Icons.message),
              tooltip: 'Hoca ile Chat',
            )
          : null, // Hoca seçilmemişse FAB görünmez
      body: FutureBuilder<List<Course>>(
        future: fetchCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Ders bilgisi bulunamadı.'));
          }

          List<Course> courses = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    Course course = courses[index];
                    return ListTile(
                      title: Text(course.name),
                      subtitle: Text('Kredi: ${course.credit}'),
                      onTap: () => setState(() {
                        selectedCourse = course;
                        selectedProfessor = null;
                      }),
                    );
                  },
                ),
              ),
              if (selectedCourse != null) ...[
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Hocalar: ${selectedCourse!.name}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0 ,bottom: 30.0),
                  child: Wrap(
                    spacing: 8.0,
                    children: selectedCourse!.professors.map((professor) {
                      return ChoiceChip(
                        label: Text(professor),
                        selected: selectedProfessor == professor,
                        onSelected: (selected) {
                          if (selected) {
                            print(professor);
                            getProfessorByName(professor).then((prof) {
                              print(prof!.id.toString() + "zort");
                              if (prof != null) {
                                Request.createRequest(prof.id, student.studentId,
                                        selectedCourse!.name, 0)
                                    .then((_) {
                                  // Future tamamlandığında ve veriler alındığında setState ile widget'ı güncelleyin.
                                  setState(() {
                                    selectedProfessor = professor;
                                    selectedProfessorId = prof.id;
                                  });
                                });
                              }
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
              if (selectedProfessor != null) ...[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Talep gönderilen hoca: $selectedProfessor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
