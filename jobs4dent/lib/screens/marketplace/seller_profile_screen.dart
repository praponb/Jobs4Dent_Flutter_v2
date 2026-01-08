import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/product_model.dart';

class SellerProfileScreen extends StatefulWidget {
  final String sellerId;

  const SellerProfileScreen({super.key, required this.sellerId});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  List<ProductModel> sellerProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSellerProducts();
  }

  Future<void> _loadSellerProducts() async {
    final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
    
    // Filter products by seller ID
    final products = marketplaceProvider.products
        .where((product) => product.sellerId == widget.sellerId)
        .toList();
    
    setState(() {
      sellerProducts = products;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('โปรไฟล์ผู้ขาย'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (sellerProducts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('โปรไฟล์ผู้ขาย'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: const Center(child: Text('ไม่พบสินค้าของผู้ขายรายนี้')),
      );
    }

    final firstProduct = sellerProducts.first;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('โปรไฟล์ผู้ขาย'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: firstProduct.sellerAvatar != null
                      ? NetworkImage(firstProduct.sellerAvatar!)
                      : null,
                  child: firstProduct.sellerAvatar == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  firstProduct.sellerName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (firstProduct.sellerLocation != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        firstProduct.sellerLocation!,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      'สินค้า',
                      '${sellerProducts.length}',
                      MdiIcons.packageVariantClosed,
                    ),
                    _buildStatCard(
                      'ยอดดูรวม',
                      '${sellerProducts.fold<int>(0, (sum, product) => sum + product.viewCount)}',
                      MdiIcons.eye,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'สินค้า',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sellerProducts.length,
                      itemBuilder: (context, index) {
                        final product = sellerProducts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: product.imageUrls.isNotEmpty
                                ? NetworkImage(product.imageUrls.first)
                                : null,
                            child: product.imageUrls.isEmpty
                                ? const Icon(Icons.inventory)
                                : null,
                          ),
                          title: Text(product.name),
                          subtitle: Text(
                            '฿${product.price.toStringAsFixed(0)} • ${product.categoryName}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Navigate to product detail
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
} 