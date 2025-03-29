import { ShiftsState } from '../store/shiftsSlice';

export interface RootState {
  shifts: ShiftsState;
}

export * from '../store/shiftsSlice';
