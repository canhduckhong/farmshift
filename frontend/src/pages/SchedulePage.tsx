import React from 'react';
import { useSelector } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { RootState } from '../store';
import WeeklyCalendar from '../components/WeeklyCalendar';
import AssignShiftModal from '../components/AssignShiftModal';
import AIScheduler from '../components/AIScheduler';

const SchedulePage: React.FC = () => {
  const { t } = useTranslation();
  const isModalOpen = useSelector((state: RootState) => state.shifts.isModalOpen);

  const showSuggestions = useSelector((state: RootState) => state.shifts.showSuggestions);
  const aiSuggestions = useSelector((state: RootState) => state.shifts.aiSuggestions);

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-center space-y-4 sm:space-y-0">
        <h1 className="text-xl sm:text-2xl font-bold text-gray-800 w-full text-center sm:text-left">
          {t('common.weeklySchedule')}
        </h1>
        <div className="flex flex-col sm:flex-row items-center space-y-2 sm:space-y-0 sm:space-x-4 w-full justify-center sm:justify-end">
          <div className="text-xs sm:text-sm text-gray-500 text-center sm:text-right">
            {new Date().toLocaleDateString(undefined, { 
              weekday: 'long', 
              year: 'numeric', 
              month: 'long', 
              day: 'numeric' 
            })}
          </div>
        </div>
      </div>
      
      <AIScheduler />
      
      {showSuggestions && aiSuggestions && (
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6 overflow-x-auto">
          <h2 className="text-lg font-semibold text-blue-800 mb-2">{t('aiScheduler.scheduleGenerated')}</h2>
          <p className="text-sm text-blue-700 mb-4">
            {t('aiScheduler.reviewSuggestions')}
          </p>
          <WeeklyCalendar useAiSuggestions={true} />
        </div>
      )}
      
      <div className="overflow-x-auto">
        {(!showSuggestions || !aiSuggestions) && <WeeklyCalendar useAiSuggestions={false} />}
      </div>
      
      {isModalOpen && <AssignShiftModal />}
    </div>
  );
};

export default SchedulePage;
