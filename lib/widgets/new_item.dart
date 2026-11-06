import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _isSave = false;

  var _name = '';
  var _quantity = 1;
  var _selectedCategory =
      categories[Categories.dairy]!; // Added ! to ensure it's not null

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSave = true;
      });
      final url = Uri.https('shoppinglist-3a500-default-rtdb.firebaseio.com',
          'shopping-list.json');

      try {
        final response = await http.post(url,
            headers: {
              'Content-Type': 'Application/json',
            },
            body: jsonEncode({
              'name': _name,
              'quantity': _quantity,
              'category': _selectedCategory.title,
            }));
        if (!mounted) {
          return;
        }
        final data = jsonDecode(response.body);
        Navigator.of(context).pop(GroceryItem(
            id: data['name'],
            name: _name,
            quantity: _quantity,
            category: _selectedCategory));
      } catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Something went wrong! ${error.toString()}')));
        setState(() {
          _isSave = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey, // 👈 FIX 1: Attached the key to the Form
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (val) {
                  if (val == null ||
                      val.isEmpty ||
                      val.length <= 1 ||
                      val.length > 50) {
                    return 'Characters must be between 1 and 50'; // Fixed spelling
                  }
                  return null;
                },
                onSaved: (val) {
                  _name = val!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(label: Text('Quantity')),
                      initialValue: _quantity.toString(),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null ||
                            val.isEmpty ||
                            int.tryParse(val) == null ||
                            int.tryParse(val)! <= 0) {
                          return 'Please enter a valid number'; // Removed trailing space
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _quantity = int.tryParse(val!)!;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField<Category>(
                      // 👈 FIX 2: Added strict typing
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          )
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSave
                        ? null
                        : () {
                            _formKey.currentState!
                                .reset(); // Now this works perfectly
                          },
                    child: const Text(
                        'Reset'), // Changed "Remove" to "Reset" to reflect its action
                  ),
                  ElevatedButton(
                      onPressed: _isSave ? null : _onSave,
                      child: _isSave
                          ? const Center(
                              child: SizedBox(
                                  height: 12,
                                  width: 12,
                                  child: CircularProgressIndicator()),
                            )
                          : const Text('Add Item'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
