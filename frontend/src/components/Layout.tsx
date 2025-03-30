import React, { useState, useRef, useEffect } from 'react';
import { Outlet, Link, useLocation, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useSelector, useDispatch } from 'react-redux';
import { RootState, AppDispatch } from '../store';
import { logout } from '../store/authSlice';
import LanguageSelector from './LanguageSelector';

const Layout: React.FC = () => {
  const { t } = useTranslation();
  const location = useLocation();
  const navigate = useNavigate();
  const dispatch = useDispatch<AppDispatch>();
  
  // State and ref for dropdown
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);
  
  // Get user information from the auth state
  const { user } = useSelector((state: RootState) => state.auth);
  
  const handleLogout = () => {
    dispatch(logout());
    navigate('/login');
  };

  // Effect to handle clicks outside of dropdown
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsDropdownOpen(false);
      }
    };

    // Add event listener
    document.addEventListener('mousedown', handleClickOutside);
    
    // Cleanup
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);
  
  return (
    <div className="min-h-screen flex flex-col">
      <header className="bg-primary-600 text-white shadow-md">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <Link to="/" className="text-2xl font-bold">FarmShift</Link>
          
          <div className="flex items-center">
            <nav className="flex space-x-4 mr-6">
              <Link 
                to="/schedule" 
                className={`px-3 py-2 rounded-md ${location.pathname === '/schedule' ? 'bg-primary-700 text-white' : 'hover:text-primary-200'}`}
              >
                {t('navigation.schedule')}
              </Link>
              <Link 
                to="/employees" 
                className={`px-3 py-2 rounded-md ${location.pathname === '/employees' ? 'bg-primary-700 text-white' : 'hover:text-primary-200'}`}
              >
                {t('navigation.employees')}
              </Link>
            </nav>
            
            <div className="flex items-center space-x-4">
              <LanguageSelector />
              
              {/* User info and logout */}
              <div 
                ref={dropdownRef}
                className="relative"
              >
                <button 
                  onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                  className="flex items-center space-x-1 focus:outline-none"
                >
                  <span className="text-sm font-medium">{user?.name}</span>
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clipRule="evenodd" />
                  </svg>
                </button>
                
                {/* Dropdown menu */}
                {isDropdownOpen && (
                  <div 
                    className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-10"
                  >
                    <div className="px-4 py-2 text-sm text-gray-700 border-b">
                      <div className="font-medium">{user?.name}</div>
                      <div className="text-gray-500">{user?.email}</div>
                      <div className="text-xs text-primary-600 mt-1">{user?.role}</div>
                    </div>
                    
                    <button
                      onClick={handleLogout}
                      className="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                    >
                      {t('auth.logout')}
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </header>
      
      <main className="flex-1 container mx-auto px-4 py-6">
        <Outlet />
      </main>
      
      <footer className="bg-gray-100 border-t">
        <div className="container mx-auto px-4 py-4 text-center text-gray-600">
          <p> {new Date().getFullYear()} FarmShift - Simple Scheduling for Danish Livestock Farms</p>
        </div>
      </footer>
    </div>
  );
};

export default Layout;
