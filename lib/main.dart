import 'package:flutter/material.dart';
import 'clothing_item.dart';
import 'database_helper.dart';

void main() {
  runApp(const ClothingStoreApp());
}

class ClothingStoreApp extends StatelessWidget {
  const ClothingStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clothing Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
      ),
      home: const ClothingCatalogScreen(),
    );
  }
}

class ClothingCatalogScreen extends StatefulWidget {
  const ClothingCatalogScreen({super.key});

  @override
  State<ClothingCatalogScreen> createState() => _ClothingCatalogScreenState();
}

class _ClothingCatalogScreenState extends State<ClothingCatalogScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _sizeController = TextEditingController();

  List<ClothingItem> _clothingList = [];

  @override
  void initState() {
    super.initState();
    _loadClothing();
  }

  void _loadClothing() async {
    final data = await ClothingDatabaseHelper.instance.getAllClothing();
    if (!mounted) return;
    setState(() => _clothingList = data);
  }

  void _addClothing() async {
    if (_nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _brandController.text.isEmpty ||
        _sizeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final item = ClothingItem(
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      brand: _brandController.text.trim(),
      size: _sizeController.text.trim(),
    );

    await ClothingDatabaseHelper.instance.insertClothing(item);
    _clearFields();
    _loadClothing();
  }

  void _clearFields() {
    _nameController.clear();
    _categoryController.clear();
    _brandController.clear();
    _sizeController.clear();
  }

  void _deleteClothing(int id) async {
    await ClothingDatabaseHelper.instance.deleteClothing(id);
    _loadClothing();
  }

  void _updateClothing(ClothingItem item) {
    _nameController.text = item.name;
    _categoryController.text = item.category;
    _brandController.text = item.brand;
    _sizeController.text = item.size;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Clothing Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: "Category")),
            TextField(controller: _brandController, decoration: const InputDecoration(labelText: "Brand")),
            TextField(controller: _sizeController, decoration: const InputDecoration(labelText: "Size")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final updated = ClothingItem(
                id: item.id,
                name: _nameController.text.trim(),
                category: _categoryController.text.trim(),
                brand: _brandController.text.trim(),
                size: _sizeController.text.trim(),
              );
              await ClothingDatabaseHelper.instance.updateClothing(updated);
              Navigator.pop(context);
              _clearFields();
              _loadClothing();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clothing Store Inventory")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: "Category")),
            TextField(controller: _brandController, decoration: const InputDecoration(labelText: "Brand")),
            TextField(controller: _sizeController, decoration: const InputDecoration(labelText: "Size")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addClothing, child: const Text("Add Clothing")),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _clothingList.length,
                itemBuilder: (context, index) {
                  final item = _clothingList[index];
                  return Card(
                    child: ListTile(
                      title: Text("${item.name} - ${item.brand}"),
                      subtitle: Text("Category: ${item.category} | Size: ${item.size}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () => _updateClothing(item),
                              icon: const Icon(Icons.edit, color: Colors.blue)),
                          IconButton(
                              onPressed: () => _deleteClothing(item.id!),
                              icon: const Icon(Icons.delete, color: Colors.red)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
