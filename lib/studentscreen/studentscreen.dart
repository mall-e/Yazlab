import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazlab/classification.dart';
import 'package:yazlab/screentemplate.dart';
import 'package:yazlab/student.dart';
import 'package:yazlab/studentscreen/firstpage.dart';
import 'package:yazlab/studentscreen/secondpage.dart';
import 'package:yazlab/studentscreen/srequestscreen.dart';
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
      child: ScreenTemplate(buttons: [
        Icon(
          Icons.print_rounded,
          color: Colors.white,
        ),
        Icon(
          Icons.select_all,
          color: Colors.white,
        ),
        Icon(
          Icons.request_quote,
          color: Colors.white,
        )
      ], pages: {
        0: const FirstPage(),
        1: CoursesPage(),
        2: const ThirdPage(),
      }),
    );
  }
}
