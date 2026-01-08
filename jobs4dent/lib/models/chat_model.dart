import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  file,
  voice,
  appointment,
  system,
}

enum MessageStatus {
  sent,
  delivered,
  read,
  failed,
}

class ChatMessage {
  final String messageId;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String senderType; // 'clinic', 'dentist', 'assistant'
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? fileUrl;
  final String? fileName;
  final String? fileType;
  final int? fileSize;
  final Map<String, dynamic>? metadata;
  final String? replyToMessageId;
  final bool isEdited;
  final DateTime? editedAt;

  ChatMessage({
    required this.messageId,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.fileSize,
    this.metadata,
    this.replyToMessageId,
    this.isEdited = false,
    this.editedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'metadata': metadata,
      'replyToMessageId': replyToMessageId,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      messageId: map['messageId'] ?? '',
      chatRoomId: map['chatRoomId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderType: map['senderType'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      fileType: map['fileType'],
      fileSize: map['fileSize'],
      metadata: map['metadata'],
      replyToMessageId: map['replyToMessageId'],
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] != null ? (map['editedAt'] as Timestamp).toDate() : null,
    );
  }

  ChatMessage copyWith({
    String? messageId,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? senderType,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSize,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
    bool? isEdited,
    DateTime? editedAt,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      metadata: metadata ?? this.metadata,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}

class ChatRoom {
  final String chatRoomId;
  final String jobId;
  final String jobTitle;
  final String clinicId;
  final String clinicName;
  final String applicantId;
  final String applicantName;
  final DateTime createdAt;
  final DateTime lastActivity;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final List<String> participants;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  ChatRoom({
    required this.chatRoomId,
    required this.jobId,
    required this.jobTitle,
    required this.clinicId,
    required this.clinicName,
    required this.applicantId,
    required this.applicantName,
    required this.createdAt,
    required this.lastActivity,
    this.lastMessage,
    this.unreadCount = 0,
    required this.participants,
    this.isActive = true,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActivity': Timestamp.fromDate(lastActivity),
      'lastMessage': lastMessage?.toMap(),
      'unreadCount': unreadCount,
      'participants': participants,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      chatRoomId: map['chatRoomId'] ?? '',
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      clinicId: map['clinicId'] ?? '',
      clinicName: map['clinicName'] ?? '',
      applicantId: map['applicantId'] ?? '',
      applicantName: map['applicantName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastActivity: (map['lastActivity'] as Timestamp).toDate(),
      lastMessage: map['lastMessage'] != null ? ChatMessage.fromMap(map['lastMessage']) : null,
      unreadCount: map['unreadCount'] ?? 0,
      participants: List<String>.from(map['participants'] ?? []),
      isActive: map['isActive'] ?? true,
      metadata: map['metadata'],
    );
  }

  ChatRoom copyWith({
    String? chatRoomId,
    String? jobId,
    String? jobTitle,
    String? clinicId,
    String? clinicName,
    String? applicantId,
    String? applicantName,
    DateTime? createdAt,
    DateTime? lastActivity,
    ChatMessage? lastMessage,
    int? unreadCount,
    List<String>? participants,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return ChatRoom(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      participants: participants ?? this.participants,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}

class TypingIndicator {
  final String userId;
  final String userName;
  final DateTime timestamp;

  TypingIndicator({
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory TypingIndicator.fromMap(Map<String, dynamic> map) {
    return TypingIndicator(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  bool get isExpired {
    return DateTime.now().difference(timestamp).inSeconds > 5;
  }
} 