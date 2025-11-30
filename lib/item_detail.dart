import 'package:flutter/material.dart';
import 'models/track_item.dart';

class ItemDetailPage extends StatefulWidget {
  final TrackItem item;

  const ItemDetailPage({super.key, required this.item});

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late List<bool> segments;

  @override
    void initState() {
    super.initState();
    // Use the segments list from the item directly
    segments = widget.item.segments;
    }

  void updateCompleted() {
    widget.item.completed = segments.where((e) => e).length;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        widget.item.total == 0 ? 0 : widget.item.completed / widget.item.total;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 20,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: segments.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text('Segment ${index + 1}'),
                    value: segments[index],
                    onChanged: (bool? value) {
                        setState(() {
                            segments[index] = value ?? false;
                            widget.item.completed = segments.where((e) => e).length;
                        });
                    },
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
