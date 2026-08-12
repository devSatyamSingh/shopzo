import 'package:flutter/material.dart';

/// Backend statuses: "OPEN", "IN_PROGRESS", "RESOLVED", "CLOSED"
enum SupportTicketStatus { open, inProgress, resolved, closed, unknown }

extension SupportTicketStatusX on SupportTicketStatus {
  static SupportTicketStatus fromRaw(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'OPEN':
        return SupportTicketStatus.open;
      case 'IN_PROGRESS':
        return SupportTicketStatus.inProgress;
      case 'RESOLVED':
        return SupportTicketStatus.resolved;
      case 'CLOSED':
        return SupportTicketStatus.closed;
      default:
        return SupportTicketStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case SupportTicketStatus.open:
        return 'Open';
      case SupportTicketStatus.inProgress:
        return 'In Progress';
      case SupportTicketStatus.resolved:
        return 'Resolved';
      case SupportTicketStatus.closed:
        return 'Closed';
      case SupportTicketStatus.unknown:
        return 'Unknown';
    }
  }

  // Har status ka apna color — list me badge isi se render hoga
  Color get color {
    switch (this) {
      case SupportTicketStatus.open:
        return const Color(0xFFFF9800); // orange
      case SupportTicketStatus.inProgress:
        return const Color(0xFF2F80ED); // blue
      case SupportTicketStatus.resolved:
        return const Color(0xFF27AE60); // green
      case SupportTicketStatus.closed:
        return const Color(0xFF9E9E9E); // grey
      case SupportTicketStatus.unknown:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData get icon {
    switch (this) {
      case SupportTicketStatus.open:
        return Icons.mark_email_unread_rounded;
      case SupportTicketStatus.inProgress:
        return Icons.autorenew_rounded;
      case SupportTicketStatus.resolved:
        return Icons.check_circle_rounded;
      case SupportTicketStatus.closed:
        return Icons.lock_rounded;
      case SupportTicketStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }
}

class SupportTicketModel {
  final String id;
  final String customerId;
  final String title;
  final String description;
  final String statusRaw;
  final String createdAt;
  final String updatedAt;

  SupportTicketModel({
    required this.id,
    required this.customerId,
    required this.title,
    required this.description,
    required this.statusRaw,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      statusRaw: json['status']?.toString() ?? 'OPEN',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  SupportTicketStatus get status => SupportTicketStatusX.fromRaw(statusRaw);

  // e.g. "12 Aug 2026" — list card me niche dikhane ke liye
  String get formattedCreatedAt {
    final date = DateTime.tryParse(createdAt);
    if (date == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}