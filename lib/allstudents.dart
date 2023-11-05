import 'package:flutter/material.dart';
import 'package:yazlab/screentemplate.dart';
import 'package:yazlab/student.dart';
import 'package:yazlab/studentdetailpage.dart';
import 'package:yazlab/studentscreen/databesops.dart';

class StudentsPage extends StatelessWidget {

  StudentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Student st = Student();
    return UITemplate(
      page: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Öğrenciler'),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchStudents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState  == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final students = snapshot.data!;
              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  var username = student['username'];
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(student['ad'][0]),
                      ),
                      title: Text('${student['ad']} ${student['soyad']}'),
                      subtitle: Text('Detayları görmek için tıklayın'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        await st.fetchStudentFromDatabase(username).then(
                          (value) => Navigator.push(context, MaterialPageRoute(builder: (context) => StudentDetailsPage(student: st))));

                      },
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('Veri bulunamadı.'));
            }
          },
        ),
      ),
    );
  }
}
