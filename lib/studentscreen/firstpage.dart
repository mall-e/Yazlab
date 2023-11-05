import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazlab/screentemplate.dart';
import 'package:yazlab/studentscreen/databesops.dart';
import 'package:yazlab/studentscreen/ocrandregex.dart';
import 'package:yazlab/studentscreen/studentscreen.dart';
import 'package:yazlab/studentscreen/transcriptpage.dart';
import 'package:yazlab/transciprtrow.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({ Key? key }) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  var ocrResult;
  @override
  Widget build(BuildContext context) {
    final pageModel = Provider.of<PageModel>(context, listen: false);
    return UITemplate(
    page: Column(
          children: [
            Text("Öğrenci ekranına hoşgeldiniz!"),
            ElevatedButton(
              onPressed: () async {
                File? file = await pickTranscriptFile();
                    List<TranscriptRow> row;
                if (file != null) {
                  // Dosya seçildiyse OCR işlevini çağır
                  ocrResult = await doOCR(file);
                  setState(() {
                      row =  ayirVeTranscriptRowsOlustur(ocrResult);
                      print(row[0].not);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TranscriptPage(row)));
                      pageModel.page = TranscriptPage(row);
                      insertTranscriptRows(row);
                      print(row[0]);
                    });
                } else
                  print("sorun!");
              },
              child: Text('Transkript Seç'),
            ),
            ElevatedButton(onPressed: (){resetTable();}, child: Text("Tabloyu sıfırla")),
          ],
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
}


