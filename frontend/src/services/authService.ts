import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL 
  ? `${process.env.REACT_APP_API_URL}` 
  : 'http://localhost:5000';

// Configure axios defaults for CORS
axios.defaults.withCredentials = true;

export interface User {
  id: number;
  email: string;
  name: string;
  created_at: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  email: string;
  password: string;
  name: string;
  role?: string;
}

export interface AuthResponse {
  status: string;
  data: {
    user: User;
    token: string;
  };
}

// Set token in axios headers
const setAuthToken = (token: string | null) => {
  if (token) {
    axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    console.log('Token set in headers:', token);
  } else {
    delete axios.defaults.headers.common['Authorization'];
    console.log('Token removed from headers');
  }
};

// Load token from localStorage on app initialization
const loadToken = () => {
  const token = localStorage.getItem('auth_token');
  if (token) {
    console.log('Token loaded from localStorage');
    setAuthToken(token);
    return token;
  }
  console.log('No token found in localStorage');
  return null;
};

// Get auth token 
export const getAuthToken = (): string | null => {
  return localStorage.getItem('auth_token');
};

// Register new user
const register = async (userData: RegisterData): Promise<User> => {
  try {
    const response = await axios.post<{ user: User; token: string }>(`${API_URL}/auth/register`, userData);
    
    const { token, user } = response.data;
    localStorage.setItem('auth_token', token);
    setAuthToken(token);
    
    return user;
  } catch (error) {
    console.error('Registration error:', error);
    throw error;
  }
};

// Login user
const login = async (credentials: LoginCredentials): Promise<User> => {
  try {
    const response = await axios.post<{ user: User; token: string }>(`${API_URL}/auth/login`, credentials);
    
    const { token, user } = response.data;
    localStorage.setItem('auth_token', token);
    setAuthToken(token);
    
    return user;
  } catch (error) {
    console.error('Login error:', error);
    throw error;
  }
};

// Logout user
const logout = async (): Promise<void> => {
  // Just clear local storage and headers since our backend is stateless
  localStorage.removeItem('auth_token');
  setAuthToken(null);
};

// Get current user information
const getCurrentUser = async (): Promise<User | null> => {
  try {
    const token = loadToken();
    if (!token) {
      console.log('No token found, cannot fetch current user');
      return null;
    }
    
    const response = await axios.get<User>(`${API_URL}/me`);
    console.log('Current user fetched successfully:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error fetching current user:', error);
    localStorage.removeItem('auth_token');
    setAuthToken(null);
    return null;
  }
};

// Check if user is authenticated
const isAuthenticated = (): boolean => {
  return localStorage.getItem('auth_token') !== null;
};

const authService = {
  register,
  login,
  logout,
  getCurrentUser,
  isAuthenticated,
  loadToken,
  getAuthToken
};

export default authService;
