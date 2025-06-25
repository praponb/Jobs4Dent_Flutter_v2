class PackageModel {
  final String packageId;
  final String name;
  final String description;
  final double price;
  final String currency;
  final PackageType type;
  final int duration; // in days
  final List<String> features;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  PackageModel({
    required this.packageId,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'THB',
    required this.type,
    required this.duration,
    required this.features,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory PackageModel.fromMap(Map<String, dynamic> map) {
    return PackageModel(
      packageId: map['packageId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'THB',
      type: PackageType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => PackageType.basic,
      ),
      duration: map['duration'] ?? 30,
      features: List<String>.from(map['features'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageId': packageId,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'type': type.name,
      'duration': duration,
      'features': features,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  PackageModel copyWith({
    String? packageId,
    String? name,
    String? description,
    double? price,
    String? currency,
    PackageType? type,
    int? duration,
    List<String>? features,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PackageModel(
      packageId: packageId ?? this.packageId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum PackageType {
  basic,
  premium,
  enterprise,
  custom,
}

class TransactionModel {
  final String transactionId;
  final String packageId;
  final String userId;
  final String paymentMethod;
  final double amount;
  final String currency;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic> paymentDetails;
  final String? failureReason;

  TransactionModel({
    required this.transactionId,
    required this.packageId,
    required this.userId,
    required this.paymentMethod,
    required this.amount,
    this.currency = 'THB',
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.paymentDetails = const {},
    this.failureReason,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      transactionId: map['transactionId'] ?? '',
      packageId: map['packageId'] ?? '',
      userId: map['userId'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'THB',
      status: TransactionStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      paymentDetails: Map<String, dynamic>.from(map['paymentDetails'] ?? {}),
      failureReason: map['failureReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'packageId': packageId,
      'userId': userId,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'paymentDetails': paymentDetails,
      'failureReason': failureReason,
    };
  }
}

enum TransactionStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
} 