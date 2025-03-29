import { configureStore } from '@reduxjs/toolkit';
import shiftsReducer from './shiftsSlice';
import authReducer from './authSlice';
import { RootState } from '../types';

export const store = configureStore({
  reducer: {
    shifts: shiftsReducer,
    auth: authReducer,
  },
});

// Inferred type for dispatch actions
export type AppDispatch = typeof store.dispatch;

export type { RootState };
