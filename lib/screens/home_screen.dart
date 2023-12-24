import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/model/grocery_item.dart';
import 'package:shopping_list/screens/new_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GroceryItem> _groceryList = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroceryList();
  }

  void _loadGroceryList() async {
    final url = Uri.https('flutter-shop-733f2-default-rtdb.firebaseio.com',
        '/shopping-list.json');
    try {
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later.';
        _isLoading = false;
      });
    }

    if(response.body == 'null') {
      setState(() => _isLoading = false);
      return;
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((catItem) => catItem.value.name == item.value['category'])
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
    setState(() {
      _groceryList = loadedItems;
      _isLoading = false;
    });
    }catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
        _isLoading = false;
      });
    }
    
  }

  void _onNavigation() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItemScreen(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() => _groceryList.add(newItem));
  }

  void _onDismissItem(GroceryItem deletedItem, BuildContext context) async {
    final itemIndex = _groceryList.indexOf(deletedItem);
    setState(() => _groceryList.remove(deletedItem));

    final url = Uri.https(
        'flutter-shop-733f2-default-rtdb.firebaseio.com', '/shopping-list/${deletedItem.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Can not delete item. Please try again later.'),
          ),
        );
      }
      setState(() {
        _groceryList.insert(itemIndex, deletedItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget displayContent =
        const Center(child: Text('No item! Start by adding some.'));

    if (_isLoading) {
      displayContent = const Center(child: CircularProgressIndicator());
    }

    if (!_isLoading && _groceryList.isNotEmpty) {
      displayContent = ListView.builder(
        itemCount: _groceryList.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryList[index].id),
          onDismissed: (direction) =>
              _onDismissItem(_groceryList[index], context),
          child: ListTile(
            title: Text(_groceryList[index].name),
            leading: Container(
              decoration:
                  BoxDecoration(color: _groceryList[index].category.color),
              height: 24,
              width: 24,
            ),
            trailing: Text(
              _groceryList[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      displayContent = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _onNavigation,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: displayContent,
    );
  }
}
