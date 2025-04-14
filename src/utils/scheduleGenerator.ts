import { Shift, Employee, ValidationRule, AISchedulerConfig, shiftRequirements } from '../store/shiftsSlice';

// Helper to check if an employee has the required skills for a shift
export const hasRequiredSkills = (employee: Employee, timeSlot: string): boolean => {
  const requiredSkills = shiftRequirements[timeSlot as keyof typeof shiftRequirements] || [];
  
  // Check if employee has at least one of the required skills
  return requiredSkills.some(skill => employee.skills.includes(skill));
};

// Check if an employee can be assigned to a shift based on validation rules
export const canAssignEmployeeToShift = (
  employee: Employee,
  day: string,
  timeSlot: string, 
  currentSchedule: Shift[],
  rules: ValidationRule[]
): boolean => {
  // If the employee doesn't have required skills and skill matching is enabled
  const skillMatchRule = rules.find(r => r.name === 'skillMatch');
  if (skillMatchRule?.enabled && !hasRequiredSkills(employee, timeSlot)) {
    return false;
  }

  // Check for consecutive shifts in the same day
  const noConsecutiveShiftsRule = rules.find(r => r.name === 'noConsecutiveShifts');
  if (noConsecutiveShiftsRule?.enabled) {
    const shiftsForEmployeeOnDay = currentSchedule.filter(
      shift => shift.employeeIds.includes(employee.id) && shift.day === day
    );
    
    if (shiftsForEmployeeOnDay.length > 0) {
      return false; // Already assigned to a shift on this day
    }
  }

  // Check for maximum shifts per week
  const maxShiftsPerWeekRule = rules.find(r => r.name === 'maxShiftsPerWeek');
  if (maxShiftsPerWeekRule?.enabled) {
    const shiftsForEmployeeThisWeek = currentSchedule.filter(
      shift => shift.employeeIds.includes(employee.id)
    );
    
    if (shiftsForEmployeeThisWeek.length >= employee.maxShiftsPerWeek) {
      return false; // Exceeded max shifts per week
    }
  }

  // Check for preferred days off
  const respectDaysOffRule = rules.find(r => r.name === 'respectDaysOff');
  if (respectDaysOffRule?.enabled && employee.preferences.preferredDaysOff.includes(day)) {
    return false; // This is a preferred day off
  }

  // Check for max consecutive days
  const maxConsecutiveDaysRule = rules.find(r => r.name === 'maxConsecutiveDays');
  if (maxConsecutiveDaysRule?.enabled) {
    // This requires a more complex analysis of the full week's schedule
    // For the MVP, we'll use a simplified check
    const daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const dayIndex = daysOfWeek.indexOf(day);
    
    // Check the 6 days prior to this day
    let consecutiveDays = 1; // Count today
    for (let i = 1; i <= 6; i++) {
      const prevDayIndex = (dayIndex - i + 7) % 7; // Circular array access
      const prevDay = daysOfWeek[prevDayIndex];
      
      // Check if employee is scheduled on the previous day
      const hasShiftOnPrevDay = currentSchedule.some(
        shift => shift.employeeIds.includes(employee.id) && shift.day === prevDay
      );
      
      if (hasShiftOnPrevDay) {
        consecutiveDays++;
      } else {
        break; // Chain broken
      }
    }
    
    if (consecutiveDays > 6) {
      return false; // Would exceed 6 consecutive days
    }
  }

  return true;
};

// Score a potential assignment based on preferences and other factors
export const scoreAssignment = (
  employee: Employee,
  day: string,
  timeSlot: string,
  config: AISchedulerConfig
): number => {
  let score = 0;
  
  // Base score
  score += 10;
  
  // Skill match bonus
  if (config.prioritizeSkillMatch && hasRequiredSkills(employee, timeSlot)) {
    score += 30;
  }
  
  // Preferred shift bonus
  if (config.respectPreferences && employee.preferences.preferredShifts.includes(timeSlot)) {
    score += 20;
  }
  
  // Preferred day bonus (avoid scheduling on preferred days off)
  if (config.respectPreferences && employee.preferences.preferredDaysOff.includes(day)) {
    score -= 15; // Penalty for scheduling on preferred day off
  }
  
  // Employment type factor (prefer full-time employees for critical shifts)
  if (employee.employmentType === 'fulltime') {
    score += 5;
  }
  
  // Special skills bonus (if employee has more relevant skills)
  const requiredSkills = shiftRequirements[timeSlot as keyof typeof shiftRequirements] || [];
  const matchingSkillsCount = requiredSkills.filter(skill => employee.skills.includes(skill)).length;
  score += matchingSkillsCount * 3;
  
  return score;
};

// Generate an optimal schedule based on employee qualifications, preferences, and rules
export const generateOptimalSchedule = (
  initialShifts: Shift[],
  // employees: Employee[],
  // config: AISchedulerConfig
): Shift[] => {
  // Create a copy of the initial shifts to work with
  const newSchedule: Shift[] = JSON.parse(JSON.stringify(initialShifts));
  
  // Clear all assignments first
  // newSchedule.forEach(shift => {
  //   shift.employeeId = null;
  //   shift.role = null;
  // });
  
  // // Get enabled rules
  // const enabledRules = config.enabledRules.filter(rule => rule.enabled);
  
  // // Sort shifts by priority (could be based on criticality, time of day, etc.)
  // const shifts = [...newSchedule].sort((a, b) => {
  //   // For now, prioritize Morning shifts, then Evening, then Afternoon
  //   const timeSlotOrder: { [key: string]: number } = {
  //     'Morning': 0,
  //     'Evening': 1,
  //     'Afternoon': 2,
  //   };
  //   return timeSlotOrder[a.timeSlot] - timeSlotOrder[b.timeSlot];
  // });
  
  // // For each shift, find the best employee
  // for (const shift of shifts) {
  //   // Get eligible employees for this shift
  //   const eligibleEmployees = employees.filter(employee => 
  //     canAssignEmployeeToShift(
  //       employee, 
  //       shift.day, 
  //       shift.timeSlot, 
  //       newSchedule,
  //       enabledRules
  //     )
  //   );
    
  //   if (eligibleEmployees.length > 0) {
  //     // Score each eligible employee
  //     const scoredEmployees = eligibleEmployees.map(employee => ({
  //       employee,
  //       score: scoreAssignment(employee, shift.day, shift.timeSlot, config)
  //     }));
      
  //     // Find employee with highest score
  //     const bestMatch = scoredEmployees.sort((a, b) => b.score - a.score)[0];
      
  //     // Assign the best employee to this shift
  //     const shiftIndex = newSchedule.findIndex(s => s.id === shift.id);
  //     if (shiftIndex !== -1) {
  //       newSchedule[shiftIndex].employeeId = bestMatch.employee.id;
        
  //       // Assign a role that matches skills
  //       const requiredSkills = shiftRequirements[shift.timeSlot as keyof typeof shiftRequirements] || [];
  //       const matchingSkill = bestMatch.employee.skills.find(skill => 
  //         requiredSkills.includes(skill)
  //       );
        
  //       newSchedule[shiftIndex].role = matchingSkill || null;
  //     }
  //   }
  // }
  
  return newSchedule;
};

// Simulate async API call for AI-powered scheduling
// export const generateScheduleAsync = async (
//   initialShifts: Shift[],
//   employees: Employee[],
//   config: AISchedulerConfig
// ): Promise<Shift[]> => {
//   return new Promise((resolve) => {
//     // Add a delay to simulate AI processing
//     setTimeout(() => {
//       const schedule = generateOptimalSchedule(initialShifts, employees, config);
//       resolve(schedule);
//     }, 1500);
//   });
// };
