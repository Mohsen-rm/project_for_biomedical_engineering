// lib/models/alarm.dart

import 'package:flutter/material.dart';

class Alarm {
  final int id;
  final String title;
  final String location;
  final TimeOfDay time;
  final bool isDaily;
  final String audioPath;

  Alarm({
    required this.id,
    required this.title,
    required this.location,
    required this.time,
    required this.isDaily,
    required this.audioPath,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      isDaily: json['isDaily'],
      audioPath: json['audioPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'hour': time.hour,
      'minute': time.minute,
      'isDaily': isDaily,
      'audioPath': audioPath,
    };
  }
}
