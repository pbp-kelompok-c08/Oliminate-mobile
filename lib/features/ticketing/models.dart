
class Schedule {
  final int id;
  final String category;
  final String team1;
  final String team2;
  final String location;
  final String date;
  final String time;
  final String status;
  final String? imageUrl;
  final String? caption;
  final double? price;

  Schedule({
    required this.id,
    required this.category,
    required this.team1,
    required this.team2,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    this.imageUrl,
    this.caption,
    this.price,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      category: json['category'],
      team1: json['team1'],
      team2: json['team2'],
      location: json['location'],
      date: json['date'],
      time: json['time'],
      status: json['status'],
      imageUrl: json['image_url'],
      caption: json['caption'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    );
  }

  String get eventName => "${category.toUpperCase()}: $team1 vs $team2";
  String get formattedSchedule => "$date | ${time.substring(0, 5)}";
}

class Ticket {
  final String id;
  final String eventName;
  final String schedule;
  final double price;
  final String status;
  final bool isUsed;

  Ticket({
    required this.id,
    required this.eventName,
    required this.schedule,
    required this.price,
    required this.status,
    required this.isUsed,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      eventName: json['event_name'] ?? json['schedule'],
      schedule: json['schedule'],
      price: (json['price'] as num).toDouble(),
      status: json['status'],
      isUsed: json['is_used'],
    );
  }
}
