import axios from 'axios';
import { Employee } from '../store/shiftsSlice';
import { getAuthToken } from './authService';

const API_URL = process.env.REACT_APP_API_URL 
  ? `${process.env.REACT_APP_API_URL}/api` 
  : 'http://localhost:4000/api';

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

    const response = await axios.post(`${API_URL}/employees`, 
      { employee: employeeData }, 
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
    const response = await axios.put(`${API_URL}/employees/${id}`, 
      { employee: updateData }, 
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
