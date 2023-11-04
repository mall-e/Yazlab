import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazlab/classification.dart';
import 'package:yazlab/screentemplate.dart';
import 'package:yazlab/student.dart';
import 'package:yazlab/studentscreen/firstpage.dart';
import 'package:yazlab/studentscreen/secondpage.dart';
import 'package:yazlab/studentscreen/thirdpage.dart';
import 'package:yazlab/transciprtrow.dart';

class StudentScreen extends StatefulWidget {
  final String loginType;
  final String username;

  const StudentScreen({Key? key, required this.loginType, required this.username}) : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class PageModel with ChangeNotifier {
  Widget _page = Center(
    child: CircularProgressIndicator(),
  );

  Widget get page => _page;

  set page(Widget newPage) {
    _page = newPage;
    notifyListeners();
  }
}


class _StudentScreenState extends State<StudentScreen> {
  late TranscriptRow row;
  PageModel page = PageModel();
  String ocrResult = "";


  @override
  void initState() {
    page.page = FirstPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  final student = Provider.of<Student>(context, listen: false);
  student.fetchStudentFromDatabase(widget.username);
    return ChangeNotifierProvider(
      create: ((context) => PageModel()),
      child: const ScreenTemplate(buttons: [
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
      ], pages: {
        0: FirstPage(),
        1: SecondPage(),
        2: ThirdPage(),
      }),
    );
  }
}

class DataTableScreen extends StatefulWidget {
  final String ocrResult;

  const DataTableScreen({Key? key, this.ocrResult = ""}) : super(key: key);

  @override
  _DataTableScreenState createState() => _DataTableScreenState();
}

class _DataTableScreenState extends State<DataTableScreen> {
  Classification values = Classification();

  @override
  Widget build(BuildContext context) {
    values.fillValues(widget.ocrResult);
    return Container(
      alignment: Alignment.center,
      child: DataTable(
        columns: [
          DataColumn(label: Text("UK")),
          DataColumn(label: Text("AKTS")),
          DataColumn(label: Text("Not")),
          DataColumn(label: Text("Puan")),
          DataColumn(label: Text("Açıklama"))
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text(values.uk)),
            DataCell(Text(values.akts)),
            DataCell(Text(values.grade)),
            DataCell(Text(values.points)),
            DataCell(Text(values.comment)),
          ])
        ],
      ),
    );
  }
}

class Ogrencisayfasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Ders Adı')),
          DataColumn(label: Text('Hocalar')),
          DataColumn(label: Text('Mesajlaşma')),
        ],
        rows: [
          _createDataRow('Matematik', 'Prof. Dr. Ahmet', 'Doç. Dr. Ayşe'),
          _createDataRow('Fizik', 'Prof. Dr. Mehmet', 'Doç. Dr. Fatma'),
          // Diğer dersler ve hocalar buraya eklenebilir.
        ],
      ),
    ));
  }

  DataRow _createDataRow(String dersAdi, String hoca1, String hoca2) {
    return DataRow(cells: [
      DataCell(Text(dersAdi)),
      DataCell(Row(
        children: [
          ElevatedButton(onPressed: () {}, child: Text(hoca1)),
          SizedBox(width: 8),
          ElevatedButton(onPressed: () {}, child: Text(hoca2)),
        ],
      )),
      DataCell(Row(
        children: [
          ElevatedButton(onPressed: () {}, child: Text('Mesaj Gönder')),
          SizedBox(width: 8),
          ElevatedButton(onPressed: () {}, child: Text('Mesaj Gönder')),
        ],
      )),
    ]);
  }
}
