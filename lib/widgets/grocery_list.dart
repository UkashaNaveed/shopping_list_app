import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'shoppinglist-3a500-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.get(url);

      // 1. Handle error responses
      if (response.statusCode >= 400) {
        // Optionally set an error state to show in the UI
        setState(() {
          _error = ' Failed to load data';
        });
        return;
      }

      // 2. Handle empty database (Firebase returns literal string "null")
      if (response.body == 'null') {
        if (!mounted) return;
        setState(() {
          _groceryItems = [];
          _isLoading = false;
        });
        return;
      }

      // 3. Use Map<String, dynamic> instead of nested generic map
      final Map<String, dynamic> listData = jsonDecode(response.body);
      final List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere((cat) => cat.value.title == item.value['category'])
            .value;

        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }

      // 4. Ensure widget is still mounted before updating state
      if (!mounted) return;

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! ${error.toString()}';
      });
    }
  }

  void _addNewItem() async {
    final addItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (addItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(addItem);
    });
  }

  void _addDeleteItem(GroceryItem item) async {
    final indexItem = _groceryItems.indexOf(item);
    final url = Uri.https('shoppinglist-3a500-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    setState(() {
      _groceryItems.remove(item);
    });

    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        setState(() {
          _groceryItems.insert(indexItem, item);
        });
      }
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! ${error.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No Items Added Yet!'),
    );
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      content = Center(child: Text(_error!));
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Dismissible(
            key: ValueKey(_groceryItems[index].id),
            onDismissed: (direction) => _addDeleteItem(_groceryItems[index]),
            background: Container(
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(8)),
            ),
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: Container(
                width: 24,
                height: 24,
                color: _groceryItems[index].category.color,
              ),
              trailing: Text(
                _groceryItems[index].quantity.toString(),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(onPressed: _addNewItem, icon: const Icon(Icons.add))
        ],
      ),
      body: content,
    );
  }
}
