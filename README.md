# FarmShift – Simple Scheduling for Danish Livestock Farms

An MVP for a lightweight employee shift scheduling app for Danish pig and dairy farms.

## Features

- Week View Calendar (Mon–Sun)
- Table/Grid layout with days as columns and time slots as rows
- Click-to-assign shift functionality
- Employee assignment with optional role selection
- Simple shift display showing assigned name and role

## Technology Stack

- React with TypeScript
- State Management: Redux Toolkit
- Styling: TailwindCSS
- Routing: React Router DOM

## Development

### Prerequisites

- Node.js v18 or newer
- pnpm package manager

### Getting Started

1. Install dependencies:

```
pnpm install
```

2. Start the development server:

```
pnpm start
```

3. Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

## Project Structure

- `src/components` - Reusable UI components
- `src/pages` - Page-level components
- `src/store` - Redux state management
- `src/data` - Mock data for the MVP
