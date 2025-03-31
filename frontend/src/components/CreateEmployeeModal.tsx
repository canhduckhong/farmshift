import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { AppDispatch } from '../store';
import { createEmployee, closeEmployeeModal } from '../store/employeesSlice';
import { Employee } from '../store/shiftsSlice';
import { availableSkills } from '../store/shiftsSlice';
import Modal from './Modal';

// Define EmployeePreferences type
export interface EmployeePreferences {
  preferredShifts: string[];
  preferredDaysOff: string[];
}

const CreateEmployeeModal: React.FC<{ isOpen: boolean }> = ({ isOpen }) => {
  const { t } = useTranslation();
  const dispatch: AppDispatch = useDispatch();
  
  const [name, setName] = useState('');
  const [role, setRole] = useState('');
  const [employmentType, setEmploymentType] = useState<'fulltime' | 'parttime' | 'seasonal'>('fulltime');
  const [skills, setSkills] = useState<string[]>([]);
  const [maxShiftsPerWeek, setMaxShiftsPerWeek] = useState(5);
  const [preferredShifts, setPreferredShifts] = useState<string[]>([]);
  const [preferredDaysOff, setPreferredDaysOff] = useState<string[]>([]);
  
  const timeSlots = ['Morning', 'Afternoon', 'Evening'];
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    const preferences: EmployeePreferences = {
      preferredShifts,
      preferredDaysOff
    };
    
    // Add new employee
    const newEmployee: Omit<Employee, 'id'> = {
      name,
      role,
      employmentType,
      skills,
      preferences,
      maxShiftsPerWeek
    };
    
    dispatch(createEmployee(newEmployee));
    dispatch(closeEmployeeModal());
  };
  
  const handleClose = () => {
    dispatch(closeEmployeeModal());
  };
  
  const toggleSkill = (skill: string) => {
    if (skills.includes(skill)) {
      setSkills(skills.filter(s => s !== skill));
    } else {
      setSkills([...skills, skill]);
    }
  };
  
  const togglePreferredShift = (shift: string) => {
    if (preferredShifts.includes(shift)) {
      setPreferredShifts(preferredShifts.filter(s => s !== shift));
    } else {
      setPreferredShifts([...preferredShifts, shift]);
    }
  };
  
  const togglePreferredDayOff = (day: string) => {
    if (preferredDaysOff.includes(day)) {
      setPreferredDaysOff(preferredDaysOff.filter(d => d !== day));
    } else {
      setPreferredDaysOff([...preferredDaysOff, day]);
    }
  };

  return (
    <Modal 
      isOpen={isOpen} 
      onClose={handleClose}
      title={t('employees.addEmployee')}
    >
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
            {t('employees.name')}
          </label>
          <input
            id="name"
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full border border-gray-300 rounded-md py-2 px-3 focus:outline-none focus:ring-2 focus:ring-primary-500"
            required
          />
        </div>

        <div className="mb-4">
          <label htmlFor="role" className="block text-sm font-medium text-gray-700 mb-1">
            {t('employees.role')}
          </label>
          <input
            id="role"
            type="text"
            value={role}
            onChange={(e) => setRole(e.target.value)}
            className="w-full border border-gray-300 rounded-md py-2 px-3 focus:outline-none focus:ring-2 focus:ring-primary-500"
            required
          />
        </div>

        <div className="mb-4">
          <label htmlFor="employmentType" className="block text-sm font-medium text-gray-700 mb-1">
            {t('employees.employmentType')}
          </label>
          <select
            id="employmentType"
            value={employmentType}
            onChange={(e) => setEmploymentType(e.target.value as 'fulltime' | 'parttime' | 'seasonal')}
            className="w-full border border-gray-300 rounded-md py-2 px-3 focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="fulltime">{t('employees.types.fulltime')}</option>
            <option value="parttime">{t('employees.types.parttime')}</option>
            <option value="seasonal">{t('employees.types.seasonal')}</option>
          </select>
        </div>

        <div className="mb-4">
          <label htmlFor="maxShifts" className="block text-sm font-medium text-gray-700 mb-1">
            {t('employees.maxShiftsPerWeek')}
          </label>
          <input
            id="maxShifts"
            type="number"
            min="1"
            max="7"
            value={maxShiftsPerWeek}
            onChange={(e) => setMaxShiftsPerWeek(Number(e.target.value))}
            className="w-full border border-gray-300 rounded-md py-2 px-3 focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>

        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            {t('employees.skills')}
          </label>
          <div className="flex flex-wrap gap-2">
            {availableSkills.map((skill) => (
              <button
                key={skill}
                type="button"
                onClick={() => toggleSkill(skill)}
                className={`px-3 py-1 rounded-full text-sm ${
                  skills.includes(skill) 
                    ? 'bg-primary-600 text-white' 
                    : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                }`}
              >
                {skill}
              </button>
            ))}
          </div>
        </div>

        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            {t('employees.preferredShifts')}
          </label>
          <div className="flex flex-wrap gap-2">
            {timeSlots.map((shift) => (
              <button
                key={shift}
                type="button"
                onClick={() => togglePreferredShift(shift)}
                className={`px-3 py-1 rounded-full text-sm ${
                  preferredShifts.includes(shift) 
                    ? 'bg-primary-600 text-white' 
                    : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                }`}
              >
                {shift}
              </button>
            ))}
          </div>
        </div>

        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            {t('employees.preferredDaysOff')}
          </label>
          <div className="flex flex-wrap gap-2">
            {days.map((day) => (
              <button
                key={day}
                type="button"
                onClick={() => togglePreferredDayOff(day)}
                className={`px-3 py-1 rounded-full text-sm ${
                  preferredDaysOff.includes(day) 
                    ? 'bg-primary-600 text-white' 
                    : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                }`}
              >
                {day}
              </button>
            ))}
          </div>
        </div>

        <div className="flex justify-end space-x-2">
          <button
            type="button"
            onClick={handleClose}
            className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
          >
            {t('common.cancel')}
          </button>
          <button
            type="submit"
            className="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
          >
            {t('common.create')}
          </button>
        </div>
      </form>
    </Modal>
  );
};

export default CreateEmployeeModal;
