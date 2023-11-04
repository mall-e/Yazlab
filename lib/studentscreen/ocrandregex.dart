import 'dart:convert';
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:yazlab/transciprtrow.dart';

Future<String> doOCR(File file) async {
    final data = await file.readAsBytes();
    final name = file.path.split('/').last;
    final mpfile = http.MultipartFile.fromBytes(
      'file',
      data,
      filename: name,
      contentType: MediaType('application', 'pdf'),
    );

    final url =
        'http://localhost:5000/pdf-reader';
    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..files.add(mpfile);
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> resultData = json.decode(responseData);
      var ocrResult = resultData['text'];
      return ocrResult;
      //print('OCR Result: $ocrResult');
    } else {
      print('Failed to perform OCR.');
      return "";
    }
  }

  List<TranscriptRow> ayirVeTranscriptRowsOlustur(String metin) {
  RegExp regex = RegExp(
    r"([A-Z]+\d{3})\s+((?:[^\(]+)?(?:\s*\([^\)]+\))?)\s+(\w)\s+(\w{2})\s+(\d)\s+(\d)\s+(\d)\s+(\d)\s+([\d.]+)\s+(\w{2})\s+(\w+)",
    multiLine: true
  );

  List<TranscriptRow> rows = [];

  Iterable<Match> matches = regex.allMatches(metin);

  for (var match in matches) {
    // Verileri al ve TranscriptRow nesnesi oluştur
    String kod = match.group(1) ?? "";
    String isim = match.group(2)?.trim() ?? "";
    String status = match.group(3) ?? "";
    String dil = match.group(4) ?? "";
    int t = int.tryParse(match.group(5) ?? "0") ?? 0;
    int u = int.tryParse(match.group(6) ?? "0") ?? 0;
    int uk = int.tryParse(match.group(7) ?? "0") ?? 0;
    int akts = int.tryParse(match.group(8) ?? "0") ?? 0;
    double puan = double.tryParse(match.group(9) ?? "0") ?? 0.0;
    String not = match.group(10) ?? "";
    String aciklama = match.group(11) ?? "";

    // Yeni bir TranscriptRow nesnesi oluştur
    TranscriptRow row = TranscriptRow(
      kod: kod,
      isim: isim,
      status: status,
      dil: dil,
      t: t,
      u: u,
      uk: uk,
      akts: akts,
      puan: puan.toInt(), // Varsayılan olarak puanı tam sayı olarak kabul ediyorum
      not: not,
      aciklama: aciklama
    );

    // Oluşturulan nesneyi listeye ekle
    rows.add(row);
  }

  return rows;
}
