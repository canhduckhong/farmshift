import React, { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { RootState } from '../store';
import { 
  Select, 
  MenuItem, 
  FormControl, 
  InputLabel, 
  Chip, 
  Box 
} from '@mui/material';

// Mock employee data for prototyping
const mockEmployees = [
  { 
    id: '1', 
    name: 'John Doe', 
    skills: ['Harvesting', 'Planting'],
    role: 'Worker',
    employmentType: 'fulltime' as const,
    preferences: { preferredShifts: ['Morning'], preferredDaysOff: ['Sunday'] },
    maxShiftsPerWeek: 5
  },
  { 
    id: '2', 
    name: 'Jane Smith', 
    skills: ['Maintenance', 'Irrigation'],
    role: 'Manager',
    employmentType: 'fulltime' as const,
    preferences: { preferredShifts: ['Afternoon'], preferredDaysOff: ['Saturday'] },
    maxShiftsPerWeek: 5
  },
  { 
    id: '3', 
    name: 'Mike Johnson', 
    skills: ['Driving', 'Equipment Operation'],
    role: 'Worker',
    employmentType: 'fulltime' as const,
    preferences: { preferredShifts: ['Evening'], preferredDaysOff: ['Monday'] },
    maxShiftsPerWeek: 6
  }
];

// Custom shift interface for local storage
interface CustomShift {
  id: string;
  startTime: string;
  endTime: string;
  employeeIds: string[];
  task: string;
  date: string;
}

interface CustomShiftModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAddShift: (shift: CustomShift) => void;
}

const CustomShiftModal: React.FC<CustomShiftModalProps> = ({ 
  isOpen, 
  onClose, 
  onAddShift 
}) => {
  const { t } = useTranslation();
  const employees = useSelector((state: RootState) => 
    state.shifts.employees.length > 0 ? state.shifts.employees : mockEmployees
  );

  const [newShift, setNewShift] = useState<CustomShift>({
    id: '',
    startTime: '',
    endTime: '',
    employeeIds: [],
    task: '',
    date: new Date().toISOString().split('T')[0] // Today's date
  });

  useEffect(() => {
    // Reset form when modal opens
    if (isOpen) {
      setNewShift({
        id: '',
        startTime: '',
        endTime: '',
        employeeIds: [],
        task: '',
        date: new Date().toISOString().split('T')[0]
      });
    }
  }, [isOpen]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setNewShift(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = () => {
    // Validate input
    if (!newShift.startTime || !newShift.endTime || 
        newShift.employeeIds.length === 0 || !newShift.task) {
      alert(t('aiScheduler.completeAllFields'));
      return;
    }
    
    // Get day name from date
    const dayOfWeek = newShift.date ? 
      new Date(newShift.date).toLocaleDateString('en-US', { weekday: 'long' }) : 
      '';
    
    // Find the appropriate time slot based on start time
    const findMatchingTimeSlot = () => {
      // Get time slots from the store (these are fixed)
      const availableTimeSlots = [
        '04:30-08:30', 
        '08:30-12:30', 
        '10:00-14:00', 
        '14:00-18:00', 
        '18:00-22:00'
      ];
      
      // Convert input time to minutes for comparison
      const inputStartTime = newShift.startTime;
      const [hours, minutes] = inputStartTime.split(':').map(Number);
      const inputTimeInMinutes = hours * 60 + minutes;
      
      // Find closest matching time slot
      let bestMatchTimeSlot = availableTimeSlots[0];
      let smallestDifference = Infinity;
      
      for (const timeSlot of availableTimeSlots) {
        const [start] = timeSlot.split('-');
        const [slotHours, slotMinutes] = start.split(':').map(Number);
        const slotTimeInMinutes = slotHours *.60 + slotMinutes;
        
        const difference = Math.abs(inputTimeInMinutes - slotTimeInMinutes);
        if (difference < smallestDifference) {
          smallestDifference = difference;
          bestMatchTimeSlot = timeSlot;
        }
      }
      
      return bestMatchTimeSlot;
    };
    
    const timeSlot = findMatchingTimeSlot();
    
    const shiftToAdd = {
      ...newShift,
      id: `shift-${Date.now()}`,
      day: dayOfWeek,
      timeSlot: timeSlot
    };
    
    console.log('Adding custom shift with specific time slot:', shiftToAdd);
    onAddShift(shiftToAdd);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-md">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold">{t('aiScheduler.addCustomShift')}</h3>
          <button 
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
        
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">{t('aiScheduler.task')}</label>
            <input
              type="text"
              name="task"
              value={newShift.task}
              onChange={handleInputChange}
              placeholder={t('aiScheduler.enterTask')}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">{t('aiScheduler.date')}</label>
            <input
              type="date"
              name="date"
              value={newShift.date}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>
          
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">{t('aiScheduler.startTime')}</label>
              <input
                type="time"
                name="startTime"
                value={newShift.startTime}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">{t('aiScheduler.endTime')}</label>
              <input
                type="time"
                name="endTime"
                value={newShift.endTime}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
              />
            </div>
          </div>
          
          <div>
            <FormControl fullWidth>
              <InputLabel id="employee-select-label">{t('aiScheduler.assignTo')}</InputLabel>
              <Select
                labelId="employee-select-label"
                id="employee-select"
                multiple
                value={newShift.employeeIds}
                onChange={(e) => {
                  const selectedEmployeeIds = e.target.value as string[];
                  setNewShift(prev => ({
                    ...prev,
                    employeeIds: selectedEmployeeIds
                  }));
                }}
                renderValue={(selected) => (
                  <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                    {(selected as string[]).map((employeeId) => {
                      const employee = employees.find(e => e.id === employeeId);
                      return employee ? (
                        <Chip 
                          key={employeeId} 
                          label={`${employee.name} (${employee.skills.join(', ')})`} 
                        />
                      ) : null;
                    })}
                  </Box>
                )}
                MenuProps={{
                  PaperProps: {
                    style: {
                      maxHeight: 48 * 4.5,
                      width: 250,
                    },
                  },
                }}
              >
                {employees.map(employee => (
                  <MenuItem key={employee.id} value={employee.id}>
                    {employee.name} ({employee.skills.join(', ')})
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
            <p className="text-xs text-gray-500 mt-1">{t('aiScheduler.multiSelectHint')}</p>
          </div>
          
          <div className="flex justify-end space-x-3 mt-6">
            <button
              onClick={onClose}
              className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
            >
              {t('common.cancel')}
            </button>
            <button
              onClick={handleSubmit}
              className="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
            >
              {t('common.add')}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CustomShiftModal;
