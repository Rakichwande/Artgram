import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String avatarInitials;
  final String imageUrl;
  final String caption;
  final int likes;
  final int comments;
  final DateTime timestamp;
  final List<String> tags;
  final List<String> likedBy; // tracks who liked — prevents double likes

  const PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatarInitials,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.timestamp,
    this.tags    = const [],
    this.likedBy = const [],
  });

  bool isLikedBy(String userId) => likedBy.contains(userId);

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PostModel(
      id:             doc.id,
      userId:         d['userId']          ?? '',
      username:       d['username']        ?? 'unknown',
      avatarInitials: d['avatarInitials']  ?? '??',
      imageUrl:       d['imageUrl']        ?? '',
      caption:        d['caption']         ?? '',
      likes:          (d['likes']          ?? 0) as int,
      comments:       (d['comments']       ?? 0) as int,
      timestamp:      (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags:           List<String>.from(d['tags']    ?? []),
      likedBy:        List<String>.from(d['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId':         userId,
    'username':       username,
    'avatarInitials': avatarInitials,
    'imageUrl':       imageUrl,
    'caption':        caption,
    'likes':          likes,
    'comments':       comments,
    'timestamp':      Timestamp.fromDate(timestamp),
    'tags':           tags,
    'likedBy':        likedBy,
  };
}
