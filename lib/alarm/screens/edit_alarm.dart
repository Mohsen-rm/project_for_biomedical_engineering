import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class ExampleAlarmEditScreen extends StatefulWidget {
  const ExampleAlarmEditScreen({super.key, this.alarmSettings});

  final AlarmSettings? alarmSettings;

  @override
  State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
}

class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
  bool loading = false;

  late bool creating;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;

  // المتغيرات الجديدة لتسجيل الصوت
  FlutterSoundRecorder? _audioRecorder;
  String? recordedFilePath;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    creating = widget.alarmSettings == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = null;
      assetAudio = 'assets/marimba.mp3';
    } else {
      selectedDateTime = widget.alarmSettings!.dateTime;
      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      volume = widget.alarmSettings!.volume;
      assetAudio = widget.alarmSettings!.assetAudioPath;
    }

    _audioRecorder = FlutterSoundRecorder();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _audioRecorder!.openRecorder();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('الميكروفون غير مسموح به');
    }
  }

  @override
  void dispose() {
    _audioRecorder!.closeRecorder();
    _audioRecorder = null;
    super.dispose();
  }

  Future<void> startRecording() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/my_alarm_sound.aac';

    await _audioRecorder!.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );

    setState(() {
      isRecording = true;
      recordedFilePath = filePath;
    });
  }

  Future<void> stopRecording() async {
    await _audioRecorder!.stopRecorder();
    setState(() {
      isRecording = false;
    });
  }

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    switch (difference) {
      case 0:
        return 'اليوم';
      case 1:
        return 'غدًا';
      case 2:
        return 'بعد غد';
      default:
        return 'بعد $difference أيام';
    }
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final now = DateTime.now();
        selectedDateTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
      });
    }
  }

  AlarmSettings buildAlarmSettings() {
    final id = creating
        ? DateTime.now().millisecondsSinceEpoch % 10000 + 1
        : widget.alarmSettings!.id;

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: selectedDateTime,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: recordedFilePath ?? assetAudio,
      warningNotificationOnKill: Platform.isIOS,
      notificationSettings: NotificationSettings(
        title: 'منبه',
        body: 'منبهك ($id) يرن',
        stopButton: 'إيقاف المنبه',
        icon: 'notification_icon',
      ),
    );
    return alarmSettings;
  }

  void saveAlarm() {
    if (loading) return;
    setState(() => loading = true);
    Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
      if (res && mounted) Navigator.pop(context, true);
      setState(() => loading = false);
    });
  }

  void deleteAlarm() {
    Alarm.stop(widget.alarmSettings!.id).then((res) {
      if (res && mounted) Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // شريط العنوان
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'إلغاء',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blueAccent),
                  ),
                ),
                TextButton(
                  onPressed: saveAlarm,
                  child: loading
                      ? const CircularProgressIndicator()
                      : Text(
                    'حفظ',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
            // اليوم
            Text(
              getDay(),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
            ),
            // اختيار الوقت
            RawMaterialButton(
              onPressed: pickTime,
              fillColor: Colors.grey[200],
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Text(
                  TimeOfDay.fromDateTime(selectedDateTime).format(context),
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(color: Colors.blueAccent),
                ),
              ),
            ),
            // خيارات المنبه
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تكرار صوت المنبه',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: loopAudio,
                  onChanged: (value) => setState(() => loopAudio = value),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'اهتزاز',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: vibrate,
                  onChanged: (value) => setState(() => vibrate = value),
                ),
              ],
            ),
            // عناصر التحكم في تسجيل الصوت
            SizedBox(height: 20),
            Text(
              'تسجيل الصوت',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: isRecording ? null : startRecording,
                  child: Text('بدء التسجيل'),
                ),
                ElevatedButton(
                  onPressed: isRecording ? stopRecording : null,
                  child: Text('إيقاف التسجيل'),
                ),
              ],
            ),
            if (recordedFilePath != null)
              Text(
                'تم تسجيل الصوت بنجاح',
                style: TextStyle(color: Colors.green),
              ),
            SizedBox(height: 20),
            // اختيار الصوت من الأصول (في حالة عدم تسجيل صوت)
            if (recordedFilePath == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الصوت',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  DropdownButton(
                    value: assetAudio,
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'assets/marimba.mp3',
                        child: Text('Marimba'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'assets/nokia.mp3',
                        child: Text('Nokia'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'assets/mozart.mp3',
                        child: Text('Mozart'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'assets/star_wars.mp3',
                        child: Text('Star Wars'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'assets/one_piece.mp3',
                        child: Text('One Piece'),
                      ),
                    ],
                    onChanged: (value) => setState(() => assetAudio = value!),
                  ),
                ],
              ),
            // مستوى الصوت
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مستوى صوت مخصص',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: volume != null,
                  onChanged: (value) =>
                      setState(() => volume = value ? 0.5 : null),
                ),
              ],
            ),
            if (volume != null)
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      volume! > 0.7
                          ? Icons.volume_up_rounded
                          : volume! > 0.1
                          ? Icons.volume_down_rounded
                          : Icons.volume_mute_rounded,
                    ),
                    Expanded(
                      child: Slider(
                        value: volume!,
                        onChanged: (value) {
                          setState(() => volume = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            // زر حذف المنبه
            if (!creating)
              TextButton(
                onPressed: deleteAlarm,
                child: Text(
                  'حذف المنبه',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
