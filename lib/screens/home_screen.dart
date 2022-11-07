import 'dart:io';
import 'package:face_detection_demo/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/face_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<File>? imageFile;
  XFile? _image;
  String result = '';
  List<Face>? faces;
  var image;
  FaceDetector? faceDetector;
  ImagePicker? imagePicker;
  File? selectedImage;
  @override
  void initState() {
    imagePicker = ImagePicker();
    super.initState();
    faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
        enableClassification: true,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.fast));
  }

  doFaceDetection() async {
    selectedImage = File(_image!.path);
    final inputImage = InputImage.fromFile(selectedImage!);
    faces = await faceDetector!.processImage(inputImage);
    print(faces!.length.toString() + " faces");
    drawRectangleAroundFaces();
    if (faces!.length > 0) {
      if (faces![0].smilingProbability! > 0.5) {
        result = AppConstants.smiling;
      } else {
        result = AppConstants.serious;
      }
    }
  }

  drawRectangleAroundFaces() async {
    image = await selectedImage!.readAsBytes();
    image = await decodeImageFromList(image);
    setState(() {
      faces;
      result;
    });
  }

  _imgFromCamera() async {
    XFile? image = await imagePicker!
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
      if (_image != null) {
        doFaceDetection();
      }
    });
  }

  _imgFromGallery() async {
    XFile? image = await imagePicker!
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = image;
      if (_image != null) {
        doFaceDetection();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    faceDetector!.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage(AppConstants.imgString), fit: BoxFit.cover),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 100,
          ),
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: Stack(children: <Widget>[
              Center(
                child: TextButton(
                  onPressed: _imgFromGallery,
                  onLongPress: _imgFromCamera,
                  child: Container(
                    width: 200,
                    height: 150,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.only(
                      top: 45,
                    ),
                    child: image != null
                        ? Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(0)),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0),
                                    color: Colors.black,
                                  ),
                                  width: image.width.toDouble(),
                                  height: 300,
                                  child: CustomPaint(
                                    child: SizedBox(
                                      width: 300,
                                      height: 300,
                                    ),
                                    painter: FacePainter(
                                        rect: faces!, imageFile: image),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              color: Colors.black,
                            ),
                            width: 240,
                            height: 150,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ]),
          ),
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: Text(
              result,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 36),
            ),
          ),
        ],
      ),
    ));
  }
}
