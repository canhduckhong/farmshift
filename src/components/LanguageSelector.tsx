import React from 'react';
import { useTranslation } from 'react-i18next';

const LanguageSelector: React.FC = () => {
  const { i18n } = useTranslation();
  
  const changeLanguage = (lng: string) => {
    i18n.changeLanguage(lng);
  };

  return (
    <div className="flex items-center space-x-2">
      <button
        onClick={() => changeLanguage('en')}
        className={`px-2 py-1 rounded text-xs ${
          i18n.language === 'en' ? 'bg-primary-600 text-white' : 'bg-gray-200 text-gray-700'
        }`}
      >
        English
      </button>
      <button
        onClick={() => changeLanguage('da')}
        className={`px-2 py-1 rounded text-xs ${
          i18n.language === 'da' ? 'bg-primary-600 text-white' : 'bg-gray-200 text-gray-700'
        }`}
      >
        Dansk
      </button>
    </div>
  );
};

export default LanguageSelector;
