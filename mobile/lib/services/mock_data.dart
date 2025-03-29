import 'package:farmshift_mobile/models/employee.dart';
import 'package:farmshift_mobile/models/shift.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();

  factory MockDataService() {
    return _instance;
  }

  MockDataService._internal();

  final List<Employee> _employees = [
    Employee(
      id: '1',
      name: 'Anders Jensen',
      role: 'Manager',
      employmentType: 'fulltime',
      skills: ['Management', 'Feeding', 'Milking'],
      preferences: EmployeePreferences(
        preferredShifts: ['Morning'],
        preferredDaysOff: ['Saturday', 'Sunday'],
      ),
      maxShiftsPerWeek: 5,
    ),
    Employee(
      id: '2',
      name: 'Maria Poulsen',
      role: 'Assistant Manager',
      employmentType: 'fulltime',
      skills: ['Management', 'Cleaning', 'Maintenance'],
      preferences: EmployeePreferences(
        preferredShifts: ['Afternoon'],
        preferredDaysOff: ['Sunday'],
      ),
      maxShiftsPerWeek: 5,
    ),
    Employee(
      id: '3',
      name: 'Piotr Kowalski',
      role: 'Worker',
      employmentType: 'fulltime',
      skills: ['Feeding', 'Milking', 'Cleaning'],
      preferences: EmployeePreferences(
        preferredShifts: ['Morning', 'Afternoon'],
        preferredDaysOff: ['Friday', 'Saturday'],
      ),
      maxShiftsPerWeek: 5,
    ),
    Employee(
      id: '4',
      name: 'Olga Ivanova',
      role: 'Worker',
      employmentType: 'fulltime',
      skills: ['Milking', 'Feeding', 'Veterinary Care'],
      preferences: EmployeePreferences(
        preferredShifts: ['Morning'],
        preferredDaysOff: ['Wednesday', 'Thursday'],
      ),
      maxShiftsPerWeek: 5,
    ),
    Employee(
      id: '5',
      name: 'Juan Fernandez',
      role: 'Worker',
      employmentType: 'intern',
      skills: ['Cleaning', 'Feeding', 'Maintenance'],
      preferences: EmployeePreferences(
        preferredShifts: ['Afternoon'],
        preferredDaysOff: ['Monday'],
      ),
      maxShiftsPerWeek: 3,
    ),
    Employee(
      id: '6',
      name: 'Sophia Larsen',
      role: 'Veterinarian',
      employmentType: 'fulltime',
      skills: ['Veterinary Care', 'Feeding', 'Milking'],
      preferences: EmployeePreferences(
        preferredShifts: ['Morning', 'Evening'],
        preferredDaysOff: ['Tuesday', 'Wednesday'],
      ),
      maxShiftsPerWeek: 4,
    ),
  ];

  // Week starting from this Monday
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> _timeSlots = ['Morning', 'Afternoon', 'Evening'];

  // Generate shifts for the week
  List<Shift> _generateShifts() {
    List<Shift> shifts = [];
    int counter = 1;

    // Sample employee assignments - in a real app this would come from the backend
    final Map<String, Map<String, String>> assignments = {
      'Monday': {
        'Morning': '1',
        'Afternoon': '2',
        'Evening': '3',
      },
      'Tuesday': {
        'Morning': '4',
        'Afternoon': '5',
        'Evening': '1',
      },
      'Wednesday': {
        'Morning': '2',
        'Afternoon': '3',
        'Evening': '4',
      },
      'Thursday': {
        'Morning': '5',
        'Afternoon': '1',
        'Evening': '2',
      },
      'Friday': {
        'Morning': '3',
        'Afternoon': '4',
        'Evening': '5',
      },
      'Saturday': {
        'Morning': '6',
        'Afternoon': '6',
        'Evening': '6',
      },
      'Sunday': {
        'Morning': '4',
        'Afternoon': '5',
        'Evening': '3',
      },
    };

    // Role assignments for each shift
    final Map<String, String> roleAssignments = {
      '1': 'Management',
      '2': 'Cleaning',
      '3': 'Feeding',
      '4': 'Milking',
      '5': 'Maintenance',
      '6': 'Veterinary Care',
    };

    for (String day in _days) {
      for (String timeSlot in _timeSlots) {
        final employeeId = assignments[day]?[timeSlot];
        
        shifts.add(Shift(
          id: (counter++).toString(),
          day: day,
          timeSlot: timeSlot,
          employeeId: employeeId,
          role: employeeId != null ? roleAssignments[employeeId] : null,
        ));
      }
    }

    return shifts;
  }

  // Cached shifts
  late final List<Shift> _shifts = _generateShifts();

  // Public getters
  List<Employee> get employees => _employees;
  List<Shift> get shifts => _shifts;
  List<String> get days => _days;
  List<String> get timeSlots => _timeSlots;

  // Find employee by ID
  Employee? getEmployeeById(String id) {
    try {
      return _employees.firstWhere((employee) => employee.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get shifts for a specific employee
  List<Shift> getEmployeeShifts(String employeeId) {
    return _shifts.where((shift) => shift.employeeId == employeeId).toList();
  }
}
