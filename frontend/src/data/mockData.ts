import { Employee } from '../store/shiftsSlice';

export const mockEmployees: Employee[] = [
  { 
    id: '1', 
    name: 'Anders Jensen', 
    role: 'Manager',
    employmentType: 'fulltime',
    skills: ['Milking', 'Feeding', 'Equipment Operation', 'Animal Health Monitoring'],
    preferences: { preferredShifts: ['Morning'], preferredDaysOff: ['Sunday'] },
    maxShiftsPerWeek: 5
  },
  { 
    id: '2', 
    name: 'Maria Poulsen', 
    role: 'Assistant Manager',
    employmentType: 'fulltime',
    skills: ['Milking', 'Feeding', 'Cleaning', 'Animal Health Monitoring'],
    preferences: { preferredShifts: ['Morning', 'Afternoon'], preferredDaysOff: ['Saturday', 'Sunday'] },
    maxShiftsPerWeek: 5
  },
  { 
    id: '3', 
    name: 'Piotr Kowalski', 
    role: 'Worker',
    employmentType: 'fulltime',
    skills: ['Feeding', 'Cleaning', 'Maintenance'],
    preferences: { preferredShifts: ['Afternoon', 'Evening'], preferredDaysOff: ['Monday'] },
    maxShiftsPerWeek: 6
  },
  { 
    id: '4', 
    name: 'Olga Ivanova', 
    role: 'Worker',
    employmentType: 'parttime',
    skills: ['Cleaning', 'Feeding', 'General Care'],
    preferences: { preferredShifts: ['Morning'], preferredDaysOff: ['Wednesday', 'Sunday'] },
    maxShiftsPerWeek: 4
  },
  { 
    id: '5', 
    name: 'Juan Fernandez', 
    role: 'Worker',
    employmentType: 'fulltime',
    skills: ['Maintenance', 'Equipment Operation', 'Cleaning'],
    preferences: { preferredShifts: ['Afternoon'], preferredDaysOff: ['Sunday'] },
    maxShiftsPerWeek: 5
  },
  { 
    id: '6', 
    name: 'Sophia Larsen', 
    role: 'Veterinarian',
    employmentType: 'seasonal',
    skills: ['Veterinary Care', 'Animal Health Monitoring', 'General Care'],
    preferences: { preferredShifts: ['Morning', 'Afternoon'], preferredDaysOff: ['Saturday', 'Sunday'] },
    maxShiftsPerWeek: 5
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
