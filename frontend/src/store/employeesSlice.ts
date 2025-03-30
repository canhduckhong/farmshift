import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { employeeService } from '../services/employeeService';
import { Employee } from './shiftsSlice';
import { RootState } from '../types';

export interface EmployeesState {
  employees: Employee[];
  selectedEmployee: Employee | null;
  isModalOpen: boolean;
  status: 'idle' | 'loading' | 'succeeded' | 'failed';
  error: string | null;
}

const initialState: EmployeesState = {
  employees: [],
  selectedEmployee: null,
  isModalOpen: false,
  status: 'idle',
  error: null
};

// Async Thunks for Employee Operations
export const fetchEmployees = createAsyncThunk(
  'employees/fetchEmployees',
  async (_, { rejectWithValue }) => {
    try {
      return await employeeService.fetchEmployees();
    } catch (error) {
      return rejectWithValue('Failed to fetch employees');
    }
  }
);

export const createEmployee = createAsyncThunk(
  'employees/createEmployee',
  async (employeeData: Omit<Employee, 'id'>, { rejectWithValue }) => {
    try {
      return await employeeService.createEmployee(employeeData);
    } catch (error) {
      return rejectWithValue('Failed to create employee');
    }
  }
);

export const updateEmployee = createAsyncThunk(
  'employees/updateEmployee',
  async (employee: Employee, { rejectWithValue }) => {
    try {
      return await employeeService.updateEmployee(employee);
    } catch (error) {
      return rejectWithValue('Failed to update employee');
    }
  }
);

export const deleteEmployee = createAsyncThunk(
  'employees/deleteEmployee',
  async (id: string, { rejectWithValue }) => {
    try {
      await employeeService.deleteEmployee(id);
      return id;
    } catch (error) {
      return rejectWithValue('Failed to delete employee');
    }
  }
);

export const employeesSlice = createSlice({
  name: 'employees',
  initialState,
  reducers: {
    openEmployeeModal: (state, action: PayloadAction<Employee | null>) => {
      state.isModalOpen = true;
      state.selectedEmployee = action.payload;
    },
    closeEmployeeModal: (state) => {
      state.isModalOpen = false;
      state.selectedEmployee = null;
    }
  },
  extraReducers: (builder) => {
    // Fetch Employees
    builder.addCase(fetchEmployees.pending, (state) => {
      state.status = 'loading';
    });
    builder.addCase(fetchEmployees.fulfilled, (state, action) => {
      state.status = 'succeeded';
      state.employees = action.payload;
    });
    builder.addCase(fetchEmployees.rejected, (state, action) => {
      state.status = 'failed';
      state.error = action.payload as string;
    });

    // Create Employee
    builder.addCase(createEmployee.fulfilled, (state, action) => {
      state.employees.push(action.payload);
      state.isModalOpen = false;
    });

    // Update Employee
    builder.addCase(updateEmployee.fulfilled, (state, action) => {
      const index = state.employees.findIndex(emp => emp.id === action.payload.id);
      if (index !== -1) {
        state.employees[index] = action.payload;
      }
      state.isModalOpen = false;
    });

    // Delete Employee
    builder.addCase(deleteEmployee.fulfilled, (state, action) => {
      state.employees = state.employees.filter(emp => emp.id !== action.payload);
    });
  }
});

// Export actions and reducer
export const { 
  openEmployeeModal, 
  closeEmployeeModal 
} = employeesSlice.actions;

export default employeesSlice.reducer;

// Selector functions
export const selectEmployees = (state: RootState) => state.employees.employees;
export const selectSelectedEmployee = (state: RootState) => state.employees.selectedEmployee;
export const selectEmployeeModalOpen = (state: RootState) => state.employees.isModalOpen;
