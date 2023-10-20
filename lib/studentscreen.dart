import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:yazlab/loginscreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:yazlab/ocr.dart';


class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {

  Widget page = Center(child: Text("deneme"),);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 189, 189, 189),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SelectionScreen()));
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Center(
        child:
        Row(
        children: [
          // Sol tarafta yer alan özel navbar
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.1,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.home, color: Colors.white,),
                    onPressed: () {
                      setState(() {
                        page = first();
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.white,),
                    onPressed: () {
                      setState(() {
                        page = second();
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.white,),
                    onPressed: () {
                      setState(() {
                        page = Deneme();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          page

        ],
      ),

      ),
    );
  }

  Future<File?> pickTranscriptFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      // Kullanıcı dosya seçimi iptal etti
      return null;
    }
  }


  Widget first () => Column(
          children: [
            Text("Öğrenci ekranına hoşgeldiniz!"),
            ElevatedButton(
              onPressed: () async {
                File? file = await pickTranscriptFile();
                if (file != null) {
                  // Dosya seçildiyse OCR işlevini çağır
                  List<Uint8List> extractedText =
                      await convertPdfToImages(file);
                  if (extractedText != null) {
                    String fulltext = await extractTextFromImage(extractedText);
                    print(fulltext);
                  } else print("ananı!");
                }
              },
              child: Text('Transkript Seç'),
            )
          ],
        );

  Widget second() => Center(child: Container(
    alignment: Alignment.center ,
    width: MediaQuery.of(context).size.width * 0.5,
    height: MediaQuery.of(context).size.height * 0.5,
    color: Colors.pink,
    child: Text("gürkan burası ikinci yazan yer!"),),);
}


class Deneme extends StatefulWidget {
  const Deneme({ Key? key }) : super(key: key);

  @override
  _DenemeState createState() => _DenemeState();
}

class _DenemeState extends State<Deneme> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0, bottom: 15.0),
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
      ),
    );
  }
}




  // Future<String?> extractTextFromPdf(File file, String apiKey) async {
  //   final request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$apiKey'),
  //   );

  //   request.files.add(http.MultipartFile.fromBytes(
  //     'file',
  //     file.readAsBytesSync(),
  //     filename: file.path.split("/").last,
  //     contentType: MediaType('application', 'pdf'),
  //   ));

  //   final response = await request.send();

  //   if (response.statusCode == 200) {
  //     final result = await http.Response.fromStream(response);
  //     // Burada, result.body'den gelen veriyi parse ederek metni çıkarabilirsiniz.
  //     // Örnek olarak, sadece raw metni döndürüyorum:
  //     return result.body;
  //   } else {
  //     print('OCR işlemi başarısız oldu: ${response.reasonPhrase}');
  //     return null;
  //   }
  // }
