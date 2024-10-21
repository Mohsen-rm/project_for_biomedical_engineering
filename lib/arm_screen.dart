import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmsScreen extends StatefulWidget {
  @override
  _AlarmsScreenState createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  List<Alarm> alarms = [];
  final Record _record = Record();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
    'alarm_channel',
    'تنبيهات المنبه',
    description: 'قناة للتنبيهات الخاصة بالمنبه',
    importance: Importance.max,
    playSound: true,
  );

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadAlarms();
    _requestPermissions();

    // Handle the case when the app is launched via a notification
    _checkForInitialNotification();
  }

  // طلب الأذونات
  Future<void> _requestPermissions() async {
    if (await Permission.microphone.request().isGranted) {
      // إذن الميكروفون تم الحصول عليه
    }

    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        // طلب إذن الإشعارات الدقيقة
        await Permission.scheduleExactAlarm.request();
      }
    }
  }

  // دالة لفحص الإشعار الأولي عند إطلاق التطبيق
  Future<void> _checkForInitialNotification() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      String? payload = notificationAppLaunchDetails!.notificationResponse?.payload;
      _showAlarmDetailsDialog(payload);
    }
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));  // استخدام التوقيت المحلي

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        _showAlarmDetailsDialog(response.payload); // عرض التنبيه مباشرة
      },
    );

    // إنشاء قناة الإشعارات
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(alarmChannel);
  }

  // عرض تفاصيل المنبه مع تشغيل الصوت
  void _showAlarmDetailsDialog(String? payload) async {
    if (payload == null) return;
    Alarm alarm = Alarm.fromJson(jsonDecode(payload));

    // تشغيل الصوت
    await _audioPlayer.play(DeviceFileSource(alarm.audioPath));

    // عرض التنبيه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('تنبيه: ${alarm.title}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('الموقع: ${alarm.location}'),
                Text('الوقت: ${alarm.time.format(context)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _audioPlayer.stop(); // إيقاف الصوت
                  Navigator.of(context).pop();
                },
                child: Text('إيقاف'),
              ),
            ],
          ),
        );
      }
    });
  }

  // تحميل المنبهات من التخزين
  void _loadAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? alarmsJson = prefs.getString('alarms');
    if (alarmsJson != null) {
      List<dynamic> alarmsList = json.decode(alarmsJson);
      setState(() {
        alarms = alarmsList.map((alarm) => Alarm.fromJson(alarm)).toList();
      });
      for (var alarm in alarms) {
        _scheduleAlarm(alarm);
      }
    }
  }

  // حفظ المنبهات في التخزين
  void _saveAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> alarmsList = alarms.map((alarm) => alarm.toJson()).toList();
    await prefs.setString('alarms', json.encode(alarmsList));
  }

  // جدولة المنبه مع الإشعارات
  void _scheduleAlarm(Alarm alarm) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        alarm.id,
        'منبه: ${alarm.title}',
        'الموقع: ${alarm.location}',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            alarmChannel.id,
            alarmChannel.name,
            channelDescription: alarmChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            fullScreenIntent: true,
          ),
        ),
        androidAllowWhileIdle: true,
        payload: jsonEncode(alarm.toJson()),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: alarm.isDaily ? DateTimeComponents.time : null,
      );
    } catch (e) {
      print("خطأ في جدولة الإشعار: $e");
    }
  }

  // دالة لإضافة منبه جديد
  void _showAddAlarmDialog() {
    String alarmTitle = '';
    String? selectedLocation;
    TimeOfDay? selectedTime;
    bool isDaily = true;
    String? audioPath;
    bool isRecording = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('إضافة منبه'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'العنوان'),
                      onChanged: (value) {
                        alarmTitle = value;
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'اختيار الموقع'),
                      items: ['غرفة النوم', 'المطبخ', 'غرفة الاستقبال']
                          .map((location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedLocation = value;
                        });
                      },
                      value: selectedLocation,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          selectedTime != null
                              ? 'الوقت: ${selectedTime!.format(context)}'
                              : 'اختيار الوقت',
                          style: TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          child: Text('اختيار'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('هل تريد تنبيه يومي؟', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: isDaily,
                          onChanged: (value) {
                            setStateDialog(() {
                              isDaily = value;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تسجيل صوت التنبيه', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: isRecording
                                  ? null
                                  : () async {
                                if (await _record.hasPermission()) {
                                  Directory appDir = await getApplicationDocumentsDirectory();
                                  String path = '${appDir.path}/alarm_${DateTime.now().millisecondsSinceEpoch}.m4a';
                                  await _record.start(
                                    path: path,
                                    encoder: AudioEncoder.aacLc,
                                    bitRate: 128000,
                                    samplingRate: 44100,
                                  );
                                  setStateDialog(() {
                                    isRecording = true;
                                  });
                                }
                              },
                              icon: Icon(Icons.mic),
                              label: Text('تسجيل'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: isRecording
                                  ? () async {
                                String? path = await _record.stop();
                                setStateDialog(() {
                                  audioPath = path;
                                  isRecording = false;
                                });
                              }
                                  : null,
                              icon: Icon(Icons.stop),
                              label: Text('إيقاف'),
                            ),
                          ],
                        ),
                        if (audioPath != null)
                          Text('تم تسجيل الصوت', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (alarmTitle.isNotEmpty &&
                        selectedLocation != null &&
                        selectedTime != null &&
                        audioPath != null) {
                      int newId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                      final newAlarm = Alarm(
                        id: newId,
                        title: alarmTitle,
                        location: selectedLocation!,
                        time: selectedTime!,
                        isDaily: isDaily,
                        audioPath: audioPath!,
                      );
                      setState(() {
                        alarms.add(newAlarm);
                      });
                      _scheduleAlarm(newAlarm);
                      _saveAlarms();
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('يرجى إكمال جميع الحقول.')),
                      );
                    }
                  },
                  child: Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // حذف منبه
  void _deleteAlarm(int index) async {
    Alarm alarm = alarms[index];
    await flutterLocalNotificationsPlugin.cancel(alarm.id);
    setState(() {
      alarms.removeAt(index);
    });
    _saveAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('شاشة المنبهات'),
      ),
      body: alarms.isEmpty
          ? Center(
        child: Text(
          'لا توجد منبهات. اضغط على زر الإضافة لإضافة منبه جديد.',
          style: TextStyle(fontSize: 18, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          return ListTile(
            leading: Icon(Icons.alarm, color: Colors.blue),
            title: Text(alarm.title),
            subtitle: Text(
                '${alarm.location} - ${alarm.time.format(context)} - ${alarm.isDaily ? "يومي" : "مرة واحدة"}'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteAlarm(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAlarmDialog,
        child: Icon(Icons.add_alarm),
        tooltip: 'إضافة منبه',
      ),
    );
  }
}
