import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/chat_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
// import 'chat_room_screen.dart'; // TODO: Create chat room screen

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    if (authProvider.userModel != null) {
      await chatProvider.loadChatRooms(authProvider.userModel!.userId);
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: Consumer2<ChatProvider, AuthProvider>(
        builder: (context, chatProvider, authProvider, child) {
          if (_isLoading || chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authProvider.userModel;
          if (user == null) {
            return const Center(child: Text('Please log in to view messages'));
          }

          final filteredChatRooms = _getFilteredChatRooms(chatProvider.chatRooms);

          if (filteredChatRooms.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadChatRooms,
            child: Column(
              children: [
                if (_searchQuery.isNotEmpty) _buildSearchHeader(),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredChatRooms.length,
                    itemBuilder: (context, index) {
                      final chatRoom = filteredChatRooms[index];
                      return _buildChatRoomItem(chatRoom, user.userId);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Searching for "$_searchQuery"',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
            },
            child: const Icon(Icons.close, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No messages found' : 'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Try adjusting your search terms'
                : 'Start chatting by applying to jobs',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatRoomItem(ChatRoom chatRoom, String currentUserId) {
    final isUnread = chatRoom.unreadCount > 0;
    final otherParticipantName = chatRoom.clinicId == currentUserId 
        ? chatRoom.applicantName 
        : chatRoom.clinicName;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: isUnread ? 2 : 1,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1976D2),
              child: Text(
                otherParticipantName.isNotEmpty 
                    ? otherParticipantName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    chatRoom.unreadCount > 99 ? '99+' : chatRoom.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                otherParticipantName,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (chatRoom.lastMessage != null)
              Text(
                _formatMessageTime(chatRoom.lastMessage!.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: isUnread ? const Color(0xFF1976D2) : Colors.grey[600],
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatRoom.jobTitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (chatRoom.lastMessage != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (chatRoom.lastMessage!.senderId == currentUserId)
                    Icon(
                      _getMessageStatusIcon(chatRoom.lastMessage!.status),
                      size: 16,
                      color: _getMessageStatusColor(chatRoom.lastMessage!.status),
                    ),
                  if (chatRoom.lastMessage!.senderId == currentUserId)
                    const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getLastMessagePreview(chatRoom.lastMessage!),
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnread ? Colors.black : Colors.grey[600],
                        fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        onTap: () => _openChatRoom(chatRoom),
        trailing: isUnread 
            ? const Icon(Icons.circle, color: Colors.red, size: 8)
            : null,
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Messages'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by name or job title...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text.trim();
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _openChatRoom(ChatRoom chatRoom) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    // Mark messages as read
    if (authProvider.userModel != null) {
      await chatProvider.markMessagesAsRead(
        chatRoom.chatRoomId, 
        authProvider.userModel!.userId,
      );
    }
    
    if (mounted) {
      // TODO: Navigate to chat room screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat feature coming soon!')),
      );
    }
  }

  List<ChatRoom> _getFilteredChatRooms(List<ChatRoom> chatRooms) {
    if (_searchQuery.isEmpty) {
      return chatRooms;
    }
    
    final query = _searchQuery.toLowerCase();
    return chatRooms.where((chatRoom) {
      return chatRoom.clinicName.toLowerCase().contains(query) ||
             chatRoom.applicantName.toLowerCase().contains(query) ||
             chatRoom.jobTitle.toLowerCase().contains(query);
    }).toList();
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEE').format(timestamp);
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  IconData _getMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  Color _getMessageStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Colors.grey;
      case MessageStatus.delivered:
        return Colors.grey;
      case MessageStatus.read:
        return const Color(0xFF1976D2);
      case MessageStatus.failed:
        return Colors.red;
    }
  }

  String _getLastMessagePreview(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return message.content;
      case MessageType.image:
        return '📷 Image';
      case MessageType.file:
        return '📎 File';
      case MessageType.voice:
        return '🎤 Voice message';
      case MessageType.appointment:
        return '📅 Appointment';
      case MessageType.system:
        return message.content;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 