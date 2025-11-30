class TrackItem {
  String name;
  int total;
  int completed;
  List<bool> segments;
  String? category; // <- mark as nullable

  TrackItem({
    required this.name,
    required this.total,
    this.completed = 0,
    List<bool>? segments,
    this.category, // optional
  }) : segments = segments ?? List<bool>.filled(total, false);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'total': total,
      'completed': completed,
      'segments': segments,
      'category': category,
    };
  }

  factory TrackItem.fromMap(Map<String, dynamic> map) {
    return TrackItem(
      name: map['name'],
      total: map['total'],
      completed: map['completed'],
      segments: List<bool>.from(map['segments'] ?? List<bool>.filled(map['total'], false)),
      category: map['category'], // may be null
    );
  }
}
