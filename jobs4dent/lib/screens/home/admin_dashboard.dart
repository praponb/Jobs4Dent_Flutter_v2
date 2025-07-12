import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/user_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load admin dashboard data
    // In a real app, you would fetch system statistics from your backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('แดชบอร์ดแอดมิน'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showSystemAlerts();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'broadcast':
                  _showBroadcastDialog();
                  break;
                case 'logs':
                  _showSystemLogs();
                  break;
                case 'backup':
                  _showBackupDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'broadcast',
                child: Row(
                  children: [
                    Icon(Icons.campaign, size: 20),
                    SizedBox(width: 8),
                    Text('ส่งข้อความประกาศ'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logs',
                child: Row(
                  children: [
                    Icon(Icons.list_alt, size: 20),
                    SizedBox(width: 8),
                    Text('บันทึกระบบ'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [
                    Icon(Icons.backup, size: 20),
                    SizedBox(width: 8),
                    Text('สำรองข้อมูล'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer3<AuthProvider, JobProvider, MarketplaceProvider>(
        builder: (context, authProvider, jobProvider, marketplaceProvider, child) {
          final user = authProvider.userModel;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin Welcome Card
                  _buildAdminWelcomeCard(user),
                  const SizedBox(height: 24),

                  // System Overview
                  _buildSystemOverview(),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  // User Statistics Chart
                  _buildUserStatsChart(),
                  const SizedBox(height: 24),

                  // Platform Statistics
                  _buildPlatformStats(),
                  const SizedBox(height: 24),

                  // Recent System Activity
                  _buildRecentActivity(),
                  const SizedBox(height: 24),

                  // Revenue & Financial Overview
                  _buildRevenueOverview(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminWelcomeCard(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user.userName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.isSuperAdmin == true ? 'ผู้ดูแลระบบสูงสุด' : 'ผู้ดูแลระบบ',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'จัดการแพลตฟอร์ม Jobs4Dent และติดตามประสิทธิภาพระบบ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ภาพรวมระบบ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSystemCard(
                title: 'ผู้ใช้รวม',
                value: '2,847',
                change: '+12%',
                isPositive: true,
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSystemCard(
                title: 'งานที่เปิดอยู่',
                value: '456',
                change: '+8%',
                isPositive: true,
                icon: Icons.work,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSystemCard(
                title: 'ยอดขายตลาดสินค้า',
                value: '₿1.2M',
                change: '+15%',
                isPositive: true,
                icon: Icons.store,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSystemCard(
                title: 'สุขภาพระบบ',
                value: '98.5%',
                                  change: 'ดีเยี่ยม',
                isPositive: true,
                icon: Icons.health_and_safety,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 10,
                    color: isPositive ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เครื่องมือผู้ดูแล',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'จัดการผู้ใช้',
                subtitle: 'จัดการผู้ใช้ทั้งหมด',
                icon: Icons.person_outline,
                color: Colors.blue,
                onTap: () => _showUserManagement(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'หมวดหมู่',
                subtitle: 'หมวดหมู่งานและสินค้า',
                icon: Icons.category,
                color: Colors.teal,
                onTap: () => _showCategoryManagement(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'แพ็คเกจบริการ',
                subtitle: 'ราคาและแพ็คเกจ',
                icon: Icons.payment,
                color: Colors.green,
                onTap: () => _showServicePackages(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'รายงาน',
                subtitle: 'รายงานและข้อมูลเชิงลึก',
                icon: Icons.analytics,
                color: Colors.purple,
                onTap: () => _showAnalytics(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatsChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'การกระจายผู้ใช้',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 45,
                    title: '45%\nทันตแพทย์',
                    color: Colors.blue,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 30,
                    title: '30%\nผู้ช่วย',
                    color: Colors.green,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%\nคลินิก',
                    color: Colors.orange,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 5,
                    title: '5%\nอื่นๆ',
                    color: Colors.purple,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'สถิติแพลตฟอร์ม',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildStatRow('ประกาศงานทั้งหมด', '1,234', Icons.work),
              const Divider(),
                              _buildStatRow('ใบสมัครที่ส่ง', '5,678', Icons.send),
              const Divider(),
              _buildStatRow('จ้างงานสำเร็จ', '891', Icons.handshake),
              const Divider(),
              _buildStatRow('สินค้าที่ลงรายการ', '2,345', Icons.inventory),
              const Divider(),
              _buildStatRow('ยอดขายตลาดสินค้า', '₿1,200,000', Icons.attach_money),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'type': 'user', 'message': 'คลินิกใหม่ลงทะเบียน: คลินิกทันตกรรมกรุงเทพ', 'time': '2 ชั่วโมงที่แล้ว'},
      {'type': 'job', 'message': 'มีการสร้างประกาศงาน 5 ตำแหน่งใหม่', 'time': '3 ชั่วโมงที่แล้ว'},
      {'type': 'sale', 'message': 'ขายสินค้า: เครื่องเอ็กซ์เรย์ทันตกรรม', 'time': '5 ชั่วโมงที่แล้ว'},
      {'type': 'system', 'message': 'การบำรุงรักษาระบบเสร็จสิ้น', 'time': '1 วันที่แล้ว'},
      {'type': 'user', 'message': 'ทันตแพทย์ใหม่ 3 คนเข้าร่วมแพลตฟอร์ม', 'time': '1 วันที่แล้ว'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'กิจกรรมล่าสุดในระบบ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => _showSystemLogs(),
              child: const Text('ดูทั้งหมด'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: activities.map((activity) => 
              _buildActivityItem(activity)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    IconData icon;
    Color color;
    
    switch (activity['type']) {
      case 'user':
        icon = Icons.person_add;
        color = Colors.blue;
        break;
      case 'job':
        icon = Icons.work;
        color = Colors.green;
        break;
      case 'sale':
        icon = Icons.shopping_bag;
        color = Colors.orange;
        break;
      case 'system':
        icon = Icons.settings;
        color = Colors.purple;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['message'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  activity['time'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ภาพรวมรายได้',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRevenueCard(
                title: 'รายได้รายเดือน',
                amount: '₿125,000',
                change: '+18%',
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRevenueCard(
                title: 'รายได้รายปี',
                amount: '₿1,200,000',
                change: '+25%',
                icon: Icons.monetization_on,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueCard({
    required String title,
    required String amount,
    required String change,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.green, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _showUserManagement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('จัดการผู้ใช้'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                    Text('ฟังก์ชันการจัดการผู้ใช้จะพัฒนาให้ใช้งานได้เร็วๆ นี้'),
        SizedBox(height: 16),
        Text('ฟีเจอร์ที่จะรวม:'),
            Text('• Create, edit, delete users'),
            Text('• Suspend/activate accounts'),
            Text('• Manage user roles'),
            Text('• View user activity'),
            Text('• Export user data'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showCategoryManagement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('จัดการหมวดหมู่'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                    Text('การจัดการหมวดหมู่จะพัฒนาให้ใช้งานได้เร็วๆ นี้'),
        SizedBox(height: 16),
        Text('ฟีเจอร์:'),
            Text('• Job categories'),
            Text('• Product categories'),
            Text('• Category hierarchy'),
            Text('• Category analytics'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showServicePackages() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แพ็คเกจบริการ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                    Text('การจัดการแพ็คเกจบริการจะพัฒนาให้ใช้งานได้เร็วๆ นี้'),
        SizedBox(height: 16),
        Text('ฟีเจอร์:'),
        Text('• สร้างระดับราคา'),
        Text('• จำกัดฟีเจอร์'),
        Text('• จัดการการสมัครสมาชิก'),
            Text('• Revenue tracking'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('รายงานวิเคราะห์ขั้นสูง'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                    Text('แดชบอร์ดการวิเคราะห์ขั้นสูงจะพัฒนาให้ใช้งานได้เร็วๆ นี้'),
        SizedBox(height: 16),
        Text('ฟีเจอร์:'),
            Text('• User engagement metrics'),
            Text('• Revenue analytics'),
            Text('• Job posting performance'),
            Text('• Marketplace insights'),
            Text('• Custom reports'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showSystemAlerts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แจ้งเตือนระบบ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ไม่มีการแจ้งเตือนที่สำคัญในขณะนี้'),
            SizedBox(height: 16),
            Text('ระบบทั้งหมดทำงานปกติ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showBroadcastDialog() {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ส่งข้อความประกาศ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ส่งข้อความถึงผู้ใช้ทั้งหมดหรือกลุ่มผู้ใช้ที่ระบุ'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'ข้อความ',
                border: OutlineInputBorder(),
                                    hintText: 'ใส่ข้อความของคุณที่นี่...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement broadcast functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ส่งข้อความประกาศเรียบร้อยแล้ว'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('ส่ง'),
          ),
        ],
      ),
    );
  }

  void _showSystemLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('บันทึกระบบ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                    Text('บันทึกระบบและการตรวจสอบข้อผิดพลาดจะพัฒนาให้ใช้งานได้เร็วๆ นี้'),
        SizedBox(height: 16),
        Text('ฟีเจอร์:'),
                    Text('• ตรวจสอบข้อผิดพลาดแบบเรียลไทม์'),
                Text('• ตัวชี้วัดประสิทธิภาพ'),
        Text('• บันทึกกิจกรรมผู้ใช้'),
        Text('• เหตุการณ์ด้านความปลอดภัย'),
        Text('• ความสามารถในการส่งออก'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('สำรองข้อมูล'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('สร้างการสำรองข้อมูลของระบบทั้งหมด'),
            SizedBox(height: 16),
            Text('อาจใช้เวลาหลายนาทีในการเสร็จสมบูรณ์'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('เริ่มสำรองข้อมูลเรียบร้อยแล้ว'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('เริ่มสำรองข้อมูล'),
          ),
        ],
      ),
    );
  }
} 