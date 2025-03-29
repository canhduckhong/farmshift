import 'package:flutter/material.dart';
import 'package:farmshift_mobile/models/shift.dart';
import 'package:farmshift_mobile/services/mock_data.dart';
import 'package:farmshift_mobile/theme/app_theme.dart';

class ScheduleTable extends StatelessWidget {
  final List<String> days;
  final List<String> timeSlots;
  final List<Shift> shifts;
  final String currentEmployeeId;

  const ScheduleTable({
    super.key,
    required this.days,
    required this.timeSlots,
    required this.shifts,
    required this.currentEmployeeId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        
        if (isLandscape && constraints.maxWidth >= 600) {
          return _buildHorizontalTable();
        } else {
          return _buildVerticalList();
        }
      },
    );
  }

  Widget _buildHorizontalTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with days
              Row(
                children: [
                  // Empty cell for the corner
                  Container(
                    width: 100,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Time',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Day headers
                  ...days.map((day) => Container(
                    width: 150,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      border: const Border(
                        left: BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                ],
              ),
              
              // Time slot rows
              ...timeSlots.map((timeSlot) {
                return Row(
                  children: [
                    // Time slot cell
                    Container(
                      width: 100,
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryVeryLightColor,
                        border: const Border(
                          top: BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                      child: Text(
                        timeSlot,
                        style: TextStyle(
                          color: AppTheme.primaryDarkColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Day cells
                    ...days.map((day) {
                      final shift = shifts.firstWhere(
                        (s) => s.day == day && s.timeSlot == timeSlot,
                        orElse: () => Shift(
                          id: '0',
                          day: day,
                          timeSlot: timeSlot,
                        ),
                      );
                      
                      return Container(
                        width: 150,
                        height: 100,
                        decoration: BoxDecoration(
                          color: shift.employeeId == currentEmployeeId
                              ? AppTheme.primaryVeryLightColor
                              : Colors.white,
                          border: Border(
                            top: const BorderSide(color: AppTheme.borderColor, width: 1),
                            left: const BorderSide(color: AppTheme.borderColor, width: 1),
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: _buildShiftCell(shift),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: days.length,
      itemBuilder: (context, dayIndex) {
        final day = days[dayIndex];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                day,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            
            // Time slots for this day
            ...timeSlots.map((timeSlot) {
              final shift = shifts.firstWhere(
                (s) => s.day == day && s.timeSlot == timeSlot,
                orElse: () => Shift(
                  id: '0',
                  day: day,
                  timeSlot: timeSlot,
                ),
              );
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Time slot
                    Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryVeryLightColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        timeSlot,
                        style: TextStyle(
                          color: AppTheme.primaryDarkColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Shift cell
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: shift.employeeId == currentEmployeeId
                              ? AppTheme.primaryVeryLightColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: shift.employeeId == currentEmployeeId
                                ? AppTheme.primaryLightColor
                                : AppTheme.borderColor,
                          ),
                        ),
                        child: _buildShiftCell(shift),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            // Divider between days
            if (dayIndex < days.length - 1)
              const Divider(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildShiftCell(Shift shift) {
    if (shift.employeeId == null) {
      return const Center(
        child: Text(
          'No assignment',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    final employee = MockDataService().getEmployeeById(shift.employeeId!);
    final bool isCurrentEmployee = shift.employeeId == currentEmployeeId;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Employee name
        Text(
          employee?.name ?? 'Unknown',
          style: TextStyle(
            fontWeight: isCurrentEmployee ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Role
        if (shift.role != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shift.role!,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryDarkColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
        if (isCurrentEmployee) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person,
                  size: 12,
                  color: AppTheme.primaryDarkColor,
                ),
                SizedBox(width: 2),
                Text(
                  'You',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDarkColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
