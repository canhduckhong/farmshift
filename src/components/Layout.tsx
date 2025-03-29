import React from 'react';
import { Outlet, Link } from 'react-router-dom';

const Layout: React.FC = () => {
  return (
    <div className="min-h-screen flex flex-col">
      <header className="bg-primary-600 text-white shadow-md">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <Link to="/" className="text-2xl font-bold">FarmShift</Link>
          <nav className="flex space-x-4">
            <Link to="/schedule" className="hover:text-primary-200 px-3 py-2 rounded-md">
              Schedule
            </Link>
          </nav>
        </div>
      </header>
      <main className="flex-1 container mx-auto px-4 py-6">
        <Outlet />
      </main>
      <footer className="bg-gray-100 border-t">
        <div className="container mx-auto px-4 py-4 text-center text-gray-600">
          <p>© {new Date().getFullYear()} FarmShift - Simple Scheduling for Danish Livestock Farms</p>
        </div>
      </footer>
    </div>
  );
};

export default Layout;
