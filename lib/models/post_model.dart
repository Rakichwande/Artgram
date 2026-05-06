import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single artwork post in the feed.
/// Designed to be easily migrated to a FastAPI backend later —
/// just swap the fromMap / toMap calls with your HTTP response parsing.
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
  final bool isLikedByCurrentUser;

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
    this.isLikedByCurrentUser = false,
  });

  /// Create from a Firestore document snapshot
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id:                  doc.id,
      userId:              data['userId']           ?? '',
      username:            data['username']         ?? 'unknown',
      avatarInitials:      data['avatarInitials']   ?? '??',
      imageUrl:            data['imageUrl']         ?? '',
      caption:             data['caption']          ?? '',
      likes:               (data['likes']           ?? 0) as int,
      comments:            (data['comments']        ?? 0) as int,
      timestamp:           (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isLikedByCurrentUser: false,
    );
  }

  /// Serialize to a Map for Firestore / future FastAPI POST body
  Map<String, dynamic> toMap() {
    return {
      'userId':          userId,
      'username':        username,
      'avatarInitials':  avatarInitials,
      'imageUrl':        imageUrl,
      'caption':         caption,
      'likes':           likes,
      'comments':        comments,
      'timestamp':       Timestamp.fromDate(timestamp),
    };
  }

  PostModel copyWith({
    String?   id,
    String?   userId,
    String?   username,
    String?   avatarInitials,
    String?   imageUrl,
    String?   caption,
    int?      likes,
    int?      comments,
    DateTime? timestamp,
    bool?     isLikedByCurrentUser,
  }) {
    return PostModel(
      id:                   id                   ?? this.id,
      userId:               userId               ?? this.userId,
      username:             username             ?? this.username,
      avatarInitials:       avatarInitials       ?? this.avatarInitials,
      imageUrl:             imageUrl             ?? this.imageUrl,
      caption:              caption              ?? this.caption,
      likes:                likes                ?? this.likes,
      comments:             comments             ?? this.comments,
      timestamp:            timestamp            ?? this.timestamp,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }
}