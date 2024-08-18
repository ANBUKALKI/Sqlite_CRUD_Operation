import 'package:flutter/material.dart';
import 'package:sqlite_crud_app/services/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite CRUD Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ItemListScreen(),
    );
  }
}

class ItemListScreen extends StatefulWidget {
  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _items = [];
  final TextEditingController _controller = TextEditingController();
  int? _selectedItemId;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  void _fetchItems() async {
    _items = await _dbHelper.readItems();
    setState(() {});
  }

  void _addItem() async {
    if (_controller.text.isNotEmpty) {
      await _dbHelper.createItem(_controller.text);
      _controller.clear();
      _fetchItems();
    }
  }

  void _updateItem() async {
    if (_selectedItemId != null && _controller.text.isNotEmpty) {
      await _dbHelper.updateItem(_selectedItemId!, _controller.text);
      _controller.clear();
      _selectedItemId = null; // Reset selected item ID
      _fetchItems();
    }
  }

  void _deleteItem(int id) async {
    await _dbHelper.deleteItem(id);
    _fetchItems();
  }

  void _editItem(Map<String, dynamic> item) {
    _controller.text = item['name'];
    _selectedItemId = item['id']; // Set selected item ID for updating
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SQLite CRUD Operation')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _addItem,
                child: Text('Add Item'),
              ),
              ElevatedButton(
                onPressed: _updateItem,
                child: Text('Update Item'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editItem(item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteItem(item['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}