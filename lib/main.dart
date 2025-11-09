import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_helper.dart';
import 'product.dart';  // Updated import to the new Product class

void main() {
  // ProductDatabaseHelper handles database init per platform, no FFI init here
  runApp(const FashionStoreApp());
}

class FashionStoreApp extends StatelessWidget {
  const FashionStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fashion Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,  // Changed to pink for a fashion-themed color scheme
        scaffoldBackgroundColor: Colors.grey[50],  // Light background for elegance
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(  // Fixed: Changed CardTheme to CardThemeData
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const ProductCatalogScreen(),
    );
  }
}

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductCatalogScreenState createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  List<Product> _products = [];
  double _averagePrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    try {
      final data = await ProductDatabaseHelper.instance.getAllProducts();
      double total = 0;
      for (var p in data) {
        total += p.price;
      }
      if (!mounted) return;
      setState(() {
        _products = data;
        _averagePrice = data.isNotEmpty ? total / data.length : 0.0;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error loading products: $e")),
      );
    }
  }

  void _addProduct() async {
    if (_nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _imageUrlController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all fields")),
      );
      return;
    }
    try {
      final newProduct = Product(
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      );

      await ProductDatabaseHelper.instance.insertProduct(newProduct);
      if (!mounted) return;

      _clearFields();
      _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Product added successfully!")),
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error in _addProduct: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error adding product: $e")),
      );
    }
  }

  void _clearFields() {
    _nameController.clear();
    _categoryController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
  }

  void _deleteProduct(int id) async {
    try {
      await ProductDatabaseHelper.instance.deleteProduct(id);
      if (!mounted) return;
      _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ Product deleted")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error deleting product: $e")),
      );
    }
  }

  void _updateProduct(Product product) async {
    _nameController.text = product.name;
    _categoryController.text = product.category;
    _priceController.text = product.price.toString();
    _descriptionController.text = product.description;
    _imageUrlController.text = product.imageUrl;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Product Name")),
            TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Category")),
            TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number),
            TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description")),
            TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: "Image URL")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final updatedProduct = Product(
                  id: product.id,
                  name: _nameController.text.trim(),
                  category: _categoryController.text.trim(),
                  price: double.tryParse(_priceController.text) ?? 0.0,
                  description: _descriptionController.text.trim(),
                  imageUrl: _imageUrlController.text.trim(),
                );
                await ProductDatabaseHelper.instance.updateProduct(updatedProduct);
                if (!mounted) return;
                _clearFields();
                Navigator.pop(context);
                _loadProducts();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✏️ Product updated successfully!")),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Error updating product: $e")),
                );
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🛍️ Fashion Store Catalog")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Product Name")),
            TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Category")),
            TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number),
            TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description")),
            TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: "Image URL")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addProduct, child: const Text("Add Product")),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    child: ListTile(
                      leading: product.imageUrl.isNotEmpty
                          ? Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 50),
                      title: Text("${product.name} - ${product.category}"),
                      subtitle: Text("Price: \$${product.price.toStringAsFixed(2)}\n${product.description}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () => _updateProduct(product),
                              icon: const Icon(Icons.edit, color: Colors.blue)),
                          IconButton(
                              onPressed: () => _deleteProduct(product.id!),
                              icon: const Icon(Icons.delete, color: Colors.red)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 1),
            Text(
              "📊 Average Price: \$${_averagePrice.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink),
            ),
          ],
        ),
      ),
    );
  }
}