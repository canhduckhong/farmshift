import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import SchedulePage from './pages/SchedulePage';
import EmployeesPage from './pages/EmployeesPage';

const App: React.FC = () => {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<Navigate to="/schedule" replace />} />
        <Route path="schedule" element={<SchedulePage />} />
        <Route path="employees" element={<EmployeesPage />} />
      </Route>
    </Routes>
  );
};

export default App;
