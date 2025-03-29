import axios from 'axios';

const API_URL = 'http://localhost:4000/api';

// Configure axios defaults for CORS
axios.defaults.withCredentials = true;

export interface User {
  id: string;
  email: string;
  name: string;
  role: string;
  inserted_at: string;
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
  } else {
    delete axios.defaults.headers.common['Authorization'];
  }
};

// Load token from localStorage on app initialization
const loadToken = () => {
  const token = localStorage.getItem('auth_token');
  if (token) {
    setAuthToken(token);
    return token;
  }
  return null;
};

// Register new user
const register = async (userData: RegisterData): Promise<User> => {
  try {
    const response = await axios.post<AuthResponse>(`${API_URL}/register`, { user: userData });
    
    const { token, user } = response.data.data;
    localStorage.setItem('auth_token', token);
    setAuthToken(token);
    
    return user;
  } catch (error) {
    throw error;
  }
};

// Login user
const login = async (credentials: LoginCredentials): Promise<User> => {
  try {
    const response = await axios.post<AuthResponse>(`${API_URL}/login`, credentials);
    
    const { token, user } = response.data.data;
    localStorage.setItem('auth_token', token);
    setAuthToken(token);
    
    return user;
  } catch (error) {
    throw error;
  }
};

// Logout user
const logout = async (): Promise<void> => {
  try {
    // Call logout API if user is logged in
    if (localStorage.getItem('auth_token')) {
      await axios.post(`${API_URL}/logout`);
    }
  } catch (error) {
    console.error('Logout error:', error);
  } finally {
    // Always clear local storage and headers
    localStorage.removeItem('auth_token');
    setAuthToken(null);
  }
};

// Get current user information
const getCurrentUser = async (): Promise<User | null> => {
  try {
    const token = loadToken();
    if (!token) return null;
    
    const response = await axios.get<{ status: string; data: { user: User } }>(`${API_URL}/current_user`);
    return response.data.data.user;
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
  loadToken
};

export default authService;
