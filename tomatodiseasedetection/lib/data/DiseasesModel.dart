import 'package:tomatodiseasedetection/Screens/diseases/diseasedetail.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

class DiseaseData {
  static final DiseaseData _instance = DiseaseData._internal();

  factory DiseaseData() => _instance;

  DiseaseData._internal();

  List<Map<String, dynamic>> diseaseList = [];

  Future<void> initializeDiseaseList() async {
    if (diseaseList.isEmpty) {
      final jsonString = await rootBundle.loadString(
        'asset/cropdisease/disease.json',
      );
      diseaseList = json.decode(jsonString).cast<Map<String, dynamic>>();
    }
  }

  Future<void> sendImageToDiseasePage(
    BuildContext context,
    dynamic _selectedImage,
  ) async {
    try {
      print("📤 !! Preparing to send image to backend...");

      var uri = Uri.parse(
        "https://diseasedetection-rumj.onrender.com/predict",
      );
      var request = http.MultipartRequest('POST', uri);

      final mimeTypeData = lookupMimeType(_selectedImage.path)?.split('/');
      if (mimeTypeData == null || mimeTypeData.length != 2) {
        throw Exception("⚠️ !! Could not determine MIME type.");
      }

      print("📂 !! MIME Type Detected: ${mimeTypeData[0]}/${mimeTypeData[1]}");
      print("🖼️ !! Image Path: ${_selectedImage.path}");

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _selectedImage.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          filename: basename(_selectedImage.path),
        ),
      );

      print("📤 !! Sending request to backend...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("📬 !! Received response: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        print("🔍 !! Decoded response body: $responseBody");

        int index = responseBody['index'] - 1;
        print("📊 !! Index received: ${responseBody['index']}");
        print("📉 !! Zero-based index used: $index");
        print("📋 !! diseaseList length: ${diseaseList.length}");

        if (index < 0 || index >= diseaseList.length) {
          throw Exception(
            "❌ !! Index out of range: $index (valid range: 0-${diseaseList.length - 1})",
          );
        }

        // Navigate to disease detail page
        print("🚀 !! Navigating to DiseaseDetailsPage...");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DiseaseDetailsPage(disease: diseaseList[index]),
          ),
        );
      } else {
        throw Exception(
          "🔥 !! Backend error: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("💥 !! Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
