import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazlab/student.dart';
import 'package:yazlab/studentscreen/studentrequestpage.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({ Key? key }) : super(key: key);

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  @override
  Widget build(BuildContext context) {
    final student = Provider.of<Student>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(
          top: 15.0, left: 10.0, right: 10.0, bottom: 15.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.83,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: StudentRequestsPage(studentId: student.studentId),
      ),
    );
  }
}
