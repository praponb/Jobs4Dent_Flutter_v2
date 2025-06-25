import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _messages = [];
  final Map<String, StreamSubscription> _messageSubscriptions = {};
  bool _isLoading = false;
  String? _error;
  String? _currentChatRoomId;

  // Getters
  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentChatRoomId => _currentChatRoomId;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load chat rooms for a user
  Future<void> loadChatRooms(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .orderBy('lastActivity', descending: true)
          .get();

      _chatRooms = querySnapshot.docs
          .map((doc) => ChatRoom.fromMap({
                ...doc.data(),
                'chatRoomId': doc.id,
              }))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load chat rooms: $e');
      debugPrint('Error loading chat rooms: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create or get existing chat room
  Future<String?> createOrGetChatRoom({
    required String jobId,
    required String jobTitle,
    required String clinicId,
    required String clinicName,
    required String applicantId,
    required String applicantName,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Check if conversation already exists
      final existingQuery = await _firestore
          .collection('conversations')
          .where('jobId', isEqualTo: jobId)
          .where('clinicId', isEqualTo: clinicId)
          .where('applicantId', isEqualTo: applicantId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        final chatRoomId = existingQuery.docs.first.id;
        _currentChatRoomId = chatRoomId;
        return chatRoomId;
      }

      // Create new conversation
      final conversationId = const Uuid().v4();
      final chatRoom = ChatRoom(
        chatRoomId: conversationId,
        jobId: jobId,
        jobTitle: jobTitle,
        clinicId: clinicId,
        clinicName: clinicName,
        applicantId: applicantId,
        applicantName: applicantName,
        createdAt: DateTime.now(),
        lastActivity: DateTime.now(),
        participants: [clinicId, applicantId],
      );

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .set(chatRoom.toMap());

      _chatRooms.insert(0, chatRoom);
      _currentChatRoomId = conversationId;
      notifyListeners();

      return conversationId;
    } catch (e) {
      _setError('Failed to create chat room: $e');
      debugPrint('Error creating chat room: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Load messages for a chat room with real-time updates
  void loadMessages(String chatRoomId) {
    _currentChatRoomId = chatRoomId;
    
    // Cancel existing subscription
    _messageSubscriptions[chatRoomId]?.cancel();
    
    // Create new subscription
    _messageSubscriptions[chatRoomId] = _firestore
        .collection('conversations')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (snapshot) {
        _messages = snapshot.docs
            .map((doc) => ChatMessage.fromMap({
                  ...doc.data(),
                  'messageId': doc.id,
                }))
            .toList();
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load messages: $error');
        debugPrint('Error loading messages: $error');
      },
    );
  }

  // Send a text message
  Future<bool> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String senderType,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final messageId = const Uuid().v4();
      
      final message = ChatMessage(
        messageId: messageId,
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderName: senderName,
        senderType: senderType,
        content: content,
        type: type,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
        replyToMessageId: replyToMessageId,
        metadata: metadata,
      );

      // Add message to Firestore
      await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      // Update conversation last activity
      await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .update({
        'lastActivity': Timestamp.fromDate(DateTime.now()),
        'lastMessage': message.toMap(),
      });

      return true;
    } catch (e) {
      _setError('Failed to send message: $e');
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  // Send a file message
  Future<bool> sendFileMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String senderType,
    required File file,
    required String fileName,
    String? content,
    MessageType type = MessageType.file,
  }) async {
    try {
      _setLoading(true);
      
      // Upload file to Firebase Storage
      final storageRef = _storage
          .ref()
          .child('chat_files')
          .child(chatRoomId)
          .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Get file metadata
      final fileMetadata = await uploadTask.ref.getMetadata();
      final fileSize = fileMetadata.size ?? 0;

      // Send message with file
      final messageId = const Uuid().v4();
      
      final message = ChatMessage(
        messageId: messageId,
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderName: senderName,
        senderType: senderType,
        content: content ?? fileName,
        type: type,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
        fileUrl: downloadUrl,
        fileName: fileName,
        fileType: _getFileType(fileName),
        fileSize: fileSize,
      );

      await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      // Update conversation last activity
      await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .update({
        'lastActivity': Timestamp.fromDate(DateTime.now()),
        'lastMessage': message.toMap(),
      });

      return true;
    } catch (e) {
      _setError('Failed to send file: $e');
      debugPrint('Error sending file: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      final batch = _firestore.batch();
      
      final unreadMessages = await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('status', isNotEqualTo: MessageStatus.read.name)
          .get();

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'status': MessageStatus.read.name});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Send typing indicator
  Future<void> sendTypingIndicator(String chatRoomId, String userId, String userName) async {
    try {
      final typingIndicator = TypingIndicator(
        userId: userId,
        userName: userName,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('typing')
          .doc(userId)
          .set(typingIndicator.toMap());

      // Auto-remove typing indicator after 5 seconds
      Timer(const Duration(seconds: 5), () {
        removeTypingIndicator(chatRoomId, userId);
      });
    } catch (e) {
      debugPrint('Error sending typing indicator: $e');
    }
  }

  // Remove typing indicator
  Future<void> removeTypingIndicator(String chatRoomId, String userId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('typing')
          .doc(userId)
          .delete();
    } catch (e) {
      debugPrint('Error removing typing indicator: $e');
    }
  }

  // Listen to typing indicators
  Stream<List<TypingIndicator>> getTypingIndicators(String chatRoomId) {
    return _firestore
        .collection('conversations')
        .doc(chatRoomId)
        .collection('typing')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TypingIndicator.fromMap(doc.data()))
            .where((indicator) => !indicator.isExpired)
            .toList());
  }

  // Edit a message
  Future<bool> editMessage(String chatRoomId, String messageId, String newContent) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'content': newContent,
        'isEdited': true,
        'editedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      _setError('Failed to edit message: $e');
      debugPrint('Error editing message: $e');
      return false;
    }
  }

  // Delete a message
  Future<bool> deleteMessage(String chatRoomId, String messageId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();

      return true;
    } catch (e) {
      _setError('Failed to delete message: $e');
      debugPrint('Error deleting message: $e');
      return false;
    }
  }

  // Search messages
  Future<List<ChatMessage>> searchMessages(String chatRoomId, String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('content')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => ChatMessage.fromMap({
                ...doc.data(),
                'messageId': doc.id,
              }))
          .toList();
    } catch (e) {
      _setError('Failed to search messages: $e');
      debugPrint('Error searching messages: $e');
      return [];
    }
  }

  // Get unread message count for a conversation
  Future<int> getUnreadCount(String chatRoomId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('status', isNotEqualTo: MessageStatus.read.name)
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  // Get total unread count for user
  Future<int> getTotalUnreadCount(String userId) async {
    try {
      int totalUnread = 0;
      
      for (final chatRoom in _chatRooms) {
        final unreadCount = await getUnreadCount(chatRoom.chatRoomId, userId);
        totalUnread += unreadCount;
      }
      
      return totalUnread;
    } catch (e) {
      debugPrint('Error getting total unread count: $e');
      return 0;
    }
  }

  // Helper method to get file type from filename
  String _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'image';
    } else if (['pdf'].contains(extension)) {
      return 'pdf';
    } else if (['doc', 'docx'].contains(extension)) {
      return 'document';
    } else if (['mp3', 'wav', 'aac'].contains(extension)) {
      return 'audio';
    } else if (['mp4', 'mov', 'avi'].contains(extension)) {
      return 'video';
    } else {
      return 'file';
    }
  }

  // Load more messages (pagination)
  Future<void> loadMoreMessages(String chatRoomId, {DateTime? before}) async {
    try {
      Query query = _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true);

      if (before != null) {
        query = query.startAfter([Timestamp.fromDate(before)]);
      }

      final querySnapshot = await query.limit(20).get();

      final moreMessages = querySnapshot.docs
          .map((doc) => ChatMessage.fromMap({
                ...doc.data() as Map<String, dynamic>,
                'messageId': doc.id,
              }))
          .toList();

      _messages.addAll(moreMessages);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load more messages: $e');
      debugPrint('Error loading more messages: $e');
    }
  }

  // Close chat room
  void closeChatRoom() {
    _currentChatRoomId = null;
    _messages.clear();
    
    // Cancel all message subscriptions
    for (final subscription in _messageSubscriptions.values) {
      subscription.cancel();
    }
    _messageSubscriptions.clear();
    
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _chatRooms.clear();
    _messages.clear();
    _currentChatRoomId = null;
    _error = null;
    
    // Cancel all subscriptions
    for (final subscription in _messageSubscriptions.values) {
      subscription.cancel();
    }
    _messageSubscriptions.clear();
    
    notifyListeners();
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _messageSubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }
} 