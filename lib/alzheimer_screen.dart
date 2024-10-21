import 'package:audioplayers/audioplayers.dart';
import 'package:biomedical_engineering_app/alarm/screens/home.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'arm_screen.dart';

class AlzheimerScreen extends StatefulWidget {
  @override
  _AlzheimerScreenState createState() => _AlzheimerScreenState();
}

class _AlzheimerScreenState extends State<AlzheimerScreen> {
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  String scannedBarcode = '';
  String title = '';
  String location = '';
  String details = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // الحصول على قائمة الكاميرات المتاحة
    cameras = await availableCameras();
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    await cameraController!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  // دالة لمحاكاة قراءة الباركود
  Future<void> scanBarcode() async {
    // هذه فقط محاكاة لمسح الباركود. يمكنك استخدام حزمة مثل qr_code_scanner أو barcode_scan
    setState(() {
      scannedBarcode = '123456789'; // الباركود المُسح
      title = 'اسم الغرض';
      location = 'الموقع: غرفة النوم';
      details = 'التفاصيل: هذا هو مثال لتفاصيل الغرض';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('شاشة البحث'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معاينة الكاميرا
          cameraController != null && cameraController!.value.isInitialized
              ? Container(
            height: 300,
            width: double.infinity,
            child: CameraPreview(cameraController!),
          )
              : Container(
            height: 300,
            width: double.infinity,
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          SizedBox(height: 20),

          // زر مسح الباركود
          Center(
            child: ElevatedButton(
              onPressed: scanBarcode, // استدعاء المسح
              child: Text('مسح الباركود'),
            ),
          ),
          SizedBox(height: 20),

          // عرض العنوان والموقع والتفاصيل
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'العنوان: $title',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  location,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  details,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      // إضافة شريط أسفل الشاشة يحتوي على زر المنبه
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.alarm, color: Colors.blue,size: 40,),
                onPressed: () {
                  // التنقل إلى شاشة المنابهات عند الضغط على الزر
                  // final AudioPlayer _audioPlayer = AudioPlayer();
                  // _audioPlayer.play(AssetSource('assets/a/alarm.mp3'));

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExampleAlarmHomeScreen()),
                  );
                },
                tooltip: 'المنبهات',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AlzheimerScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
