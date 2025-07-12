import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/product_model.dart';

import '../marketplace/my_products_screen.dart';
import '../marketplace/product_listing_screen.dart';
import '../profile/profile_screen.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final NumberFormat _numberFormat = NumberFormat('#,##0');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₿');
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userModel != null) {
      await Provider.of<MarketplaceProvider>(context, listen: false)
          .fetchSellerProducts(authProvider.userModel!.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('แดชบอร์ดผู้ขาย'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showOrderNotifications();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, MarketplaceProvider>(
        builder: (context, authProvider, marketplaceProvider, child) {
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
                  // Seller Welcome Card
                  _buildSellerWelcomeCard(user),
                  const SizedBox(height: 24),

                  // Sales Overview
                  _buildSalesOverview(marketplaceProvider),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  // Sales Performance Chart
                  _buildSalesChart(),
                  const SizedBox(height: 24),

                  // Product Performance
                  _buildProductPerformance(marketplaceProvider),
                  const SizedBox(height: 24),

                  // Recent Orders
                  _buildRecentOrders(),
                  const SizedBox(height: 24),

                  // Top Performing Products
                  _buildTopProducts(marketplaceProvider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductListingScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มสินค้า'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildSellerWelcomeCard(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
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
                  Icons.storefront,
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
                      'ยินดีต้อนรับ, ${user.userName}!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ผู้ขายในตลาด',
                      style: TextStyle(
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
            'จัดการผลิตภัณฑ์ทันตกรรมของคุณและติดตามผลการขาย',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesOverview(MarketplaceProvider marketplaceProvider) {
    final products = marketplaceProvider.myProducts;
    final totalProducts = products.length;
    final activeProducts = products.where((p) => p.isActive).length;
    final totalViews = products.fold<int>(0, (sum, p) => sum + p.viewCount);
    final totalInquiries = products.fold<int>(0, (sum, p) => sum + p.inquiryCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ภาพรวมการขาย',
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
              child: _buildSalesCard(
                title: 'สินค้า',
                value: totalProducts.toString(),
                subtitle: '$activeProducts เปิดใช้งาน',
                icon: Icons.inventory,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSalesCard(
                title: 'ครั้งชม',
                value: _numberFormat.format(totalViews),
                subtitle: 'ยอดดูทั้งหมด',
                icon: Icons.visibility,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSalesCard(
                title: 'สอบถาม',
                value: totalInquiries.toString(),
                subtitle: 'คำถามจากลูกค้า',
                icon: Icons.question_answer,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSalesCard(
                title: 'คำสั่งซื้อ',
                value: '12',
                subtitle: 'เดือนนี้',
                icon: Icons.shopping_cart,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesCard({
    required String title,
    required String value,
    required String subtitle,
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
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
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
          'การดำเนินการด่วน',
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
                title: 'เพิ่มสินค้า',
                subtitle: 'ลงรายการใหม่',
                icon: Icons.add_box,
                color: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductListingScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'สินค้าของฉัน',
                subtitle: 'จัดการสินค้าคงคลัง',
                icon: Icons.inventory_2,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyProductsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'คำสั่งซื้อ',
                subtitle: 'จัดการคำสั่งซื้อ',
                icon: Icons.receipt_long,
                color: Colors.orange,
                onTap: () {
                  _showOrderManagement();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'รายงาน',
                subtitle: 'ดูรายงาน',
                icon: Icons.analytics,
                color: Colors.purple,
                onTap: () {
                  _showDetailedAnalytics();
                },
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

  Widget _buildSalesChart() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'ประสิทธิภาพการขาย',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => _showDetailedAnalytics(),
                child: const Text('ดูรายละเอียด'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Text(months[value.toInt()]);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1500),  // ม.ค.
                      FlSpot(1, 2300),  // ก.พ.
                      FlSpot(2, 1800),  // มี.ค.
                      FlSpot(3, 2800),  // เม.ย.
                      FlSpot(4, 3200),  // พ.ค.
                      FlSpot(5, 2900),  // มิ.ย.
                      FlSpot(6, 3500),  // ก.ค.
                      FlSpot(7, 3100),  // ส.ค.
                      FlSpot(8, 2700),  // ก.ย.
                      FlSpot(9, 3300),  // ต.ค.
                      FlSpot(10, 2800), // พ.ย.
                      FlSpot(11, 3000), // ธ.ค.
                    ],
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    ),
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPerformance(MarketplaceProvider marketplaceProvider) {
    final products = marketplaceProvider.myProducts;
    final topProducts = products.toList()
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount))
      ..take(3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'ประสิทธิภาพสินค้า',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyProductsScreen()),
                );
              },
              child: const Text('ดูทั้งหมด'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (products.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                const Icon(Icons.inventory, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                const Text(
                  'ยังไม่มีสินค้าที่ลงขาย',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'เริ่มต้นด้วยการเพิ่มสินค้าแรกของคุณใน marketplace',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductListingScreen(),
                      ),
                    );
                  },
                  child: const Text('เพิ่มสินค้า'),
                ),
              ],
            ),
          )
        else
          ...topProducts.map((product) => _buildProductCard(product)),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.imageUrls.isNotEmpty
                ? Image.network(
                    product.imageUrls.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _currencyFormat.format(product.price),
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${product.viewCount} ครั้งชม',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.question_answer, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${product.inquiryCount} สอบถาม',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.isActive ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
                                product.isActive ? 'เปิดใช้งาน' : 'ปิดใช้งาน',
              style: TextStyle(
                fontSize: 12,
                color: product.isActive ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts(MarketplaceProvider marketplaceProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
                          'หมวดหมู่ขายดี',
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
              _buildCategoryRow('เครื่องมือทันตกรรม', '45%', Colors.blue),
              const Divider(),
                              _buildCategoryRow('วัสดุใช้แล้วทิ้ง', '25%', Colors.green),
              const Divider(),
                              _buildCategoryRow('เครื่องมือ', '20%', Colors.orange),
              const Divider(),
                              _buildCategoryRow('วัสดุ', '10%', Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(String category, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    final orders = [
      {'id': 'ORD-001', 'product': 'ชุดคีมทันตกรรม', 'amount': '₿1,250', 'status': 'จัดส่งแล้ว', 'date': '2 วันที่แล้ว'},
      {'id': 'ORD-002', 'product': 'ฟิล์มเอกซเรย์', 'amount': '₿850', 'status': 'กำลังดำเนินการ', 'date': '3 วันที่แล้ว'},
      {'id': 'ORD-003', 'product': 'ชุดดอกสว่านทันตกรรม', 'amount': '₿420', 'status': 'ส่งถึงแล้ว', 'date': '5 วันที่แล้ว'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'คำสั่งซื้อล่าสุด',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => _showOrderManagement(),
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
            children: orders.map((order) => _buildOrderItem(order)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    Color statusColor;
    switch (order['status']) {
      case 'จัดส่งแล้ว':
        statusColor = Colors.blue;
        break;
      case 'กำลังดำเนินการ':
        statusColor = Colors.orange;
        break;
      case 'ส่งถึงแล้ว':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['product'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order['id']} • ${order['date']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                order['amount'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _showOrderNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แจ้งเตือนคำสั่งซื้อ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('คุณมีคำสั่งซื้อใหม่ 3 รายการ!'),
            SizedBox(height: 16),
            Text('• ชุดคีมทันตกรรม - ₿1,250'),
            Text('• ชุดฟิล์มเอกซเรย์ - ₿850'),
            Text('• ชุดฆ่าเชื้อ - ₿620'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showOrderManagement();
            },
            child: const Text('ดูคำสั่งซื้อ'),
          ),
        ],
      ),
    );
  }

  void _showOrderManagement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('จัดการคำสั่งซื้อ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                    Text('ฟังก์ชันการจัดการคำสั่งซื้อจะพัฒนาให้ใช้งานได้เร็วๆ นี้'),
        SizedBox(height: 16),
        Text('ฟีเจอร์ที่จะรวม:'),
            Text('• ดูคำสั่งซื้อทั้งหมด'),
            Text('• อัปเดตสถานะคำสั่งซื้อ'),
            Text('• การจัดการจัดส่ง'),
            Text('• การสื่อสารกับลูกค้า'),
            Text('• การวิเคราะห์คำสั่งซื้อ'),
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

  void _showDetailedAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('รายงานวิเคราะห์โดยละเอียด'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                    Text('การวิเคราะห์ขั้นสูงสำหรับผู้ขายจะพัฒนาให้ใช้งานได้เร็วๆ นี้'),
        SizedBox(height: 16),
        Text('ฟีเจอร์:'),
            Text('• แนวโน้มการขาย'),
            Text('• ประสิทธิภาพของสินค้า'),
            Text('• ข้อมูลเชิงลึกของลูกค้า'),
            Text('• การพยากรณ์รายได้'),
            Text('• การวิเคราะห์ตลาด'),
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
} 