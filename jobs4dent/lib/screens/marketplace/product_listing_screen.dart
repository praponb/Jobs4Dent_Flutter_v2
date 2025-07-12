import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';

class ProductListingScreen extends StatefulWidget {
  final ProductModel? productToEdit;

  const ProductListingScreen({super.key, this.productToEdit});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  final List<XFile> _selectedImages = [];
  ProductCategory? _selectedCategory;
  ProductCondition _selectedCondition = ProductCondition.used;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _populateFormWithExistingProduct();
    }
  }

  void _populateFormWithExistingProduct() {
    final product = widget.productToEdit!;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _selectedCondition = product.condition;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
      _selectedCategory = marketplaceProvider.categories
          .firstWhere((cat) => cat.id == product.categoryId);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.productToEdit != null ? 'แก้ไขสินค้า' : 'ลงขายสินค้าใหม่',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProduct,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('บันทึก'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImageSection(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildPricingSection(),
            const SizedBox(height: 24),
            _buildCategorySection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รูปภาพสินค้า',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (_selectedImages.isNotEmpty) ...[
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      return _buildAddImageButton();
                    } else {
                      return _buildImageCard(_selectedImages[index], index);
                    }
                  },
                ),
              ),
            ] else ...[
              _buildAddImageButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: _pickImages,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(MdiIcons.plus, size: 32, color: Colors.grey),
            const Text('เพิ่มรูป'),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(XFile image, int index) {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: FileImage(File(image.path)),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImages.removeAt(index);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลพื้นฐาน',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                                  labelText: 'ชื่อสินค้า *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                                      return 'ต้องระบุชื่อสินค้า';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                                  labelText: 'คำอธิบาย *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                                      return 'ต้องระบุคำอธิบาย';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProductCondition>(
              value: _selectedCondition,
              decoration: const InputDecoration(
                                  labelText: 'สภาพสินค้า *',
                border: OutlineInputBorder(),
              ),
              items: ProductCondition.values.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(condition.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ราคา',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                                  labelText: 'ราคา (฿) *',
                border: OutlineInputBorder(),
                prefixText: '฿ ',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                                      return 'ต้องระบุราคา';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'กรุณาใส่ราคาที่ถูกต้อง';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'หมวดหมู่',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Consumer<MarketplaceProvider>(
              builder: (context, marketplaceProvider, child) {
                return DropdownButtonFormField<ProductCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'หมวดหมู่สินค้า *',
                    border: OutlineInputBorder(),
                  ),
                  items: marketplaceProvider.categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'กรุณาเลือกหมวดหมู่';
                    }
                    return null;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await ImagePicker().pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.take(5 - _selectedImages.length));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('เกิดข้อผิดพลาดในการเลือกรูปภาพ: $e')),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
      final user = authProvider.userModel!;

      final productId = widget.productToEdit?.id ?? marketplaceProvider.generateProductId();
      
      final product = ProductModel(
        id: productId,
        name: _nameController.text.trim(),
        imageUrls: [],
        price: double.parse(_priceController.text),
        originalPrice: null,
        promotionText: null,
        description: _descriptionController.text.trim(),
        specifications: '',
        usageInstructions: '',
        expirationDate: null,
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        condition: _selectedCondition,
        sellerId: user.userId,
        sellerName: user.userName,
        sellerEmail: user.email,
        sellerPhone: user.phoneNumber,
        sellerAvatar: user.profilePhotoUrl,
        sellerLocation: user.address,
        createdAt: widget.productToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        tags: [],
      );

      bool success;
      if (widget.productToEdit != null) {
        success = await marketplaceProvider.updateProduct(product, _selectedImages);
      } else {
        success = await marketplaceProvider.createProduct(product, _selectedImages);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.productToEdit != null 
                                    ? 'อัปเดตสินค้าเรียบร้อยแล้ว!'
                : 'ประกาศขายสินค้าเรียบร้อยแล้ว!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('บันทึกสินค้าไม่สำเร็จ กรุณาลองใหม่อีกครั้ง'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 