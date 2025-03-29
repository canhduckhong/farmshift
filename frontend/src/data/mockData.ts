import { Employee } from '../store/shiftsSlice';

export const mockEmployees: Employee[] = [
  { 
    id: '1', 
    name: 'Anders Jensen', 
    role: 'Manager',
    employmentType: 'fulltime',
    skills: ['Management', 'Feeding', 'Milking'],
    preferences: {
      preferredShifts: ['Morning'],
      preferredDaysOff: ['Saturday', 'Sunday']
    },
    maxShiftsPerWeek: 5
  },
  { 
    id: '2', 
    name: 'Maria Poulsen', 
    role: 'Assistant Manager',
    employmentType: 'fulltime',
    skills: ['Management', 'Cleaning', 'Maintenance'],
    preferences: {
      preferredShifts: ['Afternoon'],
      preferredDaysOff: ['Sunday']
    },
    maxShiftsPerWeek: 5
  },
  { 
    id: '3', 
    name: 'Piotr Kowalski', 
    role: 'Worker',
    employmentType: 'fulltime',
    skills: ['Feeding', 'Milking', 'Cleaning'],
    preferences: {
      preferredShifts: ['Morning', 'Afternoon'],
      preferredDaysOff: ['Friday', 'Saturday']
    },
    maxShiftsPerWeek: 5
  },
  { 
    id: '4', 
    name: 'Olga Ivanova', 
    role: 'Worker',
    employmentType: 'fulltime',
    skills: ['Milking', 'Feeding', 'Veterinary Care'],
    preferences: {
      preferredShifts: ['Morning'],
      preferredDaysOff: ['Wednesday', 'Thursday']
    },
    maxShiftsPerWeek: 5
  },
  { 
    id: '5', 
    name: 'Juan Fernandez', 
    role: 'Worker',
    employmentType: 'intern',
    skills: ['Cleaning', 'Feeding', 'Maintenance'],
    preferences: {
      preferredShifts: ['Afternoon'],
      preferredDaysOff: ['Monday']
    },
    maxShiftsPerWeek: 3
  },
  { 
    id: '6', 
    name: 'Sophia Larsen', 
    role: 'Veterinarian',
    employmentType: 'fulltime',
    skills: ['Veterinary Care', 'Feeding', 'Milking'],
    preferences: {
      preferredShifts: ['Morning', 'Evening'],
      preferredDaysOff: ['Tuesday', 'Wednesday']
    },
    maxShiftsPerWeek: 4
  },
];

export const mockRoles = [
  'Milking',
  'Feeding',
  'Cleaning',
  'Maintenance',
  'Veterinary Care',
  'General'
];
