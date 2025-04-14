import { createSlice, PayloadAction } from '@reduxjs/toolkit';

// Skills/qualifications available in the system
export const availableSkills = [
  'Milking',
  'Feeding',
  'Cleaning',
  'Maintenance',
  'Veterinary Care',
  'General Care',
  'Equipment Operation',
  'Animal Health Monitoring'
];

// Shift requirements by time slot
export const shiftRequirements = {
  '04:30-12:30': ['Milking', 'Feeding', 'Cleaning'],
  '12:30-20:30': ['Maintenance', 'General Care', 'Feeding'],
  '20:30-04:30': ['Cleaning', 'Feeding', 'Maintenance'],
};

// Enhanced employee data with qualifications, preferences, etc.
export const mockEmployees: Employee[] = [
  { 
    id: '1', 
    name: 'Anders Jensen', 
    role: 'Manager',
    employmentType: 'fulltime',
    skills: ['Milking', 'Feeding', 'Equipment Operation', 'Animal Health Monitoring'],
    preferences: { preferredShifts: ['Morning'], preferredDaysOff: ['Sunday'] },
    maxShiftsPerWeek: 5
  },
  { 
    id: '2', 
    name: 'Maria Poulsen', 
    role: 'Assistant Manager',
    employmentType: 'fulltime',
    skills: ['Milking', 'Feeding', 'Cleaning', 'Animal Health Monitoring'],
    preferences: { preferredShifts: ['Morning', 'Afternoon'], preferredDaysOff: ['Saturday', 'Sunday'] },
    maxShiftsPerWeek: 5
  },
  { 
    id: '3', 
    name: 'Piotr Kowalski', 
    role: 'Worker',
    employmentType: 'fulltime',
    skills: ['Feeding', 'Cleaning', 'Maintenance'],
    preferences: { preferredShifts: ['Afternoon', 'Evening'], preferredDaysOff: ['Monday'] },
    maxShiftsPerWeek: 6
  },
  { 
    id: '4', 
    name: 'Olga Ivanova', 
    role: 'Worker',
    employmentType: 'intern',
    skills: ['Cleaning', 'Feeding', 'General Care'],
    preferences: { preferredShifts: ['Morning'], preferredDaysOff: ['Wednesday', 'Sunday'] },
    maxShiftsPerWeek: 4
  },
  { 
    id: '5', 
    name: 'Juan Fernandez', 
    role: 'Worker',
    employmentType: 'fulltime',
    skills: ['Maintenance', 'Equipment Operation', 'Cleaning'],
    preferences: { preferredShifts: ['Afternoon'], preferredDaysOff: ['Sunday'] },
    maxShiftsPerWeek: 5
  },
  { 
    id: '6', 
    name: 'Sophia Larsen', 
    role: 'Veterinarian',
    employmentType: 'fulltime',
    skills: ['Veterinary Care', 'Animal Health Monitoring', 'General Care'],
    preferences: { preferredShifts: ['Morning', 'Afternoon'], preferredDaysOff: ['Saturday', 'Sunday'] },
    maxShiftsPerWeek: 5
  },
];

export const mockRoles = [
  'Milking',
  'Feeding',
  'Cleaning',
  'Maintenance',
  'Veterinary Care',
  'General Care',
  'Equipment Operation',
  'Animal Health Monitoring'
];

export interface EmployeePreferences {
  preferredShifts: string[];
  preferredDaysOff: string[];
}

export interface Employee {
  id: string;
  name: string;
  role: string;
  employmentType: 'fulltime' | 'intern';
  skills: string[];
  preferences: EmployeePreferences;
  maxShiftsPerWeek: number;
}

export interface Shift {
  id: string;
  day: string;
  timeSlot: string;
  employeeIds: string[];
  role: string | null;
}

export interface ValidationRule {
  name: string;
  description: string;
  enabled: boolean;
}

export interface AISchedulerConfig {
  prioritizeSkillMatch: boolean;
  respectPreferences: boolean;
  enabledRules: ValidationRule[];
}

export interface ShiftsState {
  shifts: Shift[];
  employees: Employee[];
  selectedShift: Shift | null;
  isModalOpen: boolean;
  aiConfig: AISchedulerConfig;
  isGeneratingSchedule: boolean;
  aiSuggestions: Shift[] | null;
  showSuggestions: boolean;
  selectedEmployee: Employee | null;
  isEmployeeModalOpen: boolean;
}

const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const timeSlots = ['04:30-12:30', '12:30-20:30', '20:30-04:30'];

// Generate initial empty shifts
const initialShifts: Shift[] = [];
days.forEach(day => {
  timeSlots.forEach(timeSlot => {
    initialShifts.push({
      id: `${day}-${timeSlot}`,
      day,
      timeSlot,
      employeeIds: [],
      role: null,
    });
  });
});

// Default validation rules for AI scheduling
const defaultValidationRules: ValidationRule[] = [
  {
    name: 'noConsecutiveShifts',
    description: 'No employee should work consecutive shifts in a day',
    enabled: true
  },
  {
    name: 'maxShiftsPerWeek',
    description: 'Respect maximum shifts per week based on employment type',
    enabled: true
  },
  {
    name: 'skillMatch',
    description: 'Employees should have the skills required for the shift',
    enabled: true
  },
  {
    name: 'respectDaysOff',
    description: 'Respect employee preferred days off when possible',
    enabled: true
  },
  {
    name: 'maxConsecutiveDays',
    description: 'No employee should work more than 6 consecutive days',
    enabled: true
  }
];

const initialState: ShiftsState = {
  shifts: initialShifts,
  employees: mockEmployees,
  selectedShift: null,
  isModalOpen: false,
  aiConfig: {
    prioritizeSkillMatch: true,
    respectPreferences: true,
    enabledRules: defaultValidationRules
  },
  isGeneratingSchedule: false,
  aiSuggestions: null,
  showSuggestions: false,
  selectedEmployee: null,
  isEmployeeModalOpen: false
};

export const shiftsSlice = createSlice({
  name: 'shifts',
  initialState,
  reducers: {
    selectShift: (state, action: PayloadAction<Shift>) => {
      state.selectedShift = action.payload;
      state.isModalOpen = true;
    },
    closeModal: (state) => {
      state.isModalOpen = false;
      state.selectedShift = null;
    },
    assignShift: (state, action: PayloadAction<{ employeeId: string; role: string | null }>) => {
      const { employeeId, role } = action.payload;
      if (state.selectedShift) {
        const shiftIndex = state.shifts.findIndex(shift => shift.id === state.selectedShift?.id);
        if (shiftIndex !== -1) {
          // Add the employee only if they're not already assigned to this shift
          if (!state.shifts[shiftIndex].employeeIds.includes(employeeId)) {
            state.shifts[shiftIndex].employeeIds.push(employeeId);
          }
          state.shifts[shiftIndex].role = role;
        }
      }
      state.isModalOpen = false;
      state.selectedShift = null;
    },
    clearShift: (state, action: PayloadAction<string>) => {
      const shiftIndex = state.shifts.findIndex(shift => shift.id === action.payload);
      if (shiftIndex !== -1) {
        state.shifts[shiftIndex].employeeIds = [];
        state.shifts[shiftIndex].role = null;
      }
    },
    // AI Scheduling related reducers
    startGeneratingSchedule: (state) => {
      state.isGeneratingSchedule = true;
      state.aiSuggestions = null;
    },
    setAiSuggestions: (state, action: PayloadAction<Shift[]>) => {
      state.aiSuggestions = action.payload;
      state.isGeneratingSchedule = false;
      state.showSuggestions = true;
    },
    toggleShowSuggestions: (state) => {
      state.showSuggestions = !state.showSuggestions;
    },
    applySuggestions: (state) => {
      if (state.aiSuggestions) {
        state.shifts = state.aiSuggestions;
        state.aiSuggestions = null;
        state.showSuggestions = false;
      }
    },
    discardSuggestions: (state) => {
      state.aiSuggestions = null;
      state.showSuggestions = false;
    },
    updateAiConfig: (state, action: PayloadAction<Partial<AISchedulerConfig>>) => {
      state.aiConfig = { ...state.aiConfig, ...action.payload };
    },
    toggleValidationRule: (state, action: PayloadAction<string>) => {
      const ruleName = action.payload;
      const ruleIndex = state.aiConfig.enabledRules.findIndex(rule => rule.name === ruleName);
      if (ruleIndex !== -1) {
        state.aiConfig.enabledRules[ruleIndex].enabled = !state.aiConfig.enabledRules[ruleIndex].enabled;
      }
    },
    
    // Employee Management
    addEmployee: (state, action: PayloadAction<Omit<Employee, 'id'>>) => {
      const newId = (Math.max(...state.employees.map(e => parseInt(e.id))) + 1).toString();
      const newEmployee = {
        ...action.payload,
        id: newId
      };
      state.employees.push(newEmployee);
    },

    updateEmployee: (state, action: PayloadAction<Employee>) => {
      const index = state.employees.findIndex(e => e.id === action.payload.id);
      if (index !== -1) {
        state.employees[index] = action.payload;
      }
    },

    deleteEmployee: (state, action: PayloadAction<string>) => {
      // Remove employee from shifts first
      state.shifts.forEach(shift => {
        // Remove the employee ID from any shifts they're assigned to
        if (shift.employeeIds.includes(action.payload)) {
          shift.employeeIds = shift.employeeIds.filter(id => id !== action.payload);
          // If shift now has no employees, clear the role
          if (shift.employeeIds.length === 0) {
            shift.role = null;
          }
        }
      });
      
      // Then remove from employees list
      state.employees = state.employees.filter(e => e.id !== action.payload);
    },

    selectEmployee: (state, action: PayloadAction<string>) => {
      state.selectedEmployee = state.employees.find(e => e.id === action.payload) || null;
      state.isEmployeeModalOpen = true;
    },

    closeEmployeeModal: (state) => {
      state.selectedEmployee = null;
      state.isEmployeeModalOpen = false;
    },

    openNewEmployeeModal: (state) => {
      state.selectedEmployee = null;
      state.isEmployeeModalOpen = true;
    },

    // Drag and drop functionality for shifts
    moveEmployeeBetweenShifts: (state, action: PayloadAction<{sourceShiftId: string; targetShiftId: string; employeeId: string}>) => {
      const { sourceShiftId, targetShiftId, employeeId } = action.payload;
      
      // Find the source and target shifts
      const sourceShiftIndex = state.shifts.findIndex(shift => shift.id === sourceShiftId);
      const targetShiftIndex = state.shifts.findIndex(shift => shift.id === targetShiftId);
      
      if (sourceShiftIndex !== -1 && targetShiftIndex !== -1) {
        const sourceShift = state.shifts[sourceShiftIndex];
        const targetShift = state.shifts[targetShiftIndex];
        
        // Only move if the source shift has the specified employee assigned
        if (sourceShift.employeeIds.includes(employeeId)) {
          // Save the role from source shift
          const sourceRole = sourceShift.role;
          
          // Remove employee from source shift
          state.shifts[sourceShiftIndex].employeeIds = sourceShift.employeeIds.filter(id => id !== employeeId);
          
          // If source shift is now empty, clear its role
          if (state.shifts[sourceShiftIndex].employeeIds.length === 0) {
            state.shifts[sourceShiftIndex].role = null;
          }
          
          // Add employee to target shift if not already there
          if (!targetShift.employeeIds.includes(employeeId)) {
            state.shifts[targetShiftIndex].employeeIds.push(employeeId);
          }
          
          // If target shift had no role, set it to the source role
          if (targetShift.role === null) {
            state.shifts[targetShiftIndex].role = sourceRole;
          }
        }
      }
    },
  },
});

export const {
  selectShift,
  closeModal,
  assignShift,
  clearShift,
  startGeneratingSchedule,
  setAiSuggestions,
  toggleShowSuggestions,
  applySuggestions,
  discardSuggestions,
  updateAiConfig,
  toggleValidationRule,
  moveEmployeeBetweenShifts,
  addEmployee,
  updateEmployee,
  deleteEmployee,
  selectEmployee,
  closeEmployeeModal,
  openNewEmployeeModal
} = shiftsSlice.actions;

export default shiftsSlice.reducer;
