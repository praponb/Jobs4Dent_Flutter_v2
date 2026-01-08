import 'package:cloud_firestore/cloud_firestore.dart';

class BranchModel {
  final String branchId;
  final String clinicId; // Reference to the parent clinic/user
  final String branchName;
  final String address;
  final GeoPoint? coordinates; // GPS coordinates for map display
  final Map<String, String> operatingHours; // Day -> "open-close" format
  final String parkingInfo; // Parking information
  final String contactNumber;
  final List<String> branchPhotos; // URLs of branch photos
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  BranchModel({
    required this.branchId,
    required this.clinicId,
    required this.branchName,
    required this.address,
    this.coordinates,
    this.operatingHours = const {},
    this.parkingInfo = '',
    required this.contactNumber,
    this.branchPhotos = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory BranchModel.fromMap(Map<String, dynamic> map) {
    return BranchModel(
      branchId: map['branchId'] ?? '',
      clinicId: map['clinicId'] ?? '',
      branchName: map['branchName'] ?? '',
      address: map['address'] ?? '',
      coordinates: map['coordinates'] as GeoPoint?,
      operatingHours: Map<String, String>.from(map['operatingHours'] ?? {}),
      parkingInfo: map['parkingInfo'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      branchPhotos: List<String>.from(map['branchPhotos'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isActive: map['isActive'] ?? true,
    );
  }

  factory BranchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return BranchModel.fromMap({...data, 'branchId': doc.id});
  }

  Map<String, dynamic> toMap() {
    return {
      'branchId': branchId,
      'clinicId': clinicId,
      'branchName': branchName,
      'address': address,
      'coordinates': coordinates,
      'operatingHours': operatingHours,
      'parkingInfo': parkingInfo,
      'contactNumber': contactNumber,
      'branchPhotos': branchPhotos,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toFirestore() {
    final data = toMap();
    data.remove('branchId'); // Firestore uses document ID
    return data;
  }

  BranchModel copyWith({
    String? branchId,
    String? clinicId,
    String? branchName,
    String? address,
    GeoPoint? coordinates,
    Map<String, String>? operatingHours,
    String? parkingInfo,
    String? contactNumber,
    List<String>? branchPhotos,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return BranchModel(
      branchId: branchId ?? this.branchId,
      clinicId: clinicId ?? this.clinicId,
      branchName: branchName ?? this.branchName,
      address: address ?? this.address,
      coordinates: coordinates ?? this.coordinates,
      operatingHours: operatingHours ?? this.operatingHours,
      parkingInfo: parkingInfo ?? this.parkingInfo,
      contactNumber: contactNumber ?? this.contactNumber,
      branchPhotos: branchPhotos ?? this.branchPhotos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper method to get formatted operating hours
  String getFormattedOperatingHours() {
    if (operatingHours.isEmpty) return 'ไม่ได้ระบุ';
    
    List<String> formattedHours = [];
    const Map<String, String> dayNames = {
      'monday': 'จันทร์',
      'tuesday': 'อังคาร',
      'wednesday': 'พุธ',
      'thursday': 'พฤหัสบดี',
      'friday': 'ศุกร์',
      'saturday': 'เสาร์',
      'sunday': 'อาทิตย์',
    };
    
    for (var entry in operatingHours.entries) {
      final dayName = dayNames[entry.key.toLowerCase()] ?? entry.key;
      formattedHours.add('$dayName: ${entry.value}');
    }
    
    return formattedHours.join('\n');
  }

  // Helper method to check if branch is open at a specific time
  bool isOpenAt(DateTime dateTime) {
    final dayName = _getDayName(dateTime.weekday);
    final timeString = operatingHours[dayName.toLowerCase()];
    
    if (timeString == null || timeString.isEmpty) return false;
    
    try {
      final times = timeString.split('-');
      if (times.length != 2) return false;
      
      final openTime = _parseTime(times[0].trim());
      final closeTime = _parseTime(times[1].trim());
      final currentTime = DateTime(2000, 1, 1, dateTime.hour, dateTime.minute);
      
      return currentTime.isAfter(openTime) && currentTime.isBefore(closeTime);
    } catch (e) {
      return false;
    }
  }

  String _getDayName(int weekday) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    return DateTime(2000, 1, 1, hour, minute);
  }
} 