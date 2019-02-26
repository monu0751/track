import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'services/saveimage.dart';
import 'attendance_summary.dart';
import 'home.dart';
import 'model/timeinout.dart';
import 'globals.dart' as global;
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:exifdart/exifdart_io.dart';
import 'package:image/image.dart' as rotatingImage;
//import 'package:flutter_image_compress/flutter_image_compress.dart';

/*import 'package:video_player/video_player.dart';*/

class CameraExampleHome extends StatefulWidget {
  @override
  _CameraExampleHomeState createState() => _CameraExampleHomeState();

}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHomeState extends State<CameraExampleHome> {
  bool isfrontcamera = true;
  bool isprocessed = false;
  CameraController controller;
  String imagePath = null;
  String videoPath;
  //VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  List<CameraDescription> cameras;
  File compressedFile1 = null;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async{
    try {
      cameras = await availableCameras();
      setState(() {
        cameras = cameras;
        if(cameras!=null)
          onNewCameraSelected(cameras[1]);
      });
      //runApp(CameraApp());
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: Colors.teal,
        leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },),
      ),

      body: (imagePath == null)?Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: isprocessed?Center(child : new CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.orangeAccent))):_cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          isprocessed?Text("Processing..."):_captureControlRowWidget(),

         /* Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                *//*_cameraTogglesRowWidget(),
                _thumbnailWidget(),*//*
                _captureControlRowWidget(),
              ],
            ),
          ),*/
          SizedBox(height: 20.0,)
        ],
      ):
      Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _thumbnailWidget1(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          _captureControlRowWidget1(),

          /* Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                *//*_cameraTogglesRowWidget(),
                _thumbnailWidget(),*//*
                _captureControlRowWidget(),
              ],
            ),
          ),*/
          SizedBox(height: 20.0,)
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Mark your Attendance',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }
  Widget _thumbnailWidget1() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Mark your Attendance',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Image.file(File(imagePath)),
      );
    }
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: imagePath == null
            ? null
            : SizedBox(
          child: Image.file(File(imagePath)),
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      //mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.close,size: 40.0,),
          color: Colors.black,
          onPressed: (){

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),

        IconButton(
          icon: const Icon(Icons.camera,size: 40.0,),
          color: Colors.black,
          onPressed: (){
            if(controller != null &&
              controller.value.isInitialized &&
              !controller.value.isRecordingVideo)
              {
                onTakePictureButtonPressed();
              }
         },
        ),

        IconButton(
          icon: const Icon(Icons.autorenew,size: 40.0,),
          color: Colors.black,
          onPressed: (){
            isfrontcamera = !isfrontcamera;
            if(isfrontcamera){
              onNewCameraSelected(cameras[1]);
            }else{
              onNewCameraSelected(cameras[0]);
            }
          },
        ),

      ],
    );
  }

  Widget _captureControlRowWidget1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      //mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.close,size: 40.0,),
          color: Colors.black,
          onPressed: (){

            setState(() {
              isprocessed = false;
              imagePath = null;
            });
          },
        ),



        isprocessed?Center(child : new CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.black))):IconButton(
          icon: const Icon(Icons.check,size: 40.0,),
          color: Colors.black,
          onPressed: (){
            //showInSnackBar('Picture saved to $imagePath');
            setState(() {
              isprocessed = true;
            });
            saveImage(imagePath);
          },
        ),

      ],
    );
  }


  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras==null) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: controller != null && controller.value.isRecordingVideo
                  ? null
                  : onNewCameraSelected,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.low);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    setState(() {
      isprocessed = true;
    });
    takePicture().then((String filePath) {

      if (mounted) {
        setState(() {
          imagePath = filePath;
          isprocessed = false;
        });
        /*if (filePath != null){
          showInSnackBar('Picture saved to $filePath');
          //saveImage(filePath);
        }*/
      }else{
        setState(() {
          isprocessed = false;
        });
      }
    });
  }

  saveImage(filePath) async {
    SaveImage saveImage = new SaveImage();
    bool issave = false;
    MarkTime mk;
    mk = global.mk1;
    /*ImageProperties properties = await FlutterNativeImage.getImageProperties(filePath);*/
     /*File compressedFile = await FlutterNativeImage.compressImage(filePath, percentage: 90);*/
    ImageProperties properties = await FlutterNativeImage.getImageProperties(filePath);
    File compressedFile = await FlutterNativeImage.compressImage(filePath, targetWidth: 600,
        targetHeight: (properties.height * 600 / properties.width).round());
    /*File compressedFile = await FlutterNativeImage.compressImage(filePath,
        quality: 50, percentage: 50);
*/
/*
 Map<String, dynamic> tags = await readExifFromFile(compressedFile);
if (tags.containsKey("Orientation")) {
      rotatingImage.Image imageToRotate = rotatingImage.decodeImage(compressedFile.readAsBytesSync());
      switch (tags["Orientation"]) {
        case 8:
          imageToRotate = rotatingImage.copyRotate(imageToRotate, -90);
          break;
        case 6:
          imageToRotate = rotatingImage.copyRotate(imageToRotate, 90);
          break;
      }
      setState(() {
        compressedFile1..writeAsBytesSync(rotatingImage.encodePng(imageToRotate));
      });
    }*/

    issave = await saveImage.saveTimeInOut(compressedFile,mk);
    ////print(issave);
    if (issave) {
      showDialog(context: context, child:
      new AlertDialog(
        content: new Text("Attendance marked successfully!"),
      )
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
      //showInSnackBar('Picture saved to - $filePath');
    }else{
      showDialog(context: context, child:
      new AlertDialog(
        title: new Text("!"),
        content: new Text("Problem while marking attendance, try again."),
      )
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      //showInSnackBar('Unable to save - $filePath');
    }
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (filePath != null) showInSnackBar('Saving video to $filePath');
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recorded to: $videoPath');
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    await _startVideoPlayer();
  }

  Future<void> _startVideoPlayer() async {
    /* final VideoPlayerController vcontroller =
    VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();*/
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
   // final Directory extDir = await getApplicationDocumentsDirectory();
    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';
    print(filePath);
    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
      ImageProperties properties = await FlutterNativeImage.getImageProperties(filePath);
      File compressedFile = await FlutterNativeImage.compressImage(filePath, targetWidth: 350,
          targetHeight: (properties.height * 350 / properties.width).round());
      /*File compressedFile = await FlutterNativeImage.compressImage(filePath,
          quality: 40);*/
      //compressedFile1 = File(filePath);
      Map<String, dynamic> tags = await readExifFromFile(compressedFile);
      if (tags.containsKey("Orientation")) {
        rotatingImage.Image imageToRotate = rotatingImage.decodeImage(compressedFile.readAsBytesSync());
        switch (tags["Orientation"]) {
          case 8:
            imageToRotate = rotatingImage.copyRotate(imageToRotate, -90);
            break;
          case 6:
            imageToRotate = rotatingImage.copyRotate(imageToRotate, 90);
            break;
        }
        setState(() {
          /*compressedFile1..writeAsBytesSync(rotatingImage.encodePng(imageToRotate));*/
          File(filePath).writeAsBytesSync(rotatingImage.encodePng(imageToRotate));
        });
      }
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

/*class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraExampleHome(),
    );
  }
}*/



