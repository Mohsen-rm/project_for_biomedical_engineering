import 'dart:io';
import 'package:flutter/material.dart';
import 'about_screen.dart';
import 'about_students_screen.dart';
import 'alzheimer_screen.dart';
import 'forgetting_things_screen.dart';
import 'ocd_screen.dart';
import 'sites_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExpiryDate(context); // التحقق من انتهاء الصلاحية بعد البناء
    });
  }

  void _checkExpiryDate(BuildContext context) {
    DateTime expiryDate = DateTime(2024, 10, 25); // تاريخ انتهاء الصلاحية
    DateTime currentDate = DateTime.now(); // التاريخ الحالي

    if (currentDate.isAfter(expiryDate)) {
      _showExpiryDialog(context); // عرض نافذة انتهاء الصلاحية
    }
  }

  void _showExpiryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // منع إغلاق النافذة بالنقر خارجها
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('التطبيق متوقف'),
          content: Text(
              'لقد تجاوز هذا التطبيق تاريخ انتهاء الصلاحية. برجاء الاتصال بمطور البرنامج.'),
          actions: [
            TextButton(
              child: Text('أوك'),
              onPressed: () {
                exit(0); // إغلاق التطبيق عند الضغط على "أوك"
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الصفحة الرئيسية'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // فتح القائمة الجانبية
            },
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon/app_icon.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10),
                Text(
                  'الحياة',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info,
            text: 'تحقق من الأشياء',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info,
            text: 'المواقع',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LocationsPage()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info,
            text: 'حول التطبيق',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutScreen()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.school,
            text: 'الطلاب المؤسسين',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutStudentsScreen()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.exit_to_app,
            text: 'الخروج من التطبيق',
            onTap: () => _onWillPop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/ocd.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OcdScreen()),
                ),
                child: Text('OCD', style: TextStyle(fontSize: 20)),
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/alzheime.jpg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlzheimerScreen()),
                ),
                child: Text('Alzheimer', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool? exitApp = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الخروج'),
        content: Text('هل أنت متأكد أنك تريد الخروج من التطبيق؟'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('نعم'),
          ),
        ],
      ),
    );

    if (exitApp == true) {
      exit(0);
    }

    return Future.value(false);
  }
}
