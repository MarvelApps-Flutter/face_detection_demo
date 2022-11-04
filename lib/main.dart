import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
//flutter build ios

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
    // TODO: implement initState
    imagePicker = ImagePicker();
    super.initState();
    faceDetector = GoogleMlKit.vision.faceDetector(
        FaceDetectorOptions(
            enableClassification: true,
            minFaceSize: 0.1,
            performanceMode: FaceDetectorMode.fast));
  }

  //TODO face detection code
  doFaceDetection() async {
    selectedImage = File(_image!.path);
    final inputImage = InputImage.fromFile(selectedImage!);
    faces = await faceDetector!.processImage(inputImage);
    print(faces!.length.toString()+" faces");
    drawRectangleAroundFaces();
    if(faces!.length>0){
      if(faces![0].smilingProbability! >0.5) {
        result ="Smiling";
      }else{
        result = "Serious";
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
    XFile? image = await imagePicker!.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
      if (_image != null) {
        doFaceDetection();
      }
    });
  }

  _imgFromGallery() async {
    XFile? image = await imagePicker!.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = image;
      if (_image != null) {
        doFaceDetection();
      }
    });
  }



  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    faceDetector!.close();

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/img2.jpg'),
                  fit: BoxFit.cover
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 100,
                ),
                Container(
                  margin: EdgeInsets.only(top: 100),
                  child: Stack(children: <Widget>[
                    Center(
                      child: TextButton(
                        onPressed: _imgFromGallery,
                        onLongPress: _imgFromCamera,
                        child: Container(
                          width: 200,
                          height: 200,
                           decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)
                                ),
                          margin: EdgeInsets.only(
                            top: 45,
                          ),
                          child: image != null
                              ? Center(
                            child: Container(
                               decoration: BoxDecoration(
                                 color: Colors.black,
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Container(
                                    decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                              //      width: 200,
                              // height: 200,
                                  width: image.width.toDouble(),
                                  height: image.width.toDouble(),
                                  child: CustomPaint(
                                    painter: FacePainter(
                                        rect: faces!, imageFile: image
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                              : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                   color: Colors.black,
                                ),
                           
                            width: 240,
                            height: 250,
                            child: Icon(
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
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    '$result',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'finger_paint', fontSize: 36),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Face>? rect;
  var imageFile;
  FacePainter({this.rect, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }
    Paint p = Paint();
    p.color = Colors.green;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 4;

    if (rect != null) {
      for (Face rectangle in rect!) {
        canvas.drawRect(rectangle.boundingBox, p);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}