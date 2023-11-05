import 'package:flutter/material.dart';
import 'package:yazlab/student.dart';

class StudentDetailsPage extends StatelessWidget {
  final Student student;

  const StudentDetailsPage({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${student.ad} ${student.soyad}'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text("Genel Bilgiler", style: Theme.of(context).textTheme.headline6),
                    tileColor: Colors.grey[200],
                  ),
                  ListTile(
                    title: Text("Ad Soyad"),
                    subtitle: Text(student.ad + " " + student.soyad),
                    leading: Icon(Icons.person),
                    trailing: Text("username: " + student.username),
                  ),
                  ListTile(
                    title: Text("Öğrenci Numarası"),
                    subtitle: Text(student.studentId.toString()),
                    leading: Icon(Icons.confirmation_number),
                  ),
                  ListTile(
                    title: Text("Genel Not Ortalaması"),
                    subtitle: Text('${student.genelNotOrtalamasi.toStringAsFixed(2)}'),
                    leading: Icon(Icons.school),
                  ),
                  ListTile(
                    title: Text("İlgi Alanları"),
                    subtitle: Text(student.ilgiAlani),
                    leading: Icon(Icons.interests),
                  ),
                  ListTile(
                    tileColor: Colors.grey[200],
                    title: Text("Akademik Bilgiler", style: Theme.of(context).textTheme.headline6),
                  ),
                  ListTile(
                    title: Text("Anlaşma Talep Sayısı"),
                    subtitle: Text(student.anlasmaTalepSayisi.toString()),
                    leading: Icon(Icons.handshake),
                  ),
                  ListTile(
                    title: Text("Anlaşma Durumu"),
                    subtitle: Text(student.anlasmaDurumu ? "Evet" : "Hayır"),
                    leading: Icon(Icons.check_circle_outline),
                  ),
                  ListTile(
                    title: Text("Not Durum Belgesi"),
                    subtitle: Text(student.notDurumBelgesi),
                    leading: Icon(Icons.document_scanner),
                  ),
                  ListTile(
                    title: Text("Ders Bilgileri"),
                    subtitle: Text(student.dersBilgileri),
                    leading: Icon(Icons.info_outline),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
