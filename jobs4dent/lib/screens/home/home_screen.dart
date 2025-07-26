import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dentist_dashboard.dart';
import 'clinic_dashboard.dart';
// import 'seller_dashboard.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.userModel == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final userType = authProvider.userModel!.userType;
        
        return Scaffold(
          body: _getBody(userType),
          bottomNavigationBar: _buildBottomNavigationBar(userType),
        );
      },
    );
  }

  Widget _getBody(String userType) {
    switch (_currentIndex) {
      case 0:
        return _getDashboard(userType);
      // case 1:
      //   return _getSecondaryScreen(userType);
      // case 2:
      //   return _getThirdScreen(userType);
      //case 3:
      case 1:
        return const ProfileScreen();
      default:
        return _getDashboard(userType);
    }
  }

  Widget _getDashboard(String userType) {
    switch (userType) {
      case 'dentist':
      case 'assistant':
        return const DentistDashboard();
      case 'clinic':
        return const ClinicDashboard();
      // case 'seller':
      //   return const SellerDashboard();
      default:
        return const DentistDashboard();
    }
  }

  // Widget _getSecondaryScreen(String userType) {
  //   // This would be Jobs for dentists, Applications for clinics, etc.
  //           return const Center(
  //         child: Text(
  //           'หน้าจอรอง',
  //           style: TextStyle(fontSize: 24),
  //         ),
  //       );
  // }

  // Widget _getThirdScreen(String userType) {
  //   // This would be Marketplace, Messages, etc.
  //           return const Center(
  //         child: Text(
  //           'หน้าจอที่สาม',
  //           style: TextStyle(fontSize: 24),
  //         ),
  //       );
  // }

  BottomNavigationBar _buildBottomNavigationBar(String userType) {
    List<BottomNavigationBarItem> items = [];

    switch (userType) {
      case 'dentist':
      case 'assistant':
        items = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'แดชบอร์ด',
          ),
          // const BottomNavigationBarItem(
          //   icon: Icon(Icons.work),
          //   label: 'งาน',
          // ),
          // const BottomNavigationBarItem(
          //   icon: Icon(Icons.store),
          //   label: 'ตลาดซื้อขาย',
          // ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ];
        break;
      case 'clinic':
        items = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'แดชบอร์ด',
          ),
          // const BottomNavigationBarItem(
          //   icon: Icon(Icons.post_add),
          //   label: 'ประกาศงาน',
          // ),
          // const BottomNavigationBarItem(
          //   icon: Icon(Icons.people),
          //   label: 'ใบสมัคร',
          // ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ];
        break;
      // case 'seller':
      //   items = [
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.dashboard),
      //       label: 'แดชบอร์ด',
      //     ),
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.inventory),
      //       label: 'สินค้า',
      //     ),
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart),
      //       label: 'คำสั่งซื้อ',
      //     ),
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'โปรไฟล์',
      //     ),
      //   ];
      //   break;
      default:
        items = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'แดชบอร์ด',
          ),
          // const BottomNavigationBarItem(
          //   icon: Icon(Icons.work),
          //   label: 'งาน',
          // ),
          // const BottomNavigationBarItem(
          //   icon: Icon(Icons.store),
          //   label: 'ตลาดซื้อขาย',
          // ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ];
    }

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2196F3),
      unselectedItemColor: Colors.grey,
      items: items,
    );
  }
} 