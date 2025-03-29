import 'package:flutter/material.dart';
import 'package:farmshift_mobile/models/employee.dart';
import 'package:farmshift_mobile/models/shift.dart';
import 'package:farmshift_mobile/services/mock_data.dart';
import 'package:farmshift_mobile/screens/login_screen.dart';
import 'package:farmshift_mobile/theme/app_theme.dart';
import 'package:farmshift_mobile/widgets/shift_card.dart';
import 'package:farmshift_mobile/widgets/schedule_table.dart';
import 'package:farmshift_mobile/widgets/employee_info_card.dart';

class HomeScreen extends StatefulWidget {
  final String employeeId;

  const HomeScreen({
    super.key,
    required this.employeeId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Employee _employee;
  late final List<Shift> _employeeShifts;
  late final List<Shift> _allShifts;
  late final MockDataService _mockDataService;
  
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _mockDataService = MockDataService();
    _employee = _mockDataService.getEmployeeById(widget.employeeId)!;
    _employeeShifts = _mockDataService.getEmployeeShifts(widget.employeeId);
    _allShifts = _mockDataService.shifts;
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmShift'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Employee info card
          EmployeeInfoCard(employee: _employee),
          
          // Tab selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTabButton(0, 'My Schedule'),
                const SizedBox(width: 12),
                _buildTabButton(1, 'Full Schedule'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tab content
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildMyScheduleView()
                : _buildFullScheduleView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => _selectedTabIndex = index),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.primaryColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : AppTheme.primaryColor,
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildMyScheduleView() {
    if (_employeeShifts.isEmpty) {
      return const Center(
        child: Text('You have no shifts assigned this week'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _employeeShifts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final shift = _employeeShifts[index];
        return ShiftCard(
          shift: shift,
          employee: _employee,
          showEmployeeName: false,
        );
      },
    );
  }

  Widget _buildFullScheduleView() {
    return ScheduleTable(
      days: _mockDataService.days,
      timeSlots: _mockDataService.timeSlots,
      shifts: _allShifts,
      currentEmployeeId: _employee.id,
    );
  }
}
