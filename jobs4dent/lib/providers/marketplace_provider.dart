import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';

class MarketplaceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<ProductModel> _products = [];
  List<ProductModel> _myProducts = [];
  List<ProductCategory> _categories = [];
  List<ProductModel> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';
  ProductSearchFilters _searchFilters = ProductSearchFilters();

  // Getters
  List<ProductModel> get products => _products;
  List<ProductModel> get myProducts => _myProducts;
  List<ProductCategory> get categories => _categories;
  List<ProductModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  ProductSearchFilters get searchFilters => _searchFilters;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Initialize marketplace data
  Future<void> initializeMarketplace() async {
    _setLoading(true);
    try {
      await Future.wait([loadProducts(), loadCategories()]);
    } catch (e) {
      debugPrint('Error initializing marketplace: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all active products
  Future<void> loadProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _products = querySnapshot.docs
          .map((doc) => ProductModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  // Load user's own products
  Future<void> loadMyProducts(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _myProducts = querySnapshot.docs
          .map((doc) => ProductModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading my products: $e');
    }
  }

  // Load product categories
  Future<void> loadCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('product_categories')
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Initialize with default categories if none exist
        await _initializeDefaultCategories();
        _categories = DentalProductCategories.defaultCategories;
      } else {
        _categories = querySnapshot.docs
            .map(
              (doc) => ProductCategory.fromMap({...doc.data(), 'id': doc.id}),
            )
            .toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      // Fall back to default categories
      _categories = DentalProductCategories.defaultCategories;
      notifyListeners();
    }
  }

  // Initialize default categories in Firestore
  Future<void> _initializeDefaultCategories() async {
    try {
      final batch = _firestore.batch();

      for (final category in DentalProductCategories.defaultCategories) {
        final docRef = _firestore
            .collection('product_categories')
            .doc(category.id);
        batch.set(docRef, category.toMap());
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error initializing default categories: $e');
    }
  }

  // Upload product images
  Future<List<String>> uploadProductImages(
    List<XFile> imageFiles,
    String productId,
  ) async {
    List<String> imageUrls = [];

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final file = File(imageFiles[i].path);
        final fileName = '${productId}_$i.jpg';
        final ref = _storage
            .ref()
            .child('products')
            .child(productId)
            .child(fileName);

        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
    } catch (e) {
      debugPrint('Error uploading images: $e');
      rethrow;
    }

    return imageUrls;
  }

  // Create a new product
  Future<bool> createProduct(
    ProductModel product,
    List<XFile>? imageFiles,
  ) async {
    try {
      _setLoading(true);

      List<String> imageUrls = [];
      if (imageFiles != null && imageFiles.isNotEmpty) {
        imageUrls = await uploadProductImages(imageFiles, product.id);
      }

      final productWithImages = product.copyWith(imageUrls: imageUrls);

      await _firestore
          .collection('products')
          .doc(product.id)
          .set(productWithImages.toMap());

      _products.insert(0, productWithImages);
      _myProducts.insert(0, productWithImages);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing product
  Future<bool> updateProduct(
    ProductModel product,
    List<XFile>? newImageFiles,
  ) async {
    try {
      _setLoading(true);

      List<String> imageUrls = product.imageUrls;
      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        // Delete old images if new ones are uploaded
        await _deleteProductImages(product.id);
        imageUrls = await uploadProductImages(newImageFiles, product.id);
      }

      final updatedProduct = product.copyWith(
        imageUrls: imageUrls,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('products')
          .doc(product.id)
          .update(updatedProduct.toMap());

      // Update in local lists
      final productIndex = _products.indexWhere((p) => p.id == product.id);
      if (productIndex != -1) {
        _products[productIndex] = updatedProduct;
      }

      final myProductIndex = _myProducts.indexWhere((p) => p.id == product.id);
      if (myProductIndex != -1) {
        _myProducts[myProductIndex] = updatedProduct;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a product
  Future<bool> deleteProduct(String productId) async {
    try {
      _setLoading(true);

      // Delete images from storage
      await _deleteProductImages(productId);

      // Delete from Firestore
      await _firestore.collection('products').doc(productId).delete();

      // Remove from local lists
      _products.removeWhere((p) => p.id == productId);
      _myProducts.removeWhere((p) => p.id == productId);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete product images from storage
  Future<void> _deleteProductImages(String productId) async {
    try {
      final listResult = await _storage
          .ref()
          .child('products')
          .child(productId)
          .listAll();

      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      debugPrint('Error deleting product images: $e');
    }
  }

  // Search products with filters
  Future<void> searchProducts(
    String query,
    ProductSearchFilters filters,
  ) async {
    try {
      _setLoading(true);
      _searchQuery = query;
      _searchFilters = filters;

      Query<Map<String, dynamic>> queryRef = _firestore
          .collection('products')
          .where('isActive', isEqualTo: true);

      // Apply category filter
      if (filters.categoryId != null && filters.categoryId!.isNotEmpty) {
        queryRef = queryRef.where('categoryId', isEqualTo: filters.categoryId);
      }

      // Apply condition filter
      if (filters.condition != null) {
        queryRef = queryRef.where(
          'condition',
          isEqualTo: filters.condition.toString().split('.').last,
        );
      }

      // Apply price range filter
      if (filters.minPrice != null) {
        queryRef = queryRef.where(
          'price',
          isGreaterThanOrEqualTo: filters.minPrice,
        );
      }
      if (filters.maxPrice != null) {
        queryRef = queryRef.where(
          'price',
          isLessThanOrEqualTo: filters.maxPrice,
        );
      }

      final querySnapshot = await queryRef.get();

      List<ProductModel> results = querySnapshot.docs
          .map((doc) => ProductModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Apply text search filter
      if (query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        results = results
            .where(
              (product) =>
                  product.name.toLowerCase().contains(lowercaseQuery) ||
                  product.description.toLowerCase().contains(lowercaseQuery) ||
                  product.tags.any(
                    (tag) => tag.toLowerCase().contains(lowercaseQuery),
                  ) ||
                  product.categoryName.toLowerCase().contains(lowercaseQuery),
            )
            .toList();
      }

      // Apply location filter
      if (filters.location != null && filters.location!.isNotEmpty) {
        results = results
            .where(
              (product) =>
                  product.sellerLocation?.toLowerCase().contains(
                    filters.location!.toLowerCase(),
                  ) ??
                  false,
            )
            .toList();
      }

      // Sort results
      results.sort((a, b) {
        switch (filters.sortBy) {
          case ProductSortBy.priceAsc:
            return a.price.compareTo(b.price);
          case ProductSortBy.priceDesc:
            return b.price.compareTo(a.price);
          case ProductSortBy.newest:
            return b.createdAt.compareTo(a.createdAt);
          case ProductSortBy.oldest:
            return a.createdAt.compareTo(b.createdAt);
          case ProductSortBy.mostViewed:
            return b.viewCount.compareTo(a.viewCount);
        }
      });

      _searchResults = results;
      notifyListeners();
    } catch (e) {
      debugPrint('Error searching products: $e');
      _searchResults = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Get product by ID
  Future<ProductModel?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        // Increment view count
        await _firestore.collection('products').doc(productId).update({
          'viewCount': FieldValue.increment(1),
        });

        return ProductModel.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      debugPrint('Error getting product: $e');
      return null;
    }
  }

  // Increment inquiry count
  Future<void> incrementInquiryCount(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'inquiryCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing inquiry count: $e');
    }
  }

  // Get products by category
  List<ProductModel> getProductsByCategory(String categoryId) {
    return _products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  // Get featured products (most viewed/newest)
  List<ProductModel> getFeaturedProducts({int limit = 10}) {
    final featured = [..._products];
    featured.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return featured.take(limit).toList();
  }

  // Clear search results
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _searchFilters = ProductSearchFilters();
    notifyListeners();
  }

  // Generate unique product ID
  String generateProductId() {
    return const Uuid().v4();
  }

  // Load seller's products from user sub-collection (new structure)
  Future<void> fetchSellerProducts(String sellerId) async {
    try {
      _setLoading(true);

      // Load from main products collection
      final productsQuery = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      _myProducts = productsQuery.docs
          .map((doc) => ProductModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching seller products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create product with dual storage (main collection + user sub-collection)
  Future<bool> createProductWithUserStorage(
    ProductModel product,
    List<XFile>? imageFiles,
  ) async {
    try {
      _setLoading(true);

      List<String> imageUrls = [];
      if (imageFiles != null && imageFiles.isNotEmpty) {
        imageUrls = await uploadProductImages(imageFiles, product.id);
      }

      final productWithImages = product.copyWith(imageUrls: imageUrls);

      // Store in main products collection
      await _firestore
          .collection('products')
          .doc(product.id)
          .set(productWithImages.toMap());

      // Store in user's marketplace_products sub-collection
      await _firestore
          .collection('users')
          .doc(product.sellerId)
          .collection('marketplace_products')
          .doc(product.id)
          .set(productWithImages.toMap());

      _products.insert(0, productWithImages);
      _myProducts.insert(0, productWithImages);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating product with user storage: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update product in both locations
  Future<bool> updateProductWithUserStorage(
    ProductModel product,
    List<XFile>? newImageFiles,
  ) async {
    try {
      _setLoading(true);

      List<String> imageUrls = product.imageUrls;
      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        await _deleteProductImages(product.id);
        imageUrls = await uploadProductImages(newImageFiles, product.id);
      }

      final updatedProduct = product.copyWith(
        imageUrls: imageUrls,
        updatedAt: DateTime.now(),
      );

      // Update in main products collection
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(updatedProduct.toMap());

      // Update in user's marketplace_products sub-collection
      await _firestore
          .collection('users')
          .doc(product.sellerId)
          .collection('marketplace_products')
          .doc(product.id)
          .update(updatedProduct.toMap());

      // Update local lists
      final productIndex = _products.indexWhere(
        (p) => p.id == updatedProduct.id,
      );
      if (productIndex != -1) {
        _products[productIndex] = updatedProduct;
      }

      final myProductIndex = _myProducts.indexWhere(
        (p) => p.id == updatedProduct.id,
      );
      if (myProductIndex != -1) {
        _myProducts[myProductIndex] = updatedProduct;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating product with user storage: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete product from both locations
  Future<bool> deleteProductWithUserStorage(
    String productId,
    String sellerId,
  ) async {
    try {
      _setLoading(true);

      // Delete from main products collection
      await _firestore.collection('products').doc(productId).delete();

      // Delete from user's marketplace_products sub-collection
      await _firestore
          .collection('users')
          .doc(sellerId)
          .collection('marketplace_products')
          .doc(productId)
          .delete();

      // Delete associated images
      await _deleteProductImages(productId);

      // Remove from local lists
      _products.removeWhere((product) => product.id == productId);
      _myProducts.removeWhere((product) => product.id == productId);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting product with user storage: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}

// Search filters class
class ProductSearchFilters {
  String? categoryId;
  ProductCondition? condition;
  double? minPrice;
  double? maxPrice;
  String? location;
  ProductSortBy sortBy;

  ProductSearchFilters({
    this.categoryId,
    this.condition,
    this.minPrice,
    this.maxPrice,
    this.location,
    this.sortBy = ProductSortBy.newest,
  });

  bool get hasActiveFilters =>
      categoryId != null ||
      condition != null ||
      minPrice != null ||
      maxPrice != null ||
      location != null;

  void clear() {
    categoryId = null;
    condition = null;
    minPrice = null;
    maxPrice = null;
    location = null;
    sortBy = ProductSortBy.newest;
  }
}

enum ProductSortBy { newest, oldest, priceAsc, priceDesc, mostViewed }
