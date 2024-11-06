import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  String? title;
  String? description;
  var createdAt;
  String? timestamp;
  bool? is_read;

  NotificationModel(
      {this.title,
      this.description,
      this.createdAt,
      this.timestamp,
      this.is_read});

  factory NotificationModel.fromFirestore(
      DocumentSnapshot snapshot, BuildContext context) {
    Map d = snapshot.data() as Map<dynamic, dynamic>;
    String locale = context.locale.languageCode;
    return NotificationModel(
        title: d['title'],
        description: d['description'],
        createdAt: DateFormat('d MMM, y', locale)
            .format(DateTime.parse(d['created_at'].toDate().toString())),
        timestamp: d['timestamp'],
        is_read: d['is_read']);
  }

  @override
  String toString() {
    return 'NotificationModel{title: $title, description: $description, createdAt: $createdAt, timestamp: $timestamp, is_read: $is_read}';
  }
}
