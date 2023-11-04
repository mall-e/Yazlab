import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:provider/provider.dart';
import 'package:yazlab/loginscreen.dart';
import 'package:yazlab/professor.dart';
import 'package:yazlab/student.dart';
final connection = PostgreSQLConnection(
  'localhost', // Sunucu adresi
  5432, // Port numarası
  'yazlab', // Veritabanı adı
  username: 'postgres',
  password: '***',
);

void main() async {
  runApp(const MyApp());

  await connection.open();

  PostgreSQLResult results = await connection.query('SELECT * FROM ogrenciler');
  for (final row in results) {
    print('ID: ${row[0]}, Ad: ${row[1]}');
  }

  await connection.close();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
        create: (context) => Professor()),
         ChangeNotifierProvider(create: (context) => Student()),
      ],
        child: MaterialApp(
          title: 'Yazlab',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const SelectionScreen(),
        ),
    );
  }
}

