class ProductModel {
  final String id;
  final String name;
  final List<String> imageUrls;
  final double price;
  final double? originalPrice; // For showing discounts
  final String? promotionText; // e.g., "20% OFF", "SALE"
  final String description;
  final String specifications;
  final String usageInstructions;
  final DateTime? expirationDate;
  final String categoryId;
  final String categoryName;
  final ProductCondition condition;
  final String sellerId;
  final String sellerName;
  final String sellerEmail;
  final String? sellerPhone;
  final String? sellerAvatar;
  final String? sellerLocation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int viewCount;
  final int inquiryCount;
  final List<String> tags; // For better search
  final Map<String, dynamic>? customFields; // For category-specific fields
  
  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.price,
    this.originalPrice,
    this.promotionText,
    required this.description,
    required this.specifications,
    required this.usageInstructions,
    this.expirationDate,
    required this.categoryId,
    required this.categoryName,
    required this.condition,
    required this.sellerId,
    required this.sellerName,
    required this.sellerEmail,
    this.sellerPhone,
    this.sellerAvatar,
    this.sellerLocation,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.viewCount = 0,
    this.inquiryCount = 0,
    this.tags = const [],
    this.customFields,
  });

  // Calculate discount percentage
  double? get discountPercentage {
    if (originalPrice != null && originalPrice! > price) {
      return ((originalPrice! - price) / originalPrice!) * 100;
    }
    return null;
  }

  // Check if product has discount
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  // Check if product is expired
  bool get isExpired => expirationDate != null && expirationDate!.isBefore(DateTime.now());

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['originalPrice']?.toDouble(),
      promotionText: map['promotionText'],
      description: map['description'] ?? '',
      specifications: map['specifications'] ?? '',
      usageInstructions: map['usageInstructions'] ?? '',
      expirationDate: map['expirationDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['expirationDate'])
          : null,
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      condition: ProductCondition.values.firstWhere(
        (e) => e.toString() == 'ProductCondition.${map['condition']}',
        orElse: () => ProductCondition.used,
      ),
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerEmail: map['sellerEmail'] ?? '',
      sellerPhone: map['sellerPhone'],
      sellerAvatar: map['sellerAvatar'],
      sellerLocation: map['sellerLocation'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isActive: map['isActive'] ?? true,
      viewCount: map['viewCount'] ?? 0,
      inquiryCount: map['inquiryCount'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      customFields: map['customFields'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrls': imageUrls,
      'price': price,
      'originalPrice': originalPrice,
      'promotionText': promotionText,
      'description': description,
      'specifications': specifications,
      'usageInstructions': usageInstructions,
      'expirationDate': expirationDate?.millisecondsSinceEpoch,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'condition': condition.toString().split('.').last,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerEmail': sellerEmail,
      'sellerPhone': sellerPhone,
      'sellerAvatar': sellerAvatar,
      'sellerLocation': sellerLocation,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isActive': isActive,
      'viewCount': viewCount,
      'inquiryCount': inquiryCount,
      'tags': tags,
      'customFields': customFields,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    List<String>? imageUrls,
    double? price,
    double? originalPrice,
    String? promotionText,
    String? description,
    String? specifications,
    String? usageInstructions,
    DateTime? expirationDate,
    String? categoryId,
    String? categoryName,
    ProductCondition? condition,
    String? sellerId,
    String? sellerName,
    String? sellerEmail,
    String? sellerPhone,
    String? sellerAvatar,
    String? sellerLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? viewCount,
    int? inquiryCount,
    List<String>? tags,
    Map<String, dynamic>? customFields,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrls: imageUrls ?? this.imageUrls,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      promotionText: promotionText ?? this.promotionText,
      description: description ?? this.description,
      specifications: specifications ?? this.specifications,
      usageInstructions: usageInstructions ?? this.usageInstructions,
      expirationDate: expirationDate ?? this.expirationDate,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      condition: condition ?? this.condition,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      sellerLocation: sellerLocation ?? this.sellerLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
      inquiryCount: inquiryCount ?? this.inquiryCount,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
    );
  }
}

enum ProductCondition {
  newProduct('New', 'Brand new product'),
  used('Used', 'Used product in good condition'),
  secondHand('Second-hand', 'Second-hand product');

  const ProductCondition(this.label, this.description);
  final String label;
  final String description;
}

extension ProductConditionExtension on ProductCondition {
  String get displayName {
    switch (this) {
      case ProductCondition.newProduct:
        return 'New';
      case ProductCondition.used:
        return 'Used';
      case ProductCondition.secondHand:
        return 'Second-hand';
    }
  }

  String get description {
    switch (this) {
      case ProductCondition.newProduct:
        return 'Brand new, never used';
      case ProductCondition.used:
        return 'Previously used, good condition';
      case ProductCondition.secondHand:
        return 'Pre-owned, may show signs of wear';
    }
  }
}

class ProductCategory {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final List<String> subcategories;
  final Map<String, dynamic>? customFields; // Category-specific fields

  ProductCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    this.subcategories = const [],
    this.customFields,
  });

  factory ProductCategory.fromMap(Map<String, dynamic> map) {
    return ProductCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconUrl: map['iconUrl'],
      subcategories: List<String>.from(map['subcategories'] ?? []),
      customFields: map['customFields'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'subcategories': subcategories,
      'customFields': customFields,
    };
  }
}

// Predefined categories for dental products
class DentalProductCategories {
  static List<ProductCategory> get defaultCategories => [
    ProductCategory(
      id: 'instruments',
      name: 'Dental Instruments',
      description: 'Hand instruments, rotary instruments, and surgical tools',
      subcategories: [
        'Hand Instruments',
        'Rotary Instruments',
        'Surgical Instruments',
        'Orthodontic Instruments',
        'Periodontal Instruments',
      ],
    ),
    ProductCategory(
      id: 'materials',
      name: 'Dental Materials',
      description: 'Restorative materials, impression materials, and consumables',
      subcategories: [
        'Restorative Materials',
        'Impression Materials',
        'Adhesives & Cements',
        'Preventive Materials',
        'Laboratory Materials',
      ],
    ),
    ProductCategory(
      id: 'equipment',
      name: 'Dental Equipment',
      description: 'Chairs, units, X-ray machines, and other major equipment',
      subcategories: [
        'Dental Chairs',
        'Dental Units',
        'X-ray Equipment',
        'Sterilization Equipment',
        'Laboratory Equipment',
      ],
    ),
    ProductCategory(
      id: 'chemicals',
      name: 'Dental Chemicals',
      description: 'Disinfectants, cleaning solutions, and treatment chemicals',
      subcategories: [
        'Disinfectants',
        'Cleaning Solutions',
        'Treatment Chemicals',
        'Anesthetics',
        'Medications',
      ],
    ),
    ProductCategory(
      id: 'disposables',
      name: 'Disposables',
      description: 'Single-use items and consumables',
      subcategories: [
        'Gloves',
        'Masks',
        'Syringes',
        'Needles',
        'Cups & Containers',
      ],
    ),
    ProductCategory(
      id: 'orthodontics',
      name: 'Orthodontic Products',
      description: 'Braces, wires, brackets, and orthodontic supplies',
      subcategories: [
        'Brackets',
        'Wires',
        'Bands',
        'Appliances',
        'Adhesives',
      ],
    ),
  ];
} 