class Employee {
  final String id;
  final String name;
  final String role;
  final String employmentType;
  final List<String> skills;
  final EmployeePreferences preferences;
  final int maxShiftsPerWeek;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.employmentType,
    required this.skills,
    required this.preferences,
    required this.maxShiftsPerWeek,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      employmentType: json['employmentType'] as String,
      skills: (json['skills'] as List).map((e) => e as String).toList(),
      preferences: EmployeePreferences.fromJson(json['preferences'] as Map<String, dynamic>),
      maxShiftsPerWeek: json['maxShiftsPerWeek'] as int,
    );
  }
}

class EmployeePreferences {
  final List<String> preferredShifts;
  final List<String> preferredDaysOff;

  EmployeePreferences({
    required this.preferredShifts,
    required this.preferredDaysOff,
  });

  factory EmployeePreferences.fromJson(Map<String, dynamic> json) {
    return EmployeePreferences(
      preferredShifts: (json['preferredShifts'] as List).map((e) => e as String).toList(),
      preferredDaysOff: (json['preferredDaysOff'] as List).map((e) => e as String).toList(),
    );
  }
}
