import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:possystem/models/chat_message.dart';
import 'package:possystem/models/xfile.dart';

class ChatService {
  static const String adminEmail = 'evanlu361425@gmail.com';
  static final ChatService instance = ChatService();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ChatService([FirebaseFirestore? firestore, FirebaseAuth? auth, FirebaseStorage? storage])
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Check if current user is admin
  bool get isAdmin => _auth.currentUser?.email == adminEmail;

  /// Get or create a chat room for the current user
  Future<String> getOrCreateRoom() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final userEmail = user.email!;
    
    // If admin, return a general admin room
    if (isAdmin) {
      return 'admin_room';
    }

    // For regular users, create a room with admin
    final roomId = _generateRoomId(userEmail, adminEmail);
    final roomRef = _firestore.collection('chat_rooms').doc(roomId);
    final roomDoc = await roomRef.get();

    if (!roomDoc.exists) {
      await roomRef.set(ChatRoom(
        id: roomId,
        participants: [userEmail, adminEmail],
        lastMessage: '',
        lastMessageAt: DateTime.now(),
      ).toFirestore());
    }

    return roomId;
  }

  /// Generate a consistent room ID for two users
  String _generateRoomId(String email1, String email2) {
    final emails = [email1, email2]..sort();
    return 'room_${emails[0].replaceAll('@', '_at_').replaceAll('.', '_')}_${emails[1].replaceAll('@', '_at_').replaceAll('.', '_')}';
  }

  /// Stream messages for a room
  Stream<List<ChatMessage>> streamMessages(String roomId) {
    return _firestore
        .collection('chat_messages')
        .where('roomId', isEqualTo: roomId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  /// Send a message
  Future<void> sendMessage(String roomId, String text, {XFile? image}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    String? imageUrl;
    if (image != null) {
      imageUrl = await _uploadImage(roomId, image);
    }

    final message = ChatMessage(
      id: '',
      roomId: roomId,
      senderId: user.uid,
      senderEmail: user.email ?? '',
      senderName: user.displayName ?? user.email ?? 'Anonymous',
      text: text,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('chat_messages').add(message.toFirestore());

    // Update room's last message
    final lastMessage = imageUrl != null ? (text.isEmpty ? '📷 Image' : text) : text;
    await _firestore.collection('chat_rooms').doc(roomId).set({
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(DateTime.now()),
      'participants': isAdmin ? [adminEmail] : [user.email!, adminEmail],
    }, SetOptions(merge: true));
  }

  /// Upload image to Firebase Storage
  Future<String> _uploadImage(String roomId, XFile image) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${user.uid}_$timestamp.jpg';
    final ref = _storage.ref().child('chat_images').child(roomId).child(fileName);

    await ref.putFile(image.file);
    return await ref.getDownloadURL();
  }

  /// Get all rooms for admin
  Stream<List<ChatRoom>> streamAdminRooms() {
    if (!isAdmin) {
      return Stream.value([]);
    }

    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: adminEmail)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList());
  }
}
