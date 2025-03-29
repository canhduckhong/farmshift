class Shift {
  final String id;
  final String day;
  final String timeSlot;
  final String? employeeId;
  final String? role;

  Shift({
    required this.id,
    required this.day,
    required this.timeSlot,
    this.employeeId,
    this.role,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as String,
      day: json['day'] as String,
      timeSlot: json['timeSlot'] as String,
      employeeId: json['employeeId'] as String?,
      role: json['role'] as String?,
    );
  }

  bool get isAssigned => employeeId != null;
}
