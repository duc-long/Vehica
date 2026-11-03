import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-App Notification Model stored locally
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String? bookingId;
  final String? bookingCode;
  final String type; // NEW_BOOKING, STATUS_CHANGE, ALERT
  final DateTime timestamp;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.bookingId,
    this.bookingCode,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? bookingId,
    String? bookingCode,
    String? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      bookingId: bookingId ?? this.bookingId,
      bookingCode: bookingCode ?? this.bookingCode,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'bookingId': bookingId,
      'bookingCode': bookingCode,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      bookingId: json['bookingId'] as String?,
      bookingCode: json['bookingCode'] as String?,
      type: json['type'] as String? ?? 'STATUS_CHANGE',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

/// State notifier managing in-app notifications persisted via SharedPreferences
class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  static const String _prefKey = 'vehica_in_app_notifications';

  NotificationNotifier() : super([]) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_prefKey);
      if (rawList != null) {
        final list = rawList
            .map((item) {
              try {
                return AppNotification.fromJson(jsonDecode(item) as Map<String, dynamic>);
              } catch (_) {
                return null;
              }
            })
            .whereType<AppNotification>()
            .toList();

        // Sort descending by timestamp
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        state = list;
      }
    } catch (_) {
      // Ignore load errors gracefully
    }
  }

  Future<void> _saveToStorage(List<AppNotification> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = list.take(50).map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_prefKey, rawList);
    } catch (_) {
      // Ignore save errors
    }
  }

  Future<void> addNotification({
    required String title,
    required String message,
    String? bookingId,
    String? bookingCode,
    String type = 'STATUS_CHANGE',
  }) async {
    final newItem = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      bookingId: bookingId,
      bookingCode: bookingCode,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
    );

    final updated = [newItem, ...state];
    state = updated;
    await _saveToStorage(updated);
  }

  Future<void> markAsRead(String id) async {
    final updated = state.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = updated;
    await _saveToStorage(updated);
  }

  Future<void> markAllAsRead() async {
    final updated = state.map((n) => n.copyWith(isRead: true)).toList();
    state = updated;
    await _saveToStorage(updated);
  }

  Future<void> clearAll() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}

final notificationListProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationListProvider);
  return list.where((n) => !n.isRead).length;
});

