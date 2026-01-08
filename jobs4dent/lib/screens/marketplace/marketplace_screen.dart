import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/product_model.dart';

import 'product_listing_screen.dart';
import 'my_products_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'en_US');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
      marketplaceProvider.initializeMarketplace();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('ตลาดซื้อขาย'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'เรียกดู'),
            Tab(text: 'หมวดหมู่'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.plus),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductListingScreen()),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(MdiIcons.dotsVertical),
            onSelected: (value) {
              if (value == 'my_products') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyProductsScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'my_products',
                child: Row(
                  children: [
                    Icon(MdiIcons.packageVariantClosed),
                    SizedBox(width: 8),
                    Text('สินค้าของฉัน'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBrowseTab(),
                _buildCategoriesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหาสินค้า...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            final provider = Provider.of<MarketplaceProvider>(context, listen: false);
            provider.searchProducts(value, provider.searchFilters);
          }
        },
      ),
    );
  }

  Widget _buildBrowseTab() {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = _searchController.text.isNotEmpty
            ? provider.searchResults
            : provider.products;

        if (products.isEmpty) {
          return const Center(child: Text('ไม่พบสินค้า'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => _buildProductCard(products[index]),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.categories.length,
          itemBuilder: (context, index) {
            final category = provider.categories[index];
            final productCount = provider.getProductsByCategory(category.id).length;

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    _getCategoryIcon(category.id),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(category.name),
                subtitle: Text('$productCount รายการ'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showCategoryProducts(category),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
                      // Note: Product detail screen navigation pending implementation
          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('หน้ารายละเอียดสินค้า เร็วๆ นี้!')),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: product.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrls.first,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Icon(
                          MdiIcons.packageVariantClosed,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      )
                    : Icon(
                        MdiIcons.packageVariantClosed,
                        size: 40,
                        color: Colors.grey[400],
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '฿${_currencyFormat.format(product.price)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      product.condition.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryProducts(ProductCategory category) {
    final provider = Provider.of<MarketplaceProvider>(context, listen: false);
    final products = provider.getProductsByCategory(category.id);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(category.name),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
          body: products.isEmpty
              ? const Center(child: Text('ไม่มีสินค้าในหมวดหมู่นี้'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) => _buildProductCard(products[index]),
                ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'instruments':
        return MdiIcons.toolbox;
      case 'materials':
        return MdiIcons.testTube;
      case 'equipment':
        return MdiIcons.hospitalBox;
      case 'chemicals':
        return MdiIcons.flask;
      case 'disposables':
        return MdiIcons.handHeart;
      case 'orthodontics':
        return MdiIcons.tooth;
      default:
        return MdiIcons.packageVariantClosed;
    }
  }
} 