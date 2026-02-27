import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/services/storage/user_session_service.dart';
import 'package:sewa_hub/features/chat/presentation/state/chat_state.dart';
import 'package:sewa_hub/features/chat/presentation/view_model/chat_view_model.dart';
import 'package:sewa_hub/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:sewa_hub/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:sewa_hub/features/chat/presentation/widgets/date_separator.dart';
import 'package:sewa_hub/features/chat/presentation/widgets/typing_indicator.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String bookingId;
  final String providerName;
  final String? providerImage;
  final bool readOnly; // true for completed/cancelled/rejected

  const ChatPage({
    super.key,
    required this.bookingId,
    required this.providerName,
    this.providerImage,
    this.readOnly = false,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _scrollController = ScrollController();
  Timer? _typingTimer;
  String _currentUserId = '';

  static const _orange = Color(0xFFFF6B35);

  ChatViewModel get _vm =>
      ref.read(chatViewModelProvider(widget.bookingId).notifier);

  @override
  void initState() {
    super.initState();
    _currentUserId = ref.read(userSessionServiceProvider).userId ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.readOnly) {
        _vm.initSocket();
      }
      _vm.loadMessages();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 100) {
        _vm.loadMessages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTyping(String value) {
    _vm.startTyping();
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () => _vm.stopTyping());
  }

  String _avatarUrl(String? img) {
    if (img == null || img.isEmpty) return '';
    if (img.startsWith('http')) return img;
    return 'http://10.0.2.2:5050$img';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider(widget.bookingId));

    ref.listen(chatViewModelProvider(widget.bookingId), (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Read-only banner
          if (widget.readOnly)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF1F5F9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline_rounded,
                      size: 13, color: Color(0xFF94A3B8)),
                  SizedBox(width: 6),
                  Text(
                    'This conversation is read-only',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),

          Expanded(child: _buildMessageList(chatState)),

          if (!widget.readOnly) ...[
            if (chatState.isPartnerTyping) const TypingIndicator(),
            ChatInputBar(
              isSending: chatState.isSending,
              onTyping: _onTyping,
              onSend: (content) => _vm.sendMessage(content),
            ),
          ],
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final avatarUrl = _avatarUrl(widget.providerImage);
    final initials = _initials(widget.providerName);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            size: 18, color: Color(0xFF0F172A)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFF3EE),
              border: Border.all(color: const Color(0xFFFFDDCC)),
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarUrl.isNotEmpty
                ? Image.network(avatarUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(initials,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _orange)),
                    ))
                : Center(
                    child: Text(initials,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _orange))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.providerName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                Text(
                  widget.readOnly ? 'Conversation ended' : 'Service Provider',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          if (widget.readOnly)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.lock_outline_rounded,
                  size: 16, color: Color(0xFF94A3B8)),
            ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: Color(0xFFE2E8F0)),
      ),
    );
  }

  Widget _buildMessageList(ChatState state) {
    if (state.status == ChatStatus.loading && state.messages.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: _orange));
    }

    if (state.status == ChatStatus.error && state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(state.errorMessage ?? 'Something went wrong',
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _vm.loadMessages(refresh: true),
              child: const Text('Retry',
                  style: TextStyle(color: _orange)),
            ),
          ],
        ),
      );
    }

    if (state.messages.isEmpty) return _buildEmptyState();

    final messages = state.messages;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.sender.id == _currentUserId;

        final showDateSeparator = index == 0 ||
            !_isSameDay(messages[index - 1].createdAt, message.createdAt);
        final showAvatar = !isMe &&
            (index == messages.length - 1 ||
                messages[index + 1].sender.id != message.sender.id);

        return Column(
          children: [
            if (showDateSeparator) DateSeparator(date: message.createdAt),
            ChatBubble(
                message: message, isMe: isMe, showAvatar: showAvatar),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 36, color: _orange),
          ),
          const SizedBox(height: 16),
          const Text('No messages yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Start a conversation with your\nservice provider',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}