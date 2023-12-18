import 'package:flutter/material.dart';

import 'package:shopping_list/model/grocery_item.dart';
import 'package:shopping_list/screens/new_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<GroceryItem> _groceryList = [];

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

  void _onDismissItem(GroceryItem deletedItem) {
    setState(() => _groceryList.remove(deletedItem));
  }

  @override
  Widget build(BuildContext context) {
    Widget displayContent =
      const Center(child: Text('No item! Start by adding some.'));
      
    if (_groceryList.isNotEmpty) {
      displayContent = ListView.builder(
        itemCount: _groceryList.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryList[index].id),
          onDismissed: (direction) =>
              _onDismissItem(_groceryList[index]),
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
