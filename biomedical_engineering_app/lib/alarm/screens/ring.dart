import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart';

class ExampleAlarmRingScreen extends StatefulWidget {
  const ExampleAlarmRingScreen({required this.alarmSettings, super.key});

  final AlarmSettings alarmSettings;

  @override
  _ExampleAlarmRingScreenState createState() => _ExampleAlarmRingScreenState();
}

class _ExampleAlarmRingScreenState extends State<ExampleAlarmRingScreen> {
  FlutterSoundPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = FlutterSoundPlayer();
    _initPlayer();
    _startAlarm();
  }

  Future<void> _initPlayer() async {
    await _audioPlayer!.openPlayer();
  }

  Future<void> _startAlarm() async {
    String? audioPath = widget.alarmSettings.assetAudioPath;

    if (audioPath != null) {
      if (audioPath.startsWith('/')) {
        // إذا كان مسار ملف (الصوت المسجل)
        await _audioPlayer!.startPlayer(
          fromURI: audioPath,
          whenFinished: () {
            if (widget.alarmSettings.loopAudio) {
              _startAlarm();
            }
          },
        );
      } else {
        // إذا كان من الأصول (الصوت الافتراضي)
        ByteData audioData = await rootBundle.load(audioPath);
        await _audioPlayer!.startPlayer(
          fromDataBuffer: audioData.buffer.asUint8List(),
          whenFinished: () {
            if (widget.alarmSettings.loopAudio) {
              _startAlarm();
            }
          },
        );
      }
    }
  }

  void snoozeAlarm() {
    final now = DateTime.now();
    Alarm.set(
      alarmSettings: widget.alarmSettings.copyWith(
        dateTime: DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute,
        ).add(const Duration(minutes: 1)),
      ),
    ).then((_) {
      if (context.mounted) Navigator.pop(context);
    });
  }

  void stopAlarm() {
    Alarm.stop(widget.alarmSettings.id).then((_) {
      if (context.mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _audioPlayer!.stopPlayer();
    _audioPlayer!.closePlayer();
    _audioPlayer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // واجهة المستخدم مع النصوص المترجمة
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'المنبه (${widget.alarmSettings.id}) يرن...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text('🔔', style: TextStyle(fontSize: 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(
                  onPressed: snoozeAlarm,
                  child: Text(
                    'غفوة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                RawMaterialButton(
                  onPressed: stopAlarm,
                  child: Text(
                    'إيقاف',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
