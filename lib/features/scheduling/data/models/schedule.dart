class Schedule {
  const Schedule({
    required this.id,
    required this.category,
    required this.team1,
    required this.team2,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    this.caption,
    this.imageUrl,
    this.organizer,
  });

  final int id;
  final String category;
  final String team1;
  final String team2;
  final String location;
  final String date;
  final String time;
  final String status; // upcoming / completed / reviewable
  final String? caption;
  final String? imageUrl;
  final String? organizer;

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int,
      category: (json['category'] ?? '') as String,
      team1: (json['team1'] ?? '') as String,
      team2: (json['team2'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      date: (json['date'] ?? '') as String,
      time: (json['time'] ?? '') as String,
      status: (json['status'] ?? 'upcoming') as String,
      caption: json['caption'] as String?,
      imageUrl: json['image_url'] as String?,
      organizer: json['organizer'] as String?,
    );
  }
}


