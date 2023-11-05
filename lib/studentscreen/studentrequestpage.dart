import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:yazlab/sqloperations.dart';

class StudentRequestsPage extends StatefulWidget {
  final int studentId;

  const StudentRequestsPage({Key? key, required this.studentId}) : super(key: key);

  @override
  _StudentRequestsPageState createState() => _StudentRequestsPageState();
}

class _StudentRequestsPageState extends State<StudentRequestsPage> {
  List<Map<String, dynamic>> requests = [];
  late PostgreSQLConnection db;

  @override
  void initState() {
    super.initState();
    _connectToDb();
  }

  Future<void> _connectToDb() async {
    db = connect();
    await db.open();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
  final results = await db.query(
    'SELECT * FROM requests WHERE student_id = @studentId AND status = 0',
    substitutionValues: {'studentId': widget.studentId}
  );

  setState(() {
    requests = results.map((row) {
      // Burada her bir sütunu ve karşılık gelen değerleri bir Map olarak oluşturuyoruz.
      return {
        'professor_id': row[0],
        'student_id': row[1],
        'coursename': row[2],
        'status': row[3]
      };
    }).toList();
  });
}

  Future<void> _approveRequest(int professorId, String courseName) async {
    await db.transaction((ctx) async {
      await ctx.query(
        'UPDATE requests SET status = 1 WHERE professor_id = @professorId AND student_id = @studentId AND coursename = @courseName',
        substitutionValues: {
          'professorId': professorId,
          'studentId': widget.studentId,
          'courseName': courseName
        }
      );

      await ctx.query(
        'UPDATE ogrenciler SET anlasma_durumu = true WHERE student_id = @studentId',
        substitutionValues: {'studentId': widget.studentId}
      );
    });

    _fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ApprovedRequestsPage(studentId: widget.studentId)));}, icon: Icon(Icons.check))
        ],
        title: Text('Talepler'),
      ),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return ListTile(
            title: Text(request['coursename'] as String),
            subtitle: Text('Profesör ID: ${request['professor_id']}'),
            trailing: ElevatedButton(
              onPressed: () => _approveRequest(request['professor_id'] as int, request['coursename'] as String),
              child: Text('Onayla'),
            ),
          );
        },
      ),
    );
  }
}

class ApprovedRequestsPage extends StatefulWidget {
  final int studentId;

  ApprovedRequestsPage({required this.studentId});

  @override
  _ApprovedRequestsPageState createState() => _ApprovedRequestsPageState();
}

class _ApprovedRequestsPageState extends State<ApprovedRequestsPage> {
  List<Map<String, dynamic>> approvedRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchApprovedRequests();
  }

  Future<void> _fetchApprovedRequests() async {
    var db = connect();
    await db.open();
    final results = await db.query(
      'SELECT * FROM requests WHERE student_id = @studentId AND status = 1',
      substitutionValues: {'studentId': widget.studentId}
    );

    setState(() {
      approvedRequests = results.map((row) {
      return {
        'professor_id': row[0],
        'student_id': row[1],
        'coursename': row[2],
        'status': row[3],
      };
    }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onaylanmış Talepler'),
      ),
      body: ListView.builder(
        itemCount: approvedRequests.length,
        itemBuilder: (context, index) {
          final request = approvedRequests[index];
          return ListTile(
            title: Text(request['coursename'] as String),
            subtitle: Text('Profesör ID: ${request['professor_id']}'),
          );
        },
      ),
    );
  }
}

