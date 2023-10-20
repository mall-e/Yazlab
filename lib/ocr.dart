import 'dart:io';
import 'dart:typed_data';

import 'package:pdf_render/pdf_render.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path_provider/path_provider.dart';

Future<List<Uint8List>> convertPdfToImages(File file) async {
  final pdfDocument = await PdfDocument.openFile(file.path);
  final pageCount = pdfDocument.pageCount;
  final List<Uint8List> images = [];

  for (int i = 1; i <= pageCount; i++) {
    final page = await pdfDocument.getPage(i);
    final pageImage = await page.render();
    images.add(pageImage.pixels);
  }

  return images;
}



Future<String> extractTextFromImage(List<Uint8List> images) async {
  StringBuffer combinedText = StringBuffer();

  for (int i = 0; i < images.length; i++) {
     // Geçici bir dosya yolu oluştur
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/image_$i.png';
    // Uint8List verisini dosyaya yaz
    final tempFile = File(tempFilePath);
    await tempFile.writeAsBytes(images[i]);
    // Tesseract OCR ile metin çıkar
    final text = await FlutterTesseractOcr.extractText(tempFilePath);
    // Geçici dosyayı sil
    await tempFile.delete();
    // Metin verisini birleştir
    combinedText.writeln(text);
  }

  return combinedText.toString();
}
