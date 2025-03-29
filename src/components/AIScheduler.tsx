import React, { useState } from 'react';
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

const AIScheduler: React.FC = () => {
  const { t } = useTranslation();
  const dispatch = useDispatch();
  const { shifts, employees, aiConfig, isGeneratingSchedule, aiSuggestions } = useSelector(
    (state: RootState) => state.shifts
  );
  
  const [showSettings, setShowSettings] = useState(false);
  
  const handleGenerateSchedule = async () => {
    dispatch(startGeneratingSchedule());
    
    try {
      const suggestions = await generateScheduleAsync(shifts, employees, aiConfig);
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
        <button
          onClick={handleToggleSettings}
          className="px-3 py-1 text-sm text-gray-600 border border-gray-300 rounded hover:bg-gray-50"
        >
          {showSettings ? t('aiScheduler.hideSettings') : t('aiScheduler.showSettings')}
        </button>
      </div>
      
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
    </div>
  );
};

// Helper function to get statistics about the schedule
const getScheduleStats = (shifts: any[]) => {
  // We'll use t from the parent component
  const filledShifts = shifts.filter(shift => shift.employeeId !== null).length;
  return filledShifts;
};

// Refactored component to move the translation logic inside the component

export default AIScheduler;
