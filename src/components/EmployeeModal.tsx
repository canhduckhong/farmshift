import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { RootState } from '../store';
import { 
  addEmployee, 
  updateEmployee, 
  closeEmployeeModal,
  availableSkills
} from '../store/shiftsSlice';
import { Employee, EmployeePreferences } from '../store/shiftsSlice';

const EmployeeModal: React.FC = () => {
  const { t } = useTranslation();
  const dispatch = useDispatch();
  const { selectedEmployee } = useSelector((state: RootState) => state.shifts);
  
  const [name, setName] = useState('');
  const [role, setRole] = useState('');
  const [employmentType, setEmploymentType] = useState<'fulltime' | 'intern'>('fulltime');
  const [skills, setSkills] = useState<string[]>([]);
  const [maxShiftsPerWeek, setMaxShiftsPerWeek] = useState(5);
  const [preferredShifts, setPreferredShifts] = useState<string[]>([]);
  const [preferredDaysOff, setPreferredDaysOff] = useState<string[]>([]);
  
  const timeSlots = ['Morning', 'Afternoon', 'Evening'];
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
  // Initialize form with selected employee data or empty for new employee
  useEffect(() => {
    if (selectedEmployee) {
      setName(selectedEmployee.name);
      setRole(selectedEmployee.role);
      setEmploymentType(selectedEmployee.employmentType);
      setSkills(selectedEmployee.skills);
      setMaxShiftsPerWeek(selectedEmployee.maxShiftsPerWeek);
      setPreferredShifts(selectedEmployee.preferences.preferredShifts);
      setPreferredDaysOff(selectedEmployee.preferences.preferredDaysOff);
    } else {
      // Reset form for new employee
      setName('');
      setRole('');
      setEmploymentType('fulltime');
      setSkills([]);
      setMaxShiftsPerWeek(5);
      setPreferredShifts([]);
      setPreferredDaysOff([]);
    }
  }, [selectedEmployee]);
  
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    const preferences: EmployeePreferences = {
      preferredShifts,
      preferredDaysOff
    };
    
    if (selectedEmployee) {
      // Update existing employee
      const updatedEmployee: Employee = {
        id: selectedEmployee.id,
        name,
        role,
        employmentType,
        skills,
        preferences,
        maxShiftsPerWeek
      };
      dispatch(updateEmployee(updatedEmployee));
    } else {
      // Add new employee
      const newEmployee: Omit<Employee, 'id'> = {
        name,
        role,
        employmentType,
        skills,
        preferences,
        maxShiftsPerWeek
      };
      dispatch(addEmployee(newEmployee));
    }
    
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
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-lg p-6 w-full max-w-xl max-h-[90vh] overflow-y-auto">
        <h2 className="text-xl font-bold mb-4">
          {selectedEmployee ? t('employees.editEmployee') : t('employees.addEmployee')}
        </h2>
        
        <form onSubmit={handleSubmit}>
          {/* Name field */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {t('employees.name')}
            </label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full border border-gray-300 rounded-md py-2 px-3 focus:outline-none focus:ring-2 focus:ring-primary-500"
              required
            />
          </div>
          
          {/* Role field */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {t('employees.role')}
            </label>
            <input
              type="text"
              value={role}
              onChange={(e) => setRole(e.target.value)}
              className="w-full border border-gray-300 rounded-md py-2 px-3 focus:outline-none focus:ring-2 focus:ring-primary-500"
              required
            />
          </div>
          
          {/* Employment Type */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {t('employees.employmentType')}
            </label>
            <div className="flex space-x-4">
              <label className="inline-flex items-center">
                <input
                  type="radio"
                  checked={employmentType === 'fulltime'}
                  onChange={() => setEmploymentType('fulltime')}
                  className="h-4 w-4 text-primary-600"
                />
                <span className="ml-2 text-sm">{t('employees.types.fulltime')}</span>
              </label>
              <label className="inline-flex items-center">
                <input
                  type="radio"
                  checked={employmentType === 'intern'}
                  onChange={() => setEmploymentType('intern')}
                  className="h-4 w-4 text-primary-600"
                />
                <span className="ml-2 text-sm">{t('employees.types.intern')}</span>
              </label>
            </div>
          </div>
          
          {/* Max Shifts Per Week */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {t('employees.maxShifts')}
            </label>
            <input
              type="number"
              min="1"
              max="7"
              value={maxShiftsPerWeek}
              onChange={(e) => setMaxShiftsPerWeek(parseInt(e.target.value))}
              className="w-full border border-gray-300 rounded-md py-2 px-3 focus:outline-none focus:ring-2 focus:ring-primary-500"
              required
            />
          </div>
          
          {/* Skills */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {t('employees.skills')}
            </label>
            <div className="grid grid-cols-2 gap-2">
              {availableSkills.map((skill) => (
                <label key={skill} className="inline-flex items-center">
                  <input
                    type="checkbox"
                    checked={skills.includes(skill)}
                    onChange={() => toggleSkill(skill)}
                    className="h-4 w-4 text-primary-600 rounded"
                  />
                  <span className="ml-2 text-sm">{skill}</span>
                </label>
              ))}
            </div>
          </div>
          
          {/* Preferred Shifts */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {t('employees.preferredShifts')}
            </label>
            <div className="flex space-x-2">
              {timeSlots.map((shift) => (
                <label key={shift} className="inline-flex items-center">
                  <input
                    type="checkbox"
                    checked={preferredShifts.includes(shift)}
                    onChange={() => togglePreferredShift(shift)}
                    className="h-4 w-4 text-primary-600 rounded"
                  />
                  <span className="ml-2 text-sm">{t(`timeSlots.${shift.toLowerCase()}`)}</span>
                </label>
              ))}
            </div>
          </div>
          
          {/* Preferred Days Off */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {t('employees.preferredDaysOff')}
            </label>
            <div className="grid grid-cols-4 gap-2">
              {days.map((day) => (
                <label key={day} className="inline-flex items-center">
                  <input
                    type="checkbox"
                    checked={preferredDaysOff.includes(day)}
                    onChange={() => togglePreferredDayOff(day)}
                    className="h-4 w-4 text-primary-600 rounded"
                  />
                  <span className="ml-2 text-sm">{t(`days.${day.toLowerCase()}`)}</span>
                </label>
              ))}
            </div>
          </div>
          
          {/* Action buttons */}
          <div className="flex justify-end space-x-2">
            <button
              type="button"
              onClick={handleClose}
              className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
              {t('common.close')}
            </button>
            <button
              type="submit"
              className="px-4 py-2 bg-primary-600 border border-transparent rounded-md text-sm font-medium text-white hover:bg-primary-700"
            >
              {selectedEmployee ? t('employees.save') : t('employees.add')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default EmployeeModal;
