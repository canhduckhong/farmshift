import React from 'react';
import { useSelector } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { RootState } from '../store';
import WeeklyCalendar from '../components/WeeklyCalendar';
import AssignShiftModal from '../components/AssignShiftModal';
import AIScheduler from '../components/AIScheduler';
import LanguageSelector from '../components/LanguageSelector';

const SchedulePage: React.FC = () => {
  const { t } = useTranslation();
  const isModalOpen = useSelector((state: RootState) => state.shifts.isModalOpen);

  const showSuggestions = useSelector((state: RootState) => state.shifts.showSuggestions);
  const aiSuggestions = useSelector((state: RootState) => state.shifts.aiSuggestions);

  return (
    <div className="space-y-6">
    <a href="https://app.qarmainspect.com/q/app/applink/audits?session_id=81863825-98d7-48b0-8259-97b58ef491ab&amp;checkpoint_id=undefined" 
    className="flex flex-row px-8 py-4 border-default rounded-md cursor-pointer border bg-branding-brand text-white justify-center text-base my-2 shrink-0 mr-4">Open in app<i className="mi self-center flex text-white pl-2">open_in_new</i></a>
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-800">{t('common.weeklySchedule')}</h1>
        <div className="flex items-center space-x-4">
          <LanguageSelector />
          <div className="text-sm text-gray-500">
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
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
          <h2 className="text-lg font-semibold text-blue-800 mb-2">{t('aiScheduler.scheduleGenerated')}</h2>
          <p className="text-sm text-blue-700 mb-4">
            {t('aiScheduler.reviewSuggestions')}
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
