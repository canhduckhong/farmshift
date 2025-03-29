declare module 'i18next' {
  import { i18n } from 'i18next';
  export default i18n;
}

declare module 'react-i18next' {
  import { ReactElement } from 'react';
  
  export interface UseTranslationResponse {
    t: (key: string, options?: any) => string;
    i18n: {
      changeLanguage: (lng: string) => Promise<any>;
      language: string;
    };
    ready: boolean;
  }
  
  export function useTranslation(ns?: string | string[]): UseTranslationResponse;
  export const initReactI18next: any;
  export const Trans: React.ComponentType<any>;
}

declare module 'i18next-browser-languagedetector' {
  import i18next from 'i18next';
  
  export default class LanguageDetector {
    constructor(services?: any, options?: any);
    init(services?: any, options?: any): void;
    detect(): string;
    cacheUserLanguage(lng: string): void;
    type: string;
  }
}

declare module '*.json' {
  const content: Record<string, any>;
  export default content;
}
