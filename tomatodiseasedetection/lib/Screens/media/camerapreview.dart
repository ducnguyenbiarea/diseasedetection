// import 'package:camera/camera.dart';
// import 'package:tomatodiseasedetection/data/DiseasesModel.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';

// class PreviewPage extends StatelessWidget {
//   const PreviewPage({Key? key, required this.picture}) : super(key: key);

//   final XFile picture;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Preview Page')),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Expanded(
//             child:
//                 Image.file(File(picture.path), fit: BoxFit.cover, width: 250),
//           ),
//           const SizedBox(height: 30),
//           Text(picture.name),
//           const SizedBox(height: 30),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               IconButton(
//                 onPressed: () {
//                   // Handle retake functionality here
//                   Navigator.pop(context);
//                 },
//                 icon: const Icon(Icons.refresh, size: 30),
//               ),
//               IconButton(
//                 onPressed: () async {
//                   await DiseaseData().sendImageToDiseasePage(context, picture);
//                 },
//                 icon: const Icon(Icons.check, size: 30),
//                 color: Colors.green,
//               ),
//             ],
//           ),
//           const SizedBox(height: 30),
//         ],
//       ),
//     );
//   }
// }

import 'package:camera/camera.dart';
import 'package:tomatodiseasedetection/data/DiseasesModel.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: kIsWeb
                ? Image.network(picture.path) // shows preview in browser
                : Image.file(File(picture.path), fit: BoxFit.cover),
          ),
          const SizedBox(height: 30),
          Text(picture.name),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.refresh, size: 30),
              ),
              IconButton(
                onPressed: () async {
                  await DiseaseData().sendImageToDiseasePage(context, picture);
                },
                icon: const Icon(Icons.check, size: 30),
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
