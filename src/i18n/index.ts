import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

// Import language resources
import enTranslation from './locales/en.json';
import daTranslation from './locales/da.json';

// Configure i18next
i18n
  // Detect user language
  .use(LanguageDetector)
  // Pass the i18n instance to react-i18next
  .use(initReactI18next)
  // Initialize i18next
  .init({
    resources: {
      en: {
        translation: enTranslation
      },
      da: {
        translation: daTranslation
      }
    },
    // Prefer Danish, fall back to English
    supportedLngs: ['da', 'en'],
    fallbackLng: 'en',
    debug: process.env.NODE_ENV === 'development',
    
    interpolation: {
      escapeValue: false, // React already escapes values
    },
    
    // Language detector options
    detection: {
      order: ['navigator', 'htmlTag', 'cookie', 'localStorage', 'path', 'subdomain'],
      lookupCookie: 'i18next',
      lookupLocalStorage: 'i18nextLng',
      caches: ['localStorage', 'cookie'],
      cookieExpirationDate: new Date(Date.now() + 1000 * 60 * 60 * 24 * 365), // 1 year
    },
    
    // If the exact match for the user's language is not available, prefer Danish over English
    // for languages that are close to Danish (e.g. Swedish, Norwegian)
    load: 'languageOnly',
    nonExplicitSupportedLngs: true
  });

export default i18n;
