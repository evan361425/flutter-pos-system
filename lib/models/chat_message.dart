import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderEmail;
  final String senderName;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderEmail,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      roomId: data['roomId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderEmail: data['senderEmail'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class ChatRoom {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageAt;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
    };
  }
}
