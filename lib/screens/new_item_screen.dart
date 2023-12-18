import 'package:flutter/material.dart';

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/model/category.dart';
import 'package:shopping_list/model/grocery_item.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  String? _nameValidator(String? text) {
    if (text == null ||
        text.isEmpty ||
        text.trim().length <= 1 ||
        text.trim().length > 50) {
      return 'Must be between 1 and 50 characters.';
    }
    return null;
  }

  String? _quantityValidator(String? text) {
    if (text == null ||
        text.isEmpty ||
        int.tryParse(text) == null ||
        int.tryParse(text)! <= 0) {
      return 'Must be a valid, positive number.';
    }
    return null;
  }

  void _onSelectDropdown(Category? selectedValue) {
    setState(() {
      _selectedCategory = selectedValue!;
    });
  }

  void _onResetForm() {
    _formKey.currentState!.reset();
  }

  void _onSubmitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).pop(
        GroceryItem(
          id: DateTime.now().toString(),
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  void _saveNameHandler(String? name) {
    _enteredName = name!;
  }

  void _saveQuantityHandler(String? quantity) {
    _enteredQuantity = int.parse(quantity!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: _nameValidator,
                onSaved: _saveNameHandler,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: _quantityValidator,
                      onSaved: _saveQuantityHandler,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
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
                                Text(category.value.name)
                              ],
                            ),
                          ),
                      ],
                      onChanged: _onSelectDropdown,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _onResetForm,
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _onSubmitForm,
                    child: const Text('Add a item'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
