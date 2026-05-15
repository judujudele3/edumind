class ScheduleModel {
  final String id;
  final String userId;
  final String subject;
  final String day;
  final String startTime;
  final String endTime;
  final String color;

  ScheduleModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.color,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map, String id) {
    return ScheduleModel(
      id: id,
      userId: map['userId'] ?? '',
      subject: map['subject'] ?? '',
      day: map['day'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      color: map['color'] ?? '#6C63FF',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'subject': subject,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'color': color,
    };
  }
}