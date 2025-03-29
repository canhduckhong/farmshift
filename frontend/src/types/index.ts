import { ShiftsState } from '../store/shiftsSlice';
import { User } from '../services/authService';

// Auth state interface
export interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  loading: boolean;
  error: string | null;
}

export interface RootState {
  shifts: ShiftsState;
  auth: AuthState;
}

export * from '../store/shiftsSlice';
