import React, { useEffect } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import Layout from './components/Layout';
import PrivateRoute from './components/PrivateRoute';
import SchedulePage from './pages/SchedulePage';
import EmployeesPage from './pages/EmployeesPage';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import { loadUser } from './store/authSlice';
import { AppDispatch } from './store';
import authService from './services/authService';

const App: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  
  useEffect(() => {
    // Initialize auth token if it exists in local storage
    authService.loadToken();
    
    // Try to load the user data if token exists
    dispatch(loadUser());
  }, [dispatch]);
  
  return (
    <Routes>
      {/* Public routes */}
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />
      
      {/* Protected routes */}
      <Route element={<PrivateRoute />}>
        <Route path="/" element={<Layout />}>
          <Route index element={<Navigate to="/schedule" replace />} />
          <Route path="schedule" element={<SchedulePage />} />
          <Route path="employees" element={<EmployeesPage />} />
        </Route>
      </Route>
    </Routes>
  );
};

export default App;
