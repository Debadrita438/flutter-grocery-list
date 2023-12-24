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
  late Future<List<GroceryItem>> _loadedGroceryItems;

  @override
  void initState() {
    super.initState();
    _loadedGroceryItems = _loadGroceryList();
  }

  Future<List<GroceryItem>> _loadGroceryList() async {
    final url = Uri.https('flutter-shop-733f2-default-rtdb.firebaseio.com',
        '/shopping-list.json');

    final response = await http.get(url);
    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery items, please try again later.');
    }

    if (response.body == 'null') {
      return [];
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
    return loadedItems;
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

    final url = Uri.https('flutter-shop-733f2-default-rtdb.firebaseio.com',
        '/shopping-list/${deletedItem.id}.json');
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
      body: FutureBuilder(
        future: _loadedGroceryItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No item! Start by adding some.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => Dismissible(
              key: ValueKey(snapshot.data![index].id),
              onDismissed: (direction) =>
                  _onDismissItem(snapshot.data![index], context),
              child: ListTile(
                title: Text(snapshot.data![index].name),
                leading: Container(
                  decoration:
                      BoxDecoration(color: snapshot.data![index].category.color),
                  height: 24,
                  width: 24,
                ),
                trailing: Text(
                  snapshot.data![index].quantity.toString(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
