import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screen_home.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Alarm.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // هذا السطر يزيل علامة "Debug"
      // إعدادات اللغات المدعومة
      locale: Locale('ar'), // اضبط اللغة الافتراضية على العربية
      supportedLocales: [
        Locale('en'), // الإنجليزية
        Locale('ar'), // العربية
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // إذا لم تكن اللغة الحالية مدعومة، استخدم اللغة الافتراضية (الإنجليزية أو العربية)
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    // الانتقال إلى الصفحة التالية بعد 4 ثواني
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // الصورة في أعلى الشاشة وتغطي العرض بالكامل
          Container(
            width: double.infinity,
            height: 300,
            child: Image.asset(
              'assets/wel.jpg', // المسار للصورة في assets
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'مرحبًا بك في تطبيق الحياة',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, // محاذاة النص في الوسط
            ),
          ),
        ],
      ),
    );
  }
}