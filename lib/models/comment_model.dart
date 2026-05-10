import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String avatarInitials;
  final String text;
  final DateTime timestamp;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.avatarInitials,
    required this.text,
    required this.timestamp,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id:             doc.id,
      postId:         d['postId']          ?? '',
      userId:         d['userId']          ?? '',
      username:       d['username']        ?? 'unknown',
      avatarInitials: d['avatarInitials']  ?? '??',
      text:           d['text']            ?? '',
      timestamp:      (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'postId':         postId,
    'userId':         userId,
    'username':       username,
    'avatarInitials': avatarInitials,
    'text':           text,
    'timestamp':      Timestamp.fromDate(timestamp),
  };
}
