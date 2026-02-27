import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sewa_hub/core/widgets/dotted_background.dart';
import 'package:sewa_hub/features/booking/data/repositories/booking_repository.dart';
import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';
import 'package:sewa_hub/features/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'package:sewa_hub/features/chat/presentation/pages/chat_page.dart';

class _ChatConversation {
  final BookingEntity booking;
  _ChatConversation({required this.booking});
}

final _conversationsProvider =
    FutureProvider<List<_ChatConversation>>((ref) async {
  final bookingRepo = ref.read(bookingRepositoryProvider);
  final chatSource = ref.read(chatRemoteDataSourceProvider);

  final bookingsResult = await bookingRepo.getMyBookings();
  final bookings = bookingsResult.fold((_) => <BookingEntity>[], (l) => l);
  if (bookings.isEmpty) return [];

  final conversations = await Future.wait(
    bookings.map((b) async {
      if (b.id == null) return null;
      final result =
          await chatSource.getMessages(bookingId: b.id!, page: 1, size: 1);
      final hasMessages = result.fold((_) => false, (msgs) => msgs.isNotEmpty);
      if (!hasMessages) return null;
      return _ChatConversation(booking: b);
    }),
  );

  final filtered = conversations.whereType<_ChatConversation>().toList();
  filtered.sort((a, b) {
    final aActive = _isActive(a.booking.status) ? 0 : 1;
    final bActive = _isActive(b.booking.status) ? 0 : 1;
    if (aActive != bActive) return aActive - bActive;
    return b.booking.scheduledAt.compareTo(a.booking.scheduledAt);
  });

  return filtered;
});

bool _isActive(String status) =>
    status == 'pending' || status == 'accepted';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  static const _orange = Color(0xFFFF6B35);

  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _providerName(BookingEntity b) {
    if (b.provider is Map) {
      final user = (b.provider as Map)['Useruser_id'];
      if (user is Map) return user['fullname']?.toString() ?? 'Provider';
    }
    return 'Provider';
  }

  String _providerImage(BookingEntity b) {
    if (b.provider is Map) {
      final user = (b.provider as Map)['Useruser_id'];
      if (user is Map) {
        final img = user['imageUrl']?.toString() ?? '';
        if (img.isEmpty) return '';
        if (img.startsWith('http')) return img;
        return 'http://10.0.2.2:5050$img';
      }
    }
    return '';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  List<_ChatConversation> _applySearch(List<_ChatConversation> conversations) {
    if (_searchQuery.isEmpty) return conversations;
    return conversations.where((c) {
      final name = _providerName(c.booking).toLowerCase();
      final address = c.booking.address.toLowerCase();
      return name.contains(_searchQuery) || address.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(_conversationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: DottedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ─────────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Messages',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        conversationsAsync.when(
                          data: (c) => c.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3EE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('${c.length}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _orange)),
                                )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Search bar
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.toLowerCase()),
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: 'Search provider or address...',
                          hintStyle: const TextStyle(
                              fontSize: 13, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded,
                              size: 18, color: Color(0xFF94A3B8)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  child: const Icon(Icons.close_rounded,
                                      size: 16, color: Color(0xFF94A3B8)),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // ── List ───────────────────────────────────────────────
              Expanded(
                child: conversationsAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: _orange)),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            size: 48, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        const Text('Failed to load conversations',
                            style:
                                TextStyle(color: Color(0xFF64748B))),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              ref.refresh(_conversationsProvider),
                          child: const Text('Retry',
                              style: TextStyle(color: _orange)),
                        ),
                      ],
                    ),
                  ),
                  data: (conversations) {
                    final results = _applySearch(conversations);

                    if (conversations.isEmpty) return _buildEmptyState();

                    if (results.isEmpty) {
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
                              child: const Icon(Icons.search_off_rounded,
                                  size: 36, color: _orange),
                            ),
                            const SizedBox(height: 16),
                            const Text('No results found',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            const Text('Try a different search',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A3B8))),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: _orange,
                      onRefresh: () =>
                          ref.refresh(_conversationsProvider.future),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        itemCount: results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final conv = results[index];
                          final booking = conv.booking;
                          final name = _providerName(booking);
                          final isActive = _isActive(booking.status);

                          return _ConversationTile(
                            booking: booking,
                            providerName: name,
                            providerImage: _providerImage(booking),
                            initials: _initials(name),
                            isActive: isActive,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  bookingId: booking.id!,
                                  providerName: name,
                                  providerImage: _providerImage(booking),
                                  readOnly: !isActive,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EE),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 38, color: _orange),
          ),
          const SizedBox(height: 16),
          const Text('No conversations yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Messages with providers will\nappear here',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final BookingEntity booking;
  final String providerName;
  final String providerImage;
  final String initials;
  final bool isActive;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.booking,
    required this.providerName,
    required this.providerImage,
    required this.initials,
    required this.isActive,
    required this.onTap,
  });

  static const _orange = Color(0xFFFF6B35);

  Color get _statusColor {
    switch (booking.status) {
      case 'accepted':  return const Color(0xFF22C55E);
      case 'pending':   return const Color(0xFFF59E0B);
      case 'completed': return const Color(0xFF3B82F6);
      case 'rejected':  return const Color(0xFFEF4444);
      case 'cancelled': return const Color(0xFF64748B);
      default:          return const Color(0xFF64748B);
    }
  }

  String get _statusLabel =>
      booking.status[0].toUpperCase() + booking.status.substring(1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: const Color(0xFFFFDDCC), width: 1.5)
              : null,
          boxShadow: const [
            BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFF3EE),
                    border: Border.all(color: const Color(0xFFFFDDCC)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: providerImage.isNotEmpty
                      ? Image.network(providerImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(initials,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _orange)),
                          ))
                      : Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _orange))),
                ),
                if (isActive)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(providerName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A))),
                      Text(
                        DateFormat('MMM d').format(booking.scheduledAt),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(_statusLabel,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _statusColor)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking.address,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!isActive)
              const Icon(Icons.lock_outline_rounded,
                  size: 16, color: Color(0xFFCBD5E1))
            else
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}