import 'dart:io';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image/image.dart' as img;
import 'dart:developer' as devtools;
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CameraHelper {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;

  Future<void> initializeCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);

    await _cameraController?.initialize();
    _isCameraInitialized = true;
  }

  Future<void> captureImage(
      Function(File) onCapture, Function(String) onLabelUpdate) async {
    try {
      if (!_isCameraInitialized || _cameraController == null) return;

      final image = await _cameraController?.takePicture();
      if (image == null) return;

      File imageFile = File(image.path);
      onCapture(imageFile); // Notify the UI about the new image path

      File resizedFile = await resizeImage(imageFile, 224, 224);

      var recognitions = await Tflite.runModelOnImage(
        path: resizedFile.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true,
      );

      if (recognitions == null) {
        devtools.log("Recognition is null");
        return;
      }

      devtools.log(recognitions.toString());

      String label = recognitions[0]['label'].toString();
      onLabelUpdate(label); // Notify the UI about the new label

      // Upload the resized image to Firebase
      String downloadUrl = await uploadImageToFirebase(resizedFile);
      devtools.log("Image uploaded to Firebase: $downloadUrl");
    } catch (e) {
      devtools.log("Error capturing image: $e");
    }
  }

  Future<File> resizeImage(File imageFile, int width, int height) async {
    final img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    final img.Image resizedImage =
        img.copyResize(image!, width: width, height: height);

    final resizedImageFile = File(imageFile.path)
      ..writeAsBytesSync(img.encodeJpg(resizedImage));

    return resizedImageFile;
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    try {
      // Get a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();

      // Create a unique file name based on the current timestamp
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload the file to Firebase Storage
      UploadTask uploadTask =
          storageRef.child('images/$fileName.jpg').putFile(imageFile);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      devtools.log("Error uploading image to Firebase: $e");
      return '';
    }
  }

  void disposeCamera() {
    _cameraController?.dispose();
  }
}
