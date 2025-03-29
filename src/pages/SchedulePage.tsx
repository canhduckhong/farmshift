import React from 'react';
import { useSelector } from 'react-redux';
import { RootState } from '../store';
import WeeklyCalendar from '../components/WeeklyCalendar';
import AssignShiftModal from '../components/AssignShiftModal';
import AIScheduler from '../components/AIScheduler';

const SchedulePage: React.FC = () => {
  const isModalOpen = useSelector((state: RootState) => state.shifts.isModalOpen);

  const showSuggestions = useSelector((state: RootState) => state.shifts.showSuggestions);
  const aiSuggestions = useSelector((state: RootState) => state.shifts.aiSuggestions);

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-800">Weekly Schedule</h1>
        <div className="text-sm text-gray-500">
          {new Date().toLocaleDateString('en-DK', { 
            weekday: 'long', 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric' 
          })}
        </div>
      </div>
      
      <AIScheduler />
      
      {showSuggestions && aiSuggestions && (
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
          <h2 className="text-lg font-semibold text-blue-800 mb-2">AI Suggested Schedule</h2>
          <p className="text-sm text-blue-700 mb-4">
            Review the suggested schedule below. You can apply it or continue with your current schedule.
          </p>
          <WeeklyCalendar useAiSuggestions={true} />
        </div>
      )}
      
      {(!showSuggestions || !aiSuggestions) && <WeeklyCalendar useAiSuggestions={false} />}
      
      {isModalOpen && <AssignShiftModal />}
    </div>
  );
};

export default SchedulePage;
