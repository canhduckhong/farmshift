import { createSlice, PayloadAction, createAsyncThunk } from '@reduxjs/toolkit';
import { employeeService } from '../services/employeeService';

// Skills/qualifications available in the system
export const availableSkills = [
  'Milking', 
  'Feeding', 
  'Cleaning', 
  'Maintenance', 
  'Equipment Operation', 
  'Animal Health Monitoring', 
  'General Care', 
  'Veterinary Care'
];

// Shift requirements by time slot
export const shiftRequirements = {
  'Morning': ['Milking', 'Feeding', 'Cleaning'],
  'Afternoon': ['Maintenance', 'General Care', 'Feeding'],
  'Evening': ['Milking', 'Feeding', 'Animal Health Monitoring']
};

// Enhanced employee data with qualifications, preferences, etc.
export interface Employee {
  id: string;
  name: string;
  role: string;
  employmentType: 'fulltime' | 'parttime' | 'seasonal';
  skills: string[];
  preferences: {
    preferredShifts: string[];
    preferredDaysOff: string[];
  };
  maxShiftsPerWeek: number;
}

// Async thunks for API interactions
export const fetchEmployees = createAsyncThunk(
  'shifts/fetchEmployees',
  async () => {
    return await employeeService.fetchEmployees();
  }
);

export const createEmployee = createAsyncThunk(
  'shifts/createEmployee',
  async (employeeData: Omit<Employee, 'id'>) => {
    return await employeeService.createEmployee(employeeData);
  }
);

export const updateEmployee = createAsyncThunk(
  'shifts/updateEmployee',
  async (employee: Employee) => {
    return await employeeService.updateEmployee(employee);
  }
);

export const deleteEmployee = createAsyncThunk(
  'shifts/deleteEmployee',
  async (id: string) => {
    await employeeService.deleteEmployee(id);
    return id;
  }
);

// Shift interface
export interface Shift {
  id: string;
  day: string;
  timeSlot: string;
  employeeId: string | null;
  role: string | null;
}

// Validation rule interface
export interface ValidationRule {
  name: string;
  description: string;
  enabled: boolean;
}

// AI Scheduler config interface
export interface AISchedulerConfig {
  prioritizeSkillMatch: boolean;
  respectPreferences: boolean;
  enabledRules: ValidationRule[];
}

// Shifts state interface
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
  status: 'idle' | 'loading' | 'succeeded' | 'failed';
  error: string | null;
  availableSkills: string[];
}

const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const timeSlots = ['Morning', 'Afternoon', 'Evening'];

// Generate initial empty shifts
const initialShifts: Shift[] = [];
days.forEach(day => {
  timeSlots.forEach(timeSlot => {
    initialShifts.push({
      id: `${day}-${timeSlot}`,
      day,
      timeSlot,
      employeeId: null,
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
  employees: [],
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
  isEmployeeModalOpen: false,
  status: 'idle',
  error: null,
  availableSkills: availableSkills
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
          state.shifts[shiftIndex].employeeId = employeeId;
          state.shifts[shiftIndex].role = role;
        }
      }
      state.isModalOpen = false;
      state.selectedShift = null;
    },
    clearShift: (state, action: PayloadAction<string>) => {
      const shiftIndex = state.shifts.findIndex(shift => shift.id === action.payload);
      if (shiftIndex !== -1) {
        state.shifts[shiftIndex].employeeId = null;
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
    openNewEmployeeModal: (state) => {
      state.isEmployeeModalOpen = true;
      state.selectedEmployee = null;
    },
    closeEmployeeModal: (state) => {
      state.isEmployeeModalOpen = false;
      state.selectedEmployee = null;
    },
    selectEmployee: (state, action: PayloadAction<string>) => {
      const employee = state.employees.find(emp => emp.id === action.payload);
      if (employee) {
        state.selectedEmployee = employee;
        state.isEmployeeModalOpen = true;
      }
    },
    // Drag and drop functionality for shifts
    moveEmployeeBetweenShifts: (state, action: PayloadAction<{sourceShiftId: string; targetShiftId: string}>) => {
      const { sourceShiftId, targetShiftId } = action.payload;
      
      // Find the source and target shifts
      const sourceShiftIndex = state.shifts.findIndex(shift => shift.id === sourceShiftId);
      const targetShiftIndex = state.shifts.findIndex(shift => shift.id === targetShiftId);
      
      if (sourceShiftIndex !== -1 && targetShiftIndex !== -1) {
        const sourceShift = state.shifts[sourceShiftIndex];
        const targetShift = state.shifts[targetShiftIndex];
        
        // Only move if the source shift has an employee assigned
        if (sourceShift.employeeId) {
          // Save the employee data from source shift
          const sourceEmployeeId = sourceShift.employeeId;
          const sourceRole = sourceShift.role;
          
          // Check if target shift already has an employee assigned
          if (targetShift.employeeId) {
            // If target shift has an employee, perform a swap
            const targetEmployeeId = targetShift.employeeId;
            const targetRole = targetShift.role;
            
            // Move target employee to source shift
            state.shifts[sourceShiftIndex].employeeId = targetEmployeeId;
            state.shifts[sourceShiftIndex].role = targetRole;
          } else {
            // If target is empty, clear the source shift
            state.shifts[sourceShiftIndex].employeeId = null;
            state.shifts[sourceShiftIndex].role = null;
          }
          
          // Move source employee to target shift
          state.shifts[targetShiftIndex].employeeId = sourceEmployeeId;
          state.shifts[targetShiftIndex].role = sourceRole;
        }
      }
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch Employees
      .addCase(fetchEmployees.pending, (state) => {
        state.status = 'loading';
      })
      .addCase(fetchEmployees.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.employees = action.payload;
      })
      .addCase(fetchEmployees.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.error.message || 'Failed to fetch employees';
      })
      
      // Create Employee
      .addCase(createEmployee.fulfilled, (state, action) => {
        state.employees.push(action.payload);
        state.isEmployeeModalOpen = false;
      })
      
      // Update Employee
      .addCase(updateEmployee.fulfilled, (state, action) => {
        const index = state.employees.findIndex(emp => emp.id === action.payload.id);
        if (index !== -1) {
          state.employees[index] = action.payload;
        }
        state.isEmployeeModalOpen = false;
      })
      
      // Delete Employee
      .addCase(deleteEmployee.fulfilled, (state, action) => {
        state.employees = state.employees.filter(emp => emp.id !== action.payload);
      });
  }
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
  openNewEmployeeModal,
  closeEmployeeModal,
  selectEmployee
} = shiftsSlice.actions;

export default shiftsSlice.reducer;
