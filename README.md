# FarmShift: Intelligent Workforce Scheduling Platform

## Overview

FarmShift is an advanced workforce scheduling platform designed specifically for agricultural businesses, providing intelligent shift management, employee tracking, and optimization tools.

## 🌟 Key Features

### 🗓️ Smart Scheduling
- Intelligent week-based scheduling
- AI-powered shift suggestions
- Drag-and-drop shift management
- Previous/Next week navigation

### 👥 Employee Management
- Comprehensive employee profiles
- Skills and preferences tracking
- Employment type categorization
- Maximum shifts per week configuration

### 🤖 AI Scheduling Assistant
- Automated shift generation
- Optimization based on employee preferences
- Conflict resolution suggestions

### 🌐 Multilingual Support
- English and Danish languages
- Easy language switching
- Internationalization (i18n) implementation

## 🚀 Tech Stack

### Frontend
- React
- TypeScript
- Redux Toolkit
- Tailwind CSS
- React i18next
- Vite

### State Management
- Redux
- Redux Toolkit
- Async Thunks

### Internationalization
- react-i18next
- Supports multiple languages

## 📦 Prerequisites

- Node.js (v18+)
- pnpm

## 🔧 Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/farmshift.git
cd farmshift
```

2. Install dependencies
```bash
pnpm install
```

3. Start the development server
```bash
pnpm start
```

## 🌈 Environment Setup

Create a `.env` file in the `frontend` directory with the following variables:
```
VITE_API_BASE_URL=http://localhost:3000/api
VITE_ENABLE_AI_SUGGESTIONS=true
```

## 📝 Configuration

### Shift Configuration
- Modify `src/config/shifts.ts` to adjust default shift parameters
- Configure time slots and work hours

### Employee Preferences
- Set maximum shifts per week
- Define preferred shift types
- Add skill-based scheduling rules

## 🧪 Testing

Run tests with:
```bash
pnpm test
```

## 🌍 Deployment

### Frontend
```bash
pnpm build
```

### Recommended Hosting
- Vercel
- Netlify
- AWS Amplify

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📞 Contact

Chris Khong - [Your Email]

Project Link: [https://github.com/yourusername/farmshift](https://github.com/yourusername/farmshift)

---

**Built with ❤️ for Agricultural Workforce Management**
