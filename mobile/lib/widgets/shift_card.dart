import 'package:flutter/material.dart';
import 'package:farmshift_mobile/models/employee.dart';
import 'package:farmshift_mobile/models/shift.dart';
import 'package:farmshift_mobile/services/mock_data.dart';
import 'package:farmshift_mobile/theme/app_theme.dart';

class ShiftCard extends StatelessWidget {
  final Shift shift;
  final Employee? employee;
  final bool showEmployeeName;
  
  const ShiftCard({
    super.key,
    required this.shift,
    this.employee,
    this.showEmployeeName = true,
  });

  @override
  Widget build(BuildContext context) {
    // If employee is not provided but shift has employeeId, fetch it
    final Employee? displayedEmployee = employee ?? 
      (shift.employeeId != null ? MockDataService().getEmployeeById(shift.employeeId!) : null);
    
    final bool isUserShift = employee != null && shift.employeeId == employee!.id;
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: isUserShift ? 2 : 1,
      color: isUserShift 
          ? AppTheme.primaryVeryLightColor 
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUserShift 
              ? AppTheme.primaryLightColor 
              : AppTheme.borderColor,
          width: isUserShift ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day and time header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  shift.day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    shift.timeSlot,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryDarkColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Employee info
            if (displayedEmployee != null) ...[
              if (showEmployeeName) ...[
                Text(
                  'Employee:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMediumColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayedEmployee.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Role
              if (shift.role != null) ...[
                Text(
                  'Role:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMediumColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    shift.role!,
                    style: TextStyle(
                      color: AppTheme.primaryDarkColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ] else ...[
              const Text(
                'No employee assigned',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
