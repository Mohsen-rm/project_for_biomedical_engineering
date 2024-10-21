import 'package:flutter/material.dart';

class AboutStudentsScreen extends StatelessWidget {
  // قائمة بأسماء الطلاب، اختصاصاتهم، وجنسهم
  final List<Map<String, String>> students = [
    {"name": "زهراء", "major": "الهندسة الطبية", "gender": "female"},
    {"name": "مصطفى", "major": "الهندسة الطبية", "gender": "male"},
    {"name": "نور", "major": "الهندسة الطبية", "gender": "female"},
    {"name": "سارة", "major": "الهندسة الطبية", "gender": "female"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الطلاب المؤسسين'),
      ),
      body: Column(
        children: [
          // العنوان في الأعلى
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'الطلاب المؤسسين',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                // تحديد الصورة بناءً على الجنس
                String imagePath = student['gender'] == 'male'
                    ? 'assets/user_m.png'
                    : 'assets/user_f.png';

                return ListTile(
                  leading: Image.asset(
                    imagePath, // الصورة الافتراضية حسب الجنس
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    student['name'] ?? '',
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(
                    student['major'] ?? '',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
