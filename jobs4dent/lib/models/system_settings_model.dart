class SystemSettingsModel {
  final String settingId;
  final String key;
  final dynamic value;
  final String type; // string, number, boolean, array, object
  final String category;
  final String description;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastModifiedBy;

  SystemSettingsModel({
    required this.settingId,
    required this.key,
    required this.value,
    required this.type,
    required this.category,
    required this.description,
    this.isPublic = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastModifiedBy,
  });

  factory SystemSettingsModel.fromMap(Map<String, dynamic> map) {
    return SystemSettingsModel(
      settingId: map['settingId'] ?? '',
      key: map['key'] ?? '',
      value: map['value'],
      type: map['type'] ?? 'string',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      isPublic: map['isPublic'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      lastModifiedBy: map['lastModifiedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'settingId': settingId,
      'key': key,
      'value': value,
      'type': type,
      'category': category,
      'description': description,
      'isPublic': isPublic,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'lastModifiedBy': lastModifiedBy,
    };
  }

  SystemSettingsModel copyWith({
    String? settingId,
    String? key,
    dynamic value,
    String? type,
    String? category,
    String? description,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastModifiedBy,
  }) {
    return SystemSettingsModel(
      settingId: settingId ?? this.settingId,
      key: key ?? this.key,
      value: value ?? this.value,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    );
  }
}

// Common system setting categories
class SystemSettingCategories {
  static const String general = 'general';
  static const String security = 'security';
  static const String notifications = 'notifications';
  static const String marketplace = 'marketplace';
  static const String jobs = 'jobs';
  static const String chat = 'chat';
  static const String calendar = 'calendar';
  static const String payments = 'payments';
  static const String moderation = 'moderation';
}

// Common system setting keys
class SystemSettingKeys {
  // General
  static const String appName = 'app_name';
  static const String appVersion = 'app_version';
  static const String maintenanceMode = 'maintenance_mode';
  static const String maxFileSize = 'max_file_size';
  
  // Security
  static const String passwordMinLength = 'password_min_length';
  static const String sessionTimeout = 'session_timeout';
  static const String maxLoginAttempts = 'max_login_attempts';
  
  // Notifications
  static const String emailNotifications = 'email_notifications';
  static const String pushNotifications = 'push_notifications';
  static const String smsNotifications = 'sms_notifications';
  
  // Marketplace
  static const String marketplaceCommission = 'marketplace_commission';
  static const String maxProductImages = 'max_product_images';
  static const String productApprovalRequired = 'product_approval_required';
  
  // Jobs
  static const String jobPostingFee = 'job_posting_fee';
  static const String maxJobDuration = 'max_job_duration';
  static const String jobApprovalRequired = 'job_approval_required';
  
  // Chat
  static const String maxMessageLength = 'max_message_length';
  static const String fileAttachmentEnabled = 'file_attachment_enabled';
  static const String maxChatFileSize = 'max_chat_file_size';
  
  // Calendar
  static const String defaultAppointmentDuration = 'default_appointment_duration';
  static const String maxAdvanceBooking = 'max_advance_booking';
  static const String cancellationPeriod = 'cancellation_period';
  
  // Payments
  static const String paymentMethods = 'payment_methods';
  static const String refundPolicy = 'refund_policy';
  static const String taxRate = 'tax_rate';
} 