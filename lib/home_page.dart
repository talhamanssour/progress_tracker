import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/track_item.dart';
import 'add_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TrackItem> items = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  // Load items from local storage
  Future<void> loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList('items');
    if (data != null) {
      setState(() {
        items = data.map((e) => TrackItem.fromMap(jsonDecode(e))).toList();
      });
    }
  }

  // Save items to local storage
  Future<void> saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> data = items.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('items', data);
  }

  // Delete item
  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
      saveItems();
    });
  }

  // Toggle a segment
  void toggleSegment(TrackItem item, int index) {
    setState(() {
      item.segments[index] = !item.segments[index];
      item.completed = item.segments.where((e) => e).length;
      saveItems();
    });
  }

  // Group items by category
  Map<String, List<TrackItem>> groupItemsByCategory() {
    Map<String, List<TrackItem>> groupedItems = {};
    for (var item in items) {
      String cat = item.category ?? "No Category";
      if (!groupedItems.containsKey(cat)) {
        groupedItems[cat] = [];
      }
      groupedItems[cat]!.add(item);
    }
    return groupedItems;
  }

  // Build item card
  Widget buildItemCard(TrackItem item) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    setState(() {
                      items.remove(item);
                      saveItems();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Progress bar
            LinearProgressIndicator(
              value: item.total == 0 ? 0 : item.completed / item.total,
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            // Segments
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: List.generate(item.total, (segIndex) {
                    return GestureDetector(
                        onTap: () => toggleSegment(item, segIndex),
                        child: Container(
                        width: 20,   // small square
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                            color: item.segments[segIndex] ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                        ),
                        ),
                    );
                    }),
                ),
                ),
            const SizedBox(height: 4),
            Text(
              '${item.completed}/${item.total} completed',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = groupItemsByCategory(); // <- inside build()

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
      ),
      body: items.isEmpty
          ? const Center(child: Text('No items yet'))
          : ListView(
              padding: const EdgeInsets.all(8),
              children: groupedItems.keys.map((category) {
                final catItems = groupedItems[category]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        category,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Grid of items
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: catItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final item = catItems[index];
                        return buildItemCard(item);
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newItem = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemPage()),
          );
          if (newItem != null) {
            setState(() {
              items.add(newItem);
              saveItems();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
