import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:camera/camera.dart';
import 'dart:developer' as devtools;
import 'package:shape_detection/camera_helper.dart';
import 'package:shape_detection/services/database_service.dart';

class ScienceObj extends StatefulWidget {
  const ScienceObj({super.key});

  @override
  State<ScienceObj> createState() => _ScienceObjState();
}

class _ScienceObjState extends State<ScienceObj> {
  File? filePath;
  String label = '';
  double confidence = 0.0;
  bool _modelLoaded = false;

  final CameraHelper _cameraHelper = CameraHelper();
  final DatabaseService _databaseService = DatabaseService();

  Future<void> _tfliteInit() async {
    String? res = await Tflite.loadModel(
        model: "assets/model2/model_unquant.tflite",
        labels: "assets/model2/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false);
    if (res == null) {
      devtools.log("Failed to load the science model");
      return;
    }
    devtools.log("Science Model Loaded Successfully");
  }

  Future<void> _ensureModelIsLoaded() async {
    if (!_modelLoaded) {
      await _tfliteInit();
      setState(() {
        _modelLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tfliteInit();
    _cameraHelper.initializeCamera().then((_) {
      setState(() {}); // Rebuild the UI after camera initialization
    });
  }

  @override
  void dispose() {
    _cameraHelper.disposeCamera();
    Tflite.close();
    super.dispose();
  }

  void _updateImageFile(File newFile) {
    setState(() {
      filePath = newFile;
    });
  }

  void _updateLabel(String newLabel) {
    setState(() {
      label = newLabel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Science Object Detection'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (_cameraHelper.isCameraInitialized &&
                _cameraHelper.cameraController != null)
              SizedBox(
                width: 300,
                height: 400,
                child: AspectRatio(
                  aspectRatio:
                      _cameraHelper.cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraHelper.cameraController!),
                ),
              )
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 20),
            if (label.isNotEmpty)
              Text(
                'Detected Shape: $label',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _ensureModelIsLoaded();
                await _cameraHelper.captureImage(
                    _updateImageFile, _updateLabel);
                await _databaseService.saveDetectedShape(filePath,
                    label); // Save the shape after capturing the image
              },
              child: const Text('Capture Image and Save Shape'),
            ),
          ],
        ),
      ),
    );
  }
}
