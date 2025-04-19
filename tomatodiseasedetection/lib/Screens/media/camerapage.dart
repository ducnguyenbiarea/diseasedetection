import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'camerapreview.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      initCamera(widget.cameras![0]);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _cameraController.dispose();
    }
    super.dispose();
  }

  Future takePicture() async {
    if (kIsWeb) {
      final pickedFile = await _picker.pickImage(
        source: ImageSource
            .camera, // On web, this opens browser file dialog or camera
        preferredCameraDevice: CameraDevice.rear,
      );
      if (pickedFile != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewPage(picture: pickedFile),
          ),
        );
      }
    } else {
      if (!_cameraController.value.isInitialized ||
          _cameraController.value.isTakingPicture) {
        return;
      }
      try {
        await _cameraController.setFlashMode(FlashMode.off);
        XFile picture = await _cameraController.takePicture();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewPage(
                      picture: picture,
                    )));
      } on CameraException catch (e) {
        debugPrint('Error occurred while taking picture: $e');
      }
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("Camera error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          if (kIsWeb)
            const Center(child: Text("Press button to capture image"))
          else if (_cameraController.value.isInitialized)
            CameraPreview(_cameraController)
          else
            Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator()),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.black),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                if (!kIsWeb)
                  Expanded(
                      child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 30,
                    icon: Icon(
                        _isRearCameraSelected
                            ? CupertinoIcons.switch_camera
                            : CupertinoIcons.switch_camera_solid,
                        color: Colors.white),
                    onPressed: () {
                      setState(
                          () => _isRearCameraSelected = !_isRearCameraSelected);
                      initCamera(
                          widget.cameras![_isRearCameraSelected ? 0 : 1]);
                    },
                  )),
                Expanded(
                    child: IconButton(
                  onPressed: takePicture,
                  iconSize: 50,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.circle, color: Colors.white),
                )),
                const Spacer(),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
