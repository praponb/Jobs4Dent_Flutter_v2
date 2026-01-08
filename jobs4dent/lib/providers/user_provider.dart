import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _error;
  List<UserModel> _users = [];
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserModel> get users => _users;

  Future<List<UserModel>> getDentists() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userType', whereIn: ['dentist', 'assistant'])
          .get();

      _users = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
      return _users;
    } catch (e) {
      _error = 'การดึงข้อมูลทันตแพทย์ไม่สำเร็จ: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<List<UserModel>> getClinics() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'clinic')
          .get();

      _users = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
      return _users;
    } catch (e) {
      _error = 'การดึงข้อมูลคลินิกไม่สำเร็จ: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      _error = 'การดึงข้อมูลผู้ใช้ไม่สำเร็จ: $e';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 