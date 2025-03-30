import { AuthState } from './store/authSlice';
import { ShiftsState } from './store/shiftsSlice';
import { EmployeesState } from './store/employeesSlice';

export interface RootState {
  auth: AuthState;
  shifts: ShiftsState;
  employees: EmployeesState;
}
