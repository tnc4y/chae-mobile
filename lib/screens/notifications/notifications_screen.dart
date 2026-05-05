import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/context_colors.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchAll();
      if (mounted) setState(() => _notifications = data);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    await _service.markAllRead();
    setState(() {
      _notifications = _notifications
          .map((n) => NotificationModel(
                id: n.id,
                type: n.type,
                title: n.title,
                message: n.message,
                data: n.data,
                isRead: true,
                createdAt: n.createdAt,
              ))
          .toList();
    });
  }

  Future<void> _markRead(String id) async {
    await _service.markRead(id);
    setState(() {
      _notifications = _notifications
          .map((n) => n.id == id
              ? NotificationModel(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  message: n.message,
                  data: n.data,
                  isRead: true,
                  createdAt: n.createdAt,
                )
              : n)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Tümünü Oku'),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: colors.primary,
        onRefresh: _load,
        child: _buildBody(colors),
      ),
    );
  }

  Widget _buildBody(c) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    if (_notifications.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: c.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 40,
                    color: c.outline,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Bildirim yok',
                  style: TextStyle(
                    color: c.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yeni bölüm bildirimleri burada görünecek.',
                  style: TextStyle(color: c.onSurfaceDim),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: _notifications.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 72,
        color: c.outlineVariant,
      ),
      itemBuilder: (_, i) => _NotificationTile(
        notification: _notifications[i],
        onTap: () => _markRead(_notifications[i].id),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  IconData get _icon => switch (notification.type) {
        'new_chapter' => Icons.menu_book_rounded,
        'comment_reply' => Icons.reply_rounded,
        'comment_like' => Icons.favorite_rounded,
        'system' => Icons.campaign_rounded,
        _ => Icons.notifications_rounded,
      };

  Color _iconColor(BuildContext context) {
    final c = context.colors;
    return switch (notification.type) {
      'new_chapter' => c.primary,
      'comment_reply' => c.tertiary,
      'comment_like' => c.secondary,
      'system' => AppColors.warning,
      _ => c.onSurfaceDim,
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final iconColor = _iconColor(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : c.primary.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: notification.isRead
                                ? c.onSurface
                                : c.onBackground,
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.w400
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: c.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: c.onSurfaceDim,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(notification.createdAt),
                    style: TextStyle(color: c.onSurfaceDim, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk önce';
    if (diff.inHours < 24) return '${diff.inHours}s önce';
    if (diff.inDays < 7) return '${diff.inDays}g önce';
    return '${date.day}.${date.month}.${date.year}';
  }
}
