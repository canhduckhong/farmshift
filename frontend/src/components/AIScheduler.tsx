import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { RootState } from '../store';
import { 
  startGeneratingSchedule, 
  setAiSuggestions, 
  toggleValidationRule,
  updateAiConfig,
  applySuggestions,
  discardSuggestions
} from '../store/shiftsSlice';
import { generateScheduleAsync } from '../utils/scheduleGenerator';

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

const AIScheduler: React.FC = () => {
  const { t } = useTranslation();
  const dispatch = useDispatch();
  const { shifts, employees, aiConfig, isGeneratingSchedule, aiSuggestions } = useSelector(
    (state: RootState) => state.shifts
  );
  
  const [showSettings, setShowSettings] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [customShifts, setCustomShifts] = useState<CustomShift[]>([]);
  
  // New shift state
  const [newShift, setNewShift] = useState<CustomShift>({
    id: '',
    startTime: '',
    endTime: '',
    employeeIds: [],
    task: '',
    date: new Date().toISOString().split('T')[0] // Today's date
  });
  
  // Load custom shifts from local storage
  useEffect(() => {
    const savedShifts = localStorage.getItem('farmshift-custom-shifts');
    if (savedShifts) {
      try {
        setCustomShifts(JSON.parse(savedShifts));
      } catch (e) {
        console.error('Error loading custom shifts from localStorage', e);
      }
    }
  }, []);
  
  // Save custom shifts to local storage when they change
  useEffect(() => {
    localStorage.setItem('farmshift-custom-shifts', JSON.stringify(customShifts));
  }, [customShifts]);
  
  const handleOpenModal = () => {
    setNewShift({
      id: '',
      startTime: '',
      endTime: '',
      employeeIds: [],
      task: '',
      date: new Date().toISOString().split('T')[0]
    });
    setShowModal(true);
  };
  
  const handleCloseModal = () => {
    setShowModal(false);
  };
  
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setNewShift(prev => ({
      ...prev,
      [name]: value
    }));
  };
  
  const handleEmployeeSelection = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const selectedOptions = Array.from(e.target.selectedOptions, option => option.value);
    setNewShift(prev => ({
      ...prev,
      employeeIds: selectedOptions
    }));
  };
  
  const handleAddCustomShift = () => {
    if (!newShift.startTime || !newShift.endTime || newShift.employeeIds.length === 0 || !newShift.task) {
      alert(t('aiScheduler.completeAllFields'));
      return;
    }
    
    const shiftToAdd = {
      ...newShift,
      id: `shift-${Date.now()}`
    };
    
    setCustomShifts(prev => [...prev, shiftToAdd]);
    handleCloseModal();
  };
  
  const handleRemoveCustomShift = (id: string) => {
    setCustomShifts(prev => prev.filter(shift => shift.id !== id));
  };
  
  const handleGenerateSchedule = async () => {
    dispatch(startGeneratingSchedule());
    
    try {
      // Convert custom shifts to the format expected by generateScheduleAsync
      const shiftsForScheduling = customShifts.map(shift => ({
        id: shift.id,
        day: new Date(shift.date).toLocaleDateString('en-US', { weekday: 'long' }),
        timeSlot: shift.startTime.split(':')[0] < '12' ? 'Morning' : 
                 shift.startTime.split(':')[0] < '17' ? 'Afternoon' : 'Evening',
        employeeId: shift.employeeIds[0] || null,
        role: null,
        startTime: shift.startTime,
        endTime: shift.endTime,
        task: shift.task
      }));
      
      // Combine with existing shifts if needed
      const allShifts = [...shifts, ...shiftsForScheduling];
      
      const suggestions = await generateScheduleAsync(allShifts, employees.length > 0 ? employees : mockEmployees, aiConfig);
      dispatch(setAiSuggestions(suggestions));
    } catch (error) {
      console.error('Error generating schedule:', error);
    }
  };
  
  const handleToggleValidationRule = (ruleName: string) => {
    dispatch(toggleValidationRule(ruleName));
  };
  
  const handleToggleSettings = () => {
    setShowSettings(!showSettings);
  };
  
  const handleUpdateConfig = (key: keyof typeof aiConfig, value: boolean) => {
    dispatch(updateAiConfig({ [key]: value }));
  };
  
  const handleApplySuggestions = () => {
    dispatch(applySuggestions());
  };
  
  const handleDiscardSuggestions = () => {
    dispatch(discardSuggestions());
  };
  
  return (
    <div className="bg-white rounded-lg shadow p-6 mb-6">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold text-gray-800">{t('aiScheduler.title')}</h2>
        <div className="flex space-x-2">
          <button
            onClick={handleOpenModal}
            className="px-3 py-1 text-sm bg-primary-600 text-white rounded hover:bg-primary-700"
          >
            {t('aiScheduler.addCustomShift')}
          </button>
          <button
            onClick={handleToggleSettings}
            className="px-3 py-1 text-sm text-gray-600 border border-gray-300 rounded hover:bg-gray-50"
          >
            {showSettings ? t('aiScheduler.hideSettings') : t('aiScheduler.showSettings')}
          </button>
        </div>
      </div>
      
      {/* Custom Shifts List */}
      {customShifts.length > 0 && (
        <div className="mb-6">
          <h3 className="text-md font-semibold mb-3">{t('aiScheduler.customShifts')}</h3>
          <div className="bg-gray-50 p-3 rounded-md">
            <div className="space-y-2">
              {customShifts.map(shift => (
                <div key={shift.id} className="flex justify-between items-center p-2 bg-white rounded shadow-sm">
                  <div>
                    <span className="font-medium">{shift.task}</span>
                    <span className="mx-2 text-gray-500">|</span>
                    <span className="text-gray-600">
                      {new Date(shift.date).toLocaleDateString()} {shift.startTime} - {shift.endTime}
                    </span>
                    <span className="ml-2 text-gray-500">
                      {shift.employeeIds.map(id => 
                        mockEmployees.find(emp => emp.id === id)?.name
                      ).join(', ')}
                    </span>
                  </div>
                  <button
                    onClick={() => handleRemoveCustomShift(shift.id)}
                    className="text-sm text-red-500 hover:text-red-700"
                  >
                    {t('common.remove')}
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
      
      {showSettings && (
        <div className="mb-6 bg-gray-50 p-4 rounded-md">
          <h3 className="text-md font-semibold mb-3">{t('aiScheduler.schedulingRules')}</h3>
          
          <div className="mb-4">
            <div className="flex items-center mb-2">
              <input
                type="checkbox"
                id="prioritizeSkillMatch"
                checked={aiConfig.prioritizeSkillMatch}
                onChange={() => handleUpdateConfig('prioritizeSkillMatch', !aiConfig.prioritizeSkillMatch)}
                className="mr-2"
              />
              <label htmlFor="prioritizeSkillMatch" className="text-sm">
                {t('aiScheduler.prioritizeSkillMatch')}
              </label>
            </div>
            
            <div className="flex items-center">
              <input
                type="checkbox"
                id="respectPreferences"
                checked={aiConfig.respectPreferences}
                onChange={() => handleUpdateConfig('respectPreferences', !aiConfig.respectPreferences)}
                className="mr-2"
              />
              <label htmlFor="respectPreferences" className="text-sm">
                {t('aiScheduler.respectPreferences')}
              </label>
            </div>
          </div>
          
          <h4 className="text-sm font-medium mb-2">{t('aiScheduler.validationRules')}</h4>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
            {aiConfig.enabledRules.map(rule => (
              <div key={rule.name} className="flex items-center">
                <input
                  type="checkbox"
                  id={rule.name}
                  checked={rule.enabled}
                  onChange={() => handleToggleValidationRule(rule.name)}
                  className="mr-2"
                />
                <label htmlFor={rule.name} className="text-xs text-gray-700">
                  {rule.description}
                </label>
              </div>
            ))}
          </div>
        </div>
      )}
      
      {aiSuggestions && (
        <div className="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-md">
          <p className="text-sm mb-2">
            <span className="font-medium">{t('aiScheduler.scheduleGenerated')}</span> 
            {' '}{getScheduleStats(aiSuggestions)} {t('aiScheduler.outOf')} {aiSuggestions.length} {t('aiScheduler.shiftsAssigned')}
          </p>
          <div className="flex space-x-2">
            <button
              onClick={handleApplySuggestions}
              className="px-3 py-1 bg-primary-600 text-white text-sm rounded hover:bg-primary-700"
            >
              {t('aiScheduler.applySuggestions')}
            </button>
            <button
              onClick={handleDiscardSuggestions}
              className="px-3 py-1 border border-gray-300 text-gray-700 text-sm rounded hover:bg-gray-50"
            >
              {t('common.discard')}
            </button>
          </div>
        </div>
      )}
      
      <div className="flex justify-center">
        <button
          onClick={handleGenerateSchedule}
          disabled={isGeneratingSchedule}
          className={`px-4 py-2 rounded-md text-white text-sm font-medium ${
            isGeneratingSchedule ? 'bg-gray-400' : 'bg-primary-600 hover:bg-primary-700'
          }`}
        >
          {isGeneratingSchedule ? (
            <div className="flex items-center">
              <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              {t('common.generating')}
            </div>
          ) : (
            t('common.generate')
          )}
        </button>
      </div>
      
      <div className="mt-4 text-xs text-gray-500">
        <p>
          {t('aiScheduler.description')}
        </p>
      </div>
      
      {/* Modal for adding custom shifts */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">{t('aiScheduler.addCustomShift')}</h3>
              <button 
                onClick={handleCloseModal}
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
                <label className="block text-sm font-medium text-gray-700 mb-1">{t('aiScheduler.assignTo')}</label>
                <select
                  multiple
                  name="employeeIds"
                  value={newShift.employeeIds}
                  onChange={handleEmployeeSelection}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                  size={3}
                >
                  {mockEmployees.map(employee => (
                    <option key={employee.id} value={employee.id}>
                      {employee.name} ({employee.skills.join(', ')})
                    </option>
                  ))}
                </select>
                <p className="text-xs text-gray-500 mt-1">{t('aiScheduler.multiSelectHint')}</p>
              </div>
              
              <div className="flex justify-end space-x-3 mt-6">
                <button
                  onClick={handleCloseModal}
                  className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
                >
                  {t('common.cancel')}
                </button>
                <button
                  onClick={handleAddCustomShift}
                  className="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
                >
                  {t('common.add')}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

// Helper function to get statistics about the schedule
const getScheduleStats = (shifts: any[]) => {
  const filledShifts = shifts.filter(shift => shift.employeeId !== null).length;
  return filledShifts;
};

export default AIScheduler;
