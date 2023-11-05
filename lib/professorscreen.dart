import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:provider/provider.dart';
import 'package:yazlab/allstudents.dart';
import 'package:yazlab/chatscreen.dart';
import 'package:yazlab/professor.dart';
import 'package:yazlab/requests.dart';
import 'package:yazlab/screentemplate.dart';
import 'package:yazlab/sqloperations.dart';
import 'package:yazlab/studentscreen/databesops.dart';

class ProfessorScreen extends StatefulWidget {
  final String loginType;
  final String username;

  const ProfessorScreen(
      {Key? key, required this.loginType, required this.username})
      : super(key: key);

  @override
  _ProfessorScreenState createState() => _ProfessorScreenState();
}

class _ProfessorScreenState extends State<ProfessorScreen> {
  @override
  Widget build(BuildContext context) {
    final professor = Provider.of<Professor>(context, listen: false);
    professor.fetchFromDatabase(widget.username);
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
        Icon(
          Icons.settings,
          color: Colors.white,
        )
      ],
      pages: {
        0: InterestPage(
          professor: professor,
        ),
        1: RequestsPage(widget.username),
        2: StudentsPage(),
        3: MyApppp(),
      },
    );
  }
}

class InterestPage extends StatefulWidget {
  final Professor professor;

  const InterestPage({Key? key, required this.professor}) : super(key: key);

  @override
  _InterestPageState createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  TextEditingController interestController = TextEditingController();
  List<String> interestOptions = [
    "Web programlama",
    "Mobil",
    "Arayüz",
    "Yapay zeka"
  ];
  String selectedInterest =
      "Web programlama"; // Başlangıçta bir varsayılan ilgi alanı seçeneği

  // PostgreSQL veritabanı bağlantısı için gerekli bilgiler

  late PostgreSQLConnection connection;

  @override
  void initState() {
    super.initState();
    connection = connect();
    connection.open();
  }

  @override
  void dispose() {
    connection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UITemplate(
      page: Scaffold(
        appBar: AppBar(
          title: Text('İlgi Alanı Ekle'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("İlgi alanınızı seçiniz"),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    DropdownButtonFormField(
                      value: selectedInterest,
                      items: interestOptions.map((String interest) {
                        return DropdownMenuItem(
                          value: interest,
                          child: Text(interest),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedInterest = newValue!;
                        });
                      },
                      decoration: InputDecoration(labelText: "İlgi Alanınız"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedInterest.isNotEmpty) {
                          try {
                            updateProfessorInterest(
                                widget.professor.id, selectedInterest);
                            print('Veri başarıyla eklendi');
                          } catch (e) {
                            print('Veri eklenirken hata oluştu: $e');
                          }
                        } else {
                          print('Lütfen bir ilgi alanı seçin.');
                        }
                      },
                      child: Text("Ekle"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RequestsPage extends StatelessWidget {
  final String username;
  RequestsPage(this.username);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Öğrenci Talep Uygulaması',
      debugShowCheckedModeBanner: false,
      home: UITemplate(
        page: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Öğrenci Talepleri'),
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Talepleri Görüntüle'),
                  Tab(text: 'Talep Gönder'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                StudentRequestList(username),
                StudentAgreementScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudentRequestList extends StatefulWidget {
  final String username;

  StudentRequestList(this.username);
  @override
  _StudentRequestListState createState() => _StudentRequestListState();
}

class _StudentRequestListState extends State<StudentRequestList> {
  List<String> studentRequests = [];
  List<String> studentCourseRequests = [];
  List<String> professorRequestsId = [];
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> professors = [];
  bool isLoading = true;
  final connection = connect();
  Future<List<Request>>? futureRequestList;

  @override
  void initState() {
    futureRequestList = Request.fetchAllRequests();
    super.initState();
    init();
  }

  Future<void> init() async {
    await connection.open();
    await fetchStudentRequests();
    await fetchStudents();
    setState(() {
      isLoading = false;
    });
    await connection.close();
  }

  Future<void> fetchStudentRequests() async {
    final result = await connection.query('SELECT * FROM requests');

    setState(() {
      professorRequestsId = result.map((row) => row[0].toString()).toList();
      studentRequests = result.map((row) => row[1].toString()).toList();
      studentCourseRequests = result.map((row) => row[2].toString()).toList();
    });
  }

  Future<void> fetchStudents() async {
    for (String studentId in studentRequests) {
      final result = await connection.query(
        'SELECT * FROM ogrenciler WHERE student_id = @student_id',
        substitutionValues: {
          'student_id': studentId,
        },
      );

      if (result.isNotEmpty) {
        students.add(result.first.toColumnMap());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CircularProgressIndicator();
    }

    return FutureBuilder<List<Request>>(
        future: futureRequestList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var request = snapshot.data![index];
              final student = students[index];
              final professor = Provider.of<Professor>(context, listen: false);
              if (professorRequestsId[index] != professor.id.toString()) {
                return SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: request.status == 0 ? Colors.white : Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Gölgenin rengi
                        spreadRadius: 5, // Gölgenin yayılma yarıçapı
                        blurRadius: 7, // Gölgenin bulanıklık yarıçapı
                        offset:
                            Offset(0, 3), // Gölgenin yatay ve dikey pozisyonu
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(student['username']),
                        Text(studentCourseRequests[index]),
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  await request.deleteRequest();
                                  setState(() {
                                    futureRequestList =
                                        Request.fetchAllRequests();
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 18.0,
                                )),
                            SizedBox(
                              width: 10.0,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  await request.updateStatus(1);
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.check,
                                  size: 18.0,
                                )),
                            SizedBox(
                              width: 10.0,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: ((context) => ChatScreen(
                                            student_id: int.parse(
                                                studentRequests[index]),
                                            sender: 0,
                                          )));
                                },
                                child: Icon(
                                  Icons.message,
                                  size: 18.0,
                                )),
                          ],
                        )
                      ],
                    ), // 'name' sütun isminizi buraya yazın
                  ),
                ),
              );
            },
          );
        });
  }
}

class StudentAgreementScreen extends StatefulWidget {
  @override
  _StudentAgreementScreenState createState() => _StudentAgreementScreenState();
}

class _StudentAgreementScreenState extends State<StudentAgreementScreen> {
  late Future<List<Map<String, dynamic>>> futureStudents;
  String? selectedCourse; // Seçilen kursu tutmak için değişken

  @override
  void initState() {
    super.initState();
    final professor = Provider.of<Professor>(context, listen: false);
    futureStudents = initializeScreen();
    if (professor.courses.isNotEmpty) {
      selectedCourse = professor.courses.first;
    }
  }

  Future<List<Map<String, dynamic>>> initializeScreen() async {
    await addCoursesToProfessors();
    return fetchStudentsWithoutAgreement();
  }

  @override
  Widget build(BuildContext context) {
    final professor = Provider.of<Professor>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[100],
        foregroundColor: Colors.black,
        title: Text('Anlaşma Yapılmamış Öğrenciler'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureStudents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('Anlaşma yapılmamış öğrenci yok.');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var student = snapshot.data![index];
                return ListTile(
                  title: Text(student['ad'] + ' ' + student['soyad']),
                  subtitle: Text(student['ilgi_alani'] ?? " "),
                  trailing: Wrap(
                    spacing: 12,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          showDialog(context: context,
                          builder: (BuildContext context) {
                            return popupscreen(professor, student);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<String>> getCoursesFromDatabase(int professorId) async {
  var connection = connect();

  await connection.open();

  List<List<dynamic>> results = await connection.query(
    'SELECT courses FROM hoca WHERE professor_id = @professorId',
    substitutionValues: {
      'professorId': professorId
    }
  );

  await connection.close();

  if (results.isEmpty || results.first.isEmpty) {
    return [];
  }

  var coursesArray = results.first.first as List<dynamic>;
  List<String> courses = coursesArray.map((c) => c as String).toList();

  return courses;
}

  Widget popupscreen(Professor professor, Map<String, dynamic> student) {
  return AlertDialog(
    content: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      child: FutureBuilder<List<String>>(
        future: getCoursesFromDatabase(professor.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error.toString()}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Kurs bulunamadı.'));
          }

          var courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return InkWell(
                child: ListTile(
                  title: Text(courses[index]),
                ),
                onTap: () {
                  Request.createRequest(
                          professor.id,
                          student['student_id'],
                          courses[index],
                          0,
                        ).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Talep oluşturuldu.'),
                            ),
                          );
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Talep oluşturulamadı: $error'),
                            ),
                          );
                        });
                },
              );
            },
          );
        },
      ),
    ),
  );
}
}

class Stu {
  final String courseName;
  final int note;
  final String studentName;
  final String studentSurname;
  final int studentId;

  Stu({
    required this.courseName,
    required this.note,
    required this.studentName,
    required this.studentSurname,
    required this.studentId,
  });
}

class MyApppp extends StatefulWidget {
  @override
  _MyAppppState createState() => _MyAppppState();
}

class _MyAppppState extends State<MyApppp> {
  final List<Stu> students = [];
  final List<String> courseNames = [];

  String selectedCourse = '';

  Future<void> fetchStudentsFromDatabase() async {
    final connection = connect();

    await connection.open();

    final results = await connection.query('SELECT DISTINCT courses_name FROM student_courses');
    courseNames.clear();
    courseNames.addAll(results.map((row) => row[0] as String).toList());

    await connection.close();


    setState(() {
      if (courseNames.isNotEmpty) {
        selectedCourse = courseNames[0];
      }
    });


    fetchStudentsForCourse(selectedCourse);
  }

  Future<void> fetchStudentsForCourse(String courseName) async {
    final connection = connect();

    await connection.open();

    final results = await connection.query('''
      SELECT  student_courses.note, student_courses.course_student_name,
      student_courses.course_student_surname, student_courses.course_student_id
      FROM student_courses
      WHERE student_courses.courses_name = @courseName
    ''', substitutionValues: {
      'courseName': courseName,
    });

    students.clear();
    students.addAll(
      results.map((row) => Stu(
        note: row[0] as int,
        courseName: courseName,
        studentName: row[1] as String,
        studentSurname: row[2] as String,
        studentId: row[3] as int,
      )).toList(),
    );

    await connection.close();

    setState(() {});
  }

  void sortStudentsByGrade() {
    setState(() {
      students.sort((a, b) => b.note.compareTo(a.note));
    });
  }

  void sortStudentsByName() {
    setState(() {
      students.sort((a, b) => '${a.studentName} ${a.studentSurname}'.compareTo('${b.studentName} ${b.studentSurname}'));
    });
  }

  @override
  void initState() {
    super.initState();
    fetchStudentsFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Öğrenci Listesi'),
        ),
        body: Column(
          children: [

            Wrap(
              spacing: 8,
              children: courseNames.map((course) {
                return ElevatedButton(
                  onPressed: () {

                    setState(() {
                      selectedCourse = course;
                    });
                    fetchStudentsForCourse(course);
                  },
                  child: Text(course),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: sortStudentsByGrade,
              child: Text('Not Sıralama'),
            ),
            ElevatedButton(
              onPressed: sortStudentsByName,
              child: Text('İsim Sıralama'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      'Ders Adı: ${students[index].courseName}',
                    ),
                    subtitle: Text(
                      'Öğrenci Adı: ${students[index].studentName} ${students[index].studentSurname} - Öğrenci ID: ${students[index].studentId} - Not: ${students[index].note}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


