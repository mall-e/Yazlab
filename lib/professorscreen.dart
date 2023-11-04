import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:provider/provider.dart';
import 'package:yazlab/chatscreen.dart';
import 'package:yazlab/professor.dart';
import 'package:yazlab/requests.dart';
import 'package:yazlab/screentemplate.dart';
import 'package:yazlab/sqloperations.dart';

class ProfessorScreen extends StatefulWidget {
  final String loginType;
  final String username;

  const ProfessorScreen({Key? key, required this.loginType, required this.username}) : super(key: key);

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
        )
      ],
      pages: {
        0: InterestPage(),
        1: RequestsPage(widget.username),
        2: InterestPage(),
      },
    );
  }
}

class InterestPage extends StatelessWidget {
  const InterestPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    TextEditingController interestcontroller = TextEditingController();
    return UITemplate(
        page: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("İlgi alanınızı giriniz"),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: interestcontroller,
                  decoration: InputDecoration(),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  var connection = await connect();
                  try {
                    await connection.query(
                      'UPDATE hoca SET interests = @interest WHERE professor_id = @idValue',
                      substitutionValues: {
                        'interest': interestcontroller.text,
                        'idValue': 1,
                      },
                    );
                    print('Veri başarıyla eklendi');
                  } catch (e) {
                    print('Veri eklenirken hata oluştu: $e');
                  } finally {
                    await connection.close();
                  }
                },
                child: Text("Ekle"),
              )
            ],
          ),
        ),
      ],
    ));
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
                RequestFormPage(),
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

  @override
  void initState() {
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
      future: Request.fetchAllRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        return ListView.builder(
          itemCount: professorRequestsId.length,
          itemBuilder: (context, index) {
            var request = snapshot.data![index];
            final student = students[index];
            final professor = Provider.of<Professor>(context, listen: false);
            if (professorRequestsId[index] !=  professor.id.toString() ) {
              return SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.all(6.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                color: request.status == 0 ? Colors.white: Colors.green,
                  boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Gölgenin rengi
                    spreadRadius: 5, // Gölgenin yayılma yarıçapı
                    blurRadius: 7, // Gölgenin bulanıklık yarıçapı
                    offset: Offset(0, 3), // Gölgenin yatay ve dikey pozisyonu
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
                          ElevatedButton(onPressed: ()async{await request.updateStatus(0); setState(() {

                          });}, child: Icon(Icons.close, size: 18.0,)),
                          SizedBox(width: 10.0,),
                          ElevatedButton(onPressed: ()async{await request.updateStatus(1); setState(() {

                          });}, child: Icon(Icons.check, size: 18.0,)),
                          SizedBox(width: 10.0,),
                          ElevatedButton(onPressed: (){showDialog(context: context, builder: ((context) => ChatScreen(student_id: int.parse(studentRequests[index]))));}, child: Icon(Icons.message, size: 18.0,)),
                        ],
                      )
                    ],
                  ), // 'name' sütun isminizi buraya yazın
                ),
              ),
            );
          },
        );
      }
    );
  }
}


class RequestFormPage extends StatefulWidget {
  @override
  _RequestFormPageState createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  final TextEditingController requestController = TextEditingController();

  void _submitRequest() async {
    String requestText = requestController.text;
    if (requestText.isNotEmpty) {
      // Talebi gönderme kodu buraya ekleyin (PostgreSQL veya başka bir veritabanına).
      // Örnek: await sendRequestToPostgreSQL(requestText);
      requestController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: requestController,
            decoration: InputDecoration(labelText: 'Talebinizi yazın'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitRequest,
            child: Text('Talep Gönder'),
          ),
        ],
      ),
    );
  }
}
