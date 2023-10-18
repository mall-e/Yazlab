import 'package:flutter/material.dart';
import 'package:yazlab/loginscreen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({ Key? key }) : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SelectionScreen()));
            },
            icon: Icon(Icons.logout))],),
      body: Center(child: Text("Öğrenci ekranına hoşgeldiniz!"),),
    );
  }
}
