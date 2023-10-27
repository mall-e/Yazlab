import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:pdf_render/pdf_render.dart';
import 'package:image/image.dart' as img;
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:pdf_text/pdf_text.dart';


// lib/vision_helper.dart



class VisionHelper {
  final String apiKey;
  vision.VisionApi? visionApi;

  VisionHelper(this.apiKey);

  Future<void> initialize() async {
    final httpClient = clientViaApiKey(apiKey);
    visionApi = vision.VisionApi(httpClient);
  }

  Future<void> performOcr(File file) async {
    if (visionApi == null) {
      throw Exception('Vision API is not initialized');
    }

    if (await file.exists()) {
      print('File exists');
      print('File size: ${await file.length()} bytes');
    } else {
      print('File does not exist');
      return;
    }

    final pdfDocument = await PdfDocument.openFile(file.path);
    final pdfPage = await pdfDocument.getPage(1);  // 1. sayfayı alın
    final pageImage = await pdfPage.render();  // Sayfayı bir resme çevirin

    // Baytları doğrudan alın ve base64'e kodlayın
    final encodedBytes = base64Encode(pageImage.pixels);
    print('Encoded bytes: $encodedBytes');

    final visionImage = vision.Image(content: encodedBytes);
    final request = vision.AnnotateImageRequest(
        image: visionImage, features: [vision.Feature(type: 'TEXT_DETECTION')]);
    final response = await visionApi!.images
        .annotate(vision.BatchAnnotateImagesRequest(requests: [request]));

    print('API Response: ${jsonEncode(response.toJson())}');

    print('API Response: ${jsonEncode(response.toJson())}');


    if (response.responses != null && response.responses!.isNotEmpty) {
  for (var annotateImageResponse in response.responses!) {
    if (annotateImageResponse.error != null) {
      print('API Error: ${annotateImageResponse.error!.toJson()}');
    } else if (annotateImageResponse.textAnnotations != null &&
               annotateImageResponse.textAnnotations!.isNotEmpty) {
      for (var annotation in annotateImageResponse.textAnnotations!) {
        print('OCR sonucu: ${annotation.description}');
      }
    } else {
      print('Metin annotasyonları bulunamadı');
    }
  }
} else {
  print('Yanıt alınamadı veya yanıt boş');
}

  }
}

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
