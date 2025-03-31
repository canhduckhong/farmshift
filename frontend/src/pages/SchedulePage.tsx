import React, { useState } from 'react';
import { useSelector } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { RootState } from '../store';
import WeeklyCalendar from '../components/WeeklyCalendar';
import AssignShiftModal from '../components/AssignShiftModal';
import AIScheduler from '../components/AIScheduler';

const SchedulePage: React.FC = () => {
  const { t, i18n } = useTranslation();
  const isModalOpen = useSelector((state: RootState) => state.shifts.isModalOpen);

  const showSuggestions = useSelector((state: RootState) => state.shifts.showSuggestions);
  const aiSuggestions = useSelector((state: RootState) => state.shifts.aiSuggestions);

  // State to manage week navigation
  const [weekOffset, setWeekOffset] = useState(0);

  // Function to get the date for the current week
  const getCurrentWeekDate = (offset: number = 0) => {
    const today = new Date();
    const firstDayOfWeek = new Date(today);
    
    // Adjust to the start of the week (Monday)
    const dayOfWeek = today.getDay();
    const diff = today.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1);
    firstDayOfWeek.setDate(diff + (offset * 7));

    return firstDayOfWeek;
  };

  // Format the week range
  const formatWeekRange = (date: Date) => {
    const startOfWeek = new Date(date);
    const endOfWeek = new Date(date);
    endOfWeek.setDate(startOfWeek.getDate() + 6);

    // Calculate week number
    const firstDayOfYear = new Date(startOfWeek.getFullYear(), 0, 1);
    const pastDaysOfYear = (startOfWeek.getTime() - firstDayOfYear.getTime()) / 86400000;
    const weekNumber = Math.ceil((pastDaysOfYear + firstDayOfYear.getDay() + 1) / 7);

    // Use localized date formatting
    const dateOptions: Intl.DateTimeFormatOptions = { 
      month: 'short', 
      day: 'numeric' 
    };

    const startDateString = startOfWeek.toLocaleDateString(i18n.language, dateOptions);
    const endDateString = endOfWeek.toLocaleDateString(i18n.language, {
      ...dateOptions, 
      year: 'numeric'
    });

    return t('common.weekFormat', { 
      week: weekNumber, 
      startDate: startDateString, 
      endDate: endDateString 
    });
  };

  const handlePreviousWeek = () => {
    setWeekOffset(prev => prev - 1);
  };

  const handleNextWeek = () => {
    setWeekOffset(prev => prev + 1);
  };

  const currentWeekDate = getCurrentWeekDate(weekOffset);

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-center space-y-4 sm:space-y-0">
        <h1 className="text-xl sm:text-2xl font-bold text-gray-800 w-full text-center sm:text-left">
          {t('common.weeklySchedule')}
        </h1>
        <div className="flex flex-col sm:flex-row items-center space-y-2 sm:space-y-0 sm:space-x-4 w-full justify-center sm:justify-end">
          <div className="flex items-center space-x-4">
            <button 
              onClick={handlePreviousWeek}
              className="text-gray-600 hover:text-primary-600 transition-colors"
              aria-label="Previous Week"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <div className="text-xs sm:text-sm text-gray-500 text-center sm:text-right">
              {formatWeekRange(currentWeekDate)}
            </div>
            <button 
              onClick={handleNextWeek}
              className="text-gray-600 hover:text-primary-600 transition-colors"
              aria-label="Next Week"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </button>
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
          <WeeklyCalendar useAiSuggestions={true} weekOffset={weekOffset} />
        </div>
      )}
      
      <div className="overflow-x-auto">
        {(!showSuggestions || !aiSuggestions) && <WeeklyCalendar useAiSuggestions={false} weekOffset={weekOffset} />}
      </div>
      
      {isModalOpen && <AssignShiftModal />}
    </div>
  );
};

export default SchedulePage;
