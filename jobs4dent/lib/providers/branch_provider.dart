import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math';
import '../models/branch_model.dart';

class BranchProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<BranchModel> _branches = [];
  BranchModel? _selectedBranch;
  bool _isLoading = false;
  String? _error;

  List<BranchModel> get branches => _branches;
  BranchModel? get selectedBranch => _selectedBranch;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get branches for a specific clinic
  Future<void> loadBranchesForClinic(String clinicId) async {
    try {
      _isLoading = true;
      _error = null;
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      // Simplified query to avoid composite index requirement during development
      // The composite index has been added to firestore.indexes.json and deployed
      // for production optimization, but this query works without requiring manual setup
      final snapshot = await _firestore
          .collection('branches')
          .where('clinicId', isEqualTo: clinicId)
          .get();

      // Client-side filtering and sorting to avoid Firestore composite index
      _branches =
          snapshot.docs
              .map((doc) => BranchModel.fromFirestore(doc))
              .where((branch) => branch.isActive) // Filter active branches
              .toList()
            ..sort(
              (a, b) => a.createdAt.compareTo(b.createdAt),
            ); // Sort by creation date

      _isLoading = false;
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูลสาขา: ${e.toString()}';
      _isLoading = false;
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Stream branches for real-time updates
  Stream<List<BranchModel>> streamBranchesForClinic(String clinicId) {
    return _firestore
        .collection('branches')
        .where('clinicId', isEqualTo: clinicId)
        .snapshots()
        .map((snapshot) {
          // Client-side filtering and sorting to avoid Firestore composite index
          final branches =
              snapshot.docs
                  .map((doc) => BranchModel.fromFirestore(doc))
                  .where((branch) => branch.isActive) // Filter active branches
                  .toList()
                ..sort(
                  (a, b) => a.createdAt.compareTo(b.createdAt),
                ); // Sort by creation date
          return branches;
        });
  }

  // Create a new branch
  Future<void> createBranch(BranchModel branch) async {
    try {
      _isLoading = true;
      _error = null;
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      final docRef = await _firestore
          .collection('branches')
          .add(branch.toFirestore());

      final newBranch = branch.copyWith(branchId: docRef.id);
      _branches.add(newBranch);

      _isLoading = false;
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการสร้างสาขา: ${e.toString()}';
      _isLoading = false;
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  // Update an existing branch
  Future<void> updateBranch(BranchModel branch) async {
    try {
      _isLoading = true;
      _error = null;
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      await _firestore
          .collection('branches')
          .doc(branch.branchId)
          .update(branch.toFirestore());

      final index = _branches.indexWhere((b) => b.branchId == branch.branchId);
      if (index != -1) {
        _branches[index] = branch;
      }

      if (_selectedBranch?.branchId == branch.branchId) {
        _selectedBranch = branch;
      }

      _isLoading = false;
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการอัปเดตสาขา: ${e.toString()}';
      _isLoading = false;
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  // Delete a branch (soft delete)
  Future<void> deleteBranch(String branchId) async {
    try {
      _isLoading = true;
      _error = null;
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      await _firestore.collection('branches').doc(branchId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _branches.removeWhere((branch) => branch.branchId == branchId);

      if (_selectedBranch?.branchId == branchId) {
        _selectedBranch = null;
      }

      _isLoading = false;
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการลบสาขา: ${e.toString()}';
      _isLoading = false;
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  // Upload branch photos
  Future<List<String>> uploadBranchPhotos(
    String branchId,
    List<File> photos,
  ) async {
    try {
      List<String> photoUrls = [];

      for (int i = 0; i < photos.length; i++) {
        final file = photos[i];
        final fileName =
            'branch_${branchId}_photo_$i.${file.path.split('.').last}';
        final ref = _storage.ref().child('branch_photos').child(fileName);

        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        photoUrls.add(downloadUrl);
      }

      return photoUrls;
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: ${e.toString()}');
    }
  }

  // Get branch by ID
  Future<BranchModel?> getBranchById(String branchId) async {
    try {
      final doc = await _firestore.collection('branches').doc(branchId).get();

      if (doc.exists) {
        return BranchModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูลสาขา: ${e.toString()}';
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return null;
    }
  }

  // Set selected branch
  void setSelectedBranch(BranchModel? branch) {
    _selectedBranch = branch;
    // Defer notifyListeners to avoid calling during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Get branches near a location (requires coordinates)
  Future<List<BranchModel>> getBranchesNearLocation(
    GeoPoint userLocation,
    double radiusInKm,
  ) async {
    try {
      // Note: For production, you might want to use a more sophisticated
      // geospatial query. This is a simplified version.
      final snapshot = await _firestore
          .collection('branches')
          .where('isActive', isEqualTo: true)
          .get();

      final allBranches = snapshot.docs
          .map((doc) => BranchModel.fromFirestore(doc))
          .toList();

      // Filter branches within radius
      final nearbyBranches = allBranches.where((branch) {
        if (branch.coordinates == null) return false;

        final distance = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          branch.coordinates!.latitude,
          branch.coordinates!.longitude,
        );

        return distance <= radiusInKm;
      }).toList();

      return nearbyBranches;
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการค้นหาสาขาใกล้เคียง: ${e.toString()}';
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return [];
    }
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double lat1Rad = lat1 * (pi / 180);
    final double lat2Rad = lat2 * (pi / 180);
    final double deltaLatRad = (lat2 - lat1) * (pi / 180);
    final double deltaLonRad = (lon2 - lon1) * (pi / 180);

    final double a =
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLonRad / 2) *
            sin(deltaLonRad / 2);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  // Search branches by name or address
  Future<List<BranchModel>> searchBranches(String query) async {
    try {
      if (query.isEmpty) return _branches;

      final lowercaseQuery = query.toLowerCase();

      return _branches.where((branch) {
        return branch.branchName.toLowerCase().contains(lowercaseQuery) ||
            branch.address.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการค้นหา: ${e.toString()}';
      // Defer notifyListeners to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return [];
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    // Defer notifyListeners to avoid calling during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Reset state
  void reset() {
    _branches = [];
    _selectedBranch = null;
    _isLoading = false;
    _error = null;
    // Defer notifyListeners to avoid calling during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
