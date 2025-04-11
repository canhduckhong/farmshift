import { configureStore } from '@reduxjs/toolkit';
import shiftsReducer from './shiftsSlice';
import { RootState } from '../types';

export const store = configureStore({
  reducer: {
    shifts: shiftsReducer,
  },
});

// Inferred type for dispatch actions
export type AppDispatch = typeof store.dispatch;

export type { RootState };
