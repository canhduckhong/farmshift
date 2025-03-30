import axios from 'axios';
import { Employee } from '../store/shiftsSlice';
import { getAuthToken } from './authService';

const API_URL = process.env.REACT_APP_API_URL 
  ? `${process.env.REACT_APP_API_URL}/api` 
  : 'http://localhost:4000/api';

// Utility function to convert camelCase to snake_case
const camelToSnakeCase = (obj: any): any => {
  if (obj === null || typeof obj !== 'object') return obj;
  
  if (Array.isArray(obj)) {
    return obj.map(camelToSnakeCase);
  }
  
  const newObj: any = {};
  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      const snakeKey = key.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
      newObj[snakeKey] = camelToSnakeCase(obj[key]);
    }
  }
  
  return newObj;
};

export const employeeService = {
  async fetchEmployees(): Promise<Employee[]> {
    const token = getAuthToken();
    if (!token) {
      throw new Error('No authentication token');
    }

    const response = await axios.get(`${API_URL}/employees`, {
      headers: { 
        'Authorization': `Bearer ${token}` 
      }
    });
    return response.data.data;
  },

  async createEmployee(employeeData: Omit<Employee, 'id'>): Promise<Employee> {
    const token = getAuthToken();
    if (!token) {
      throw new Error('No authentication token');
    }

    // Convert keys to snake_case for backend
    const snakeCaseData = camelToSnakeCase({ employee: employeeData });

    const response = await axios.post(`${API_URL}/employees`, 
      snakeCaseData, 
      { headers: { 
        'Authorization': `Bearer ${token}` 
      }
    });
    return response.data.data;
  },

  async updateEmployee(employee: Employee): Promise<Employee> {
    const token = getAuthToken();
    if (!token) {
      throw new Error('No authentication token');
    }

    const { id, ...updateData } = employee;
    // Convert keys to snake_case for backend
    const snakeCaseData = camelToSnakeCase({ employee: updateData });

    const response = await axios.put(`${API_URL}/employees/${id}`, 
      snakeCaseData, 
      { headers: { 
        'Authorization': `Bearer ${token}` 
      }
    });
    return response.data.data;
  },

  async deleteEmployee(id: string): Promise<void> {
    const token = getAuthToken();
    if (!token) {
      throw new Error('No authentication token');
    }

    await axios.delete(`${API_URL}/employees/${id}`, {
      headers: { 
        'Authorization': `Bearer ${token}` 
      }
    });
  }
};
