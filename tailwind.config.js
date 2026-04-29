/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        oak:              { DEFAULT: '#3B1F0A', light: '#5C3D1E', dark: '#2A1507' },
        parchment:        { DEFAULT: '#C8A96E', light: '#F5E6C8', dark: '#A07840' },
        ember:            { DEFAULT: '#B5451B', light: '#C8600A', dark: '#8B3214' },
        iron:             { DEFAULT: '#4A4A4A', light: '#6B6B6B', dark: '#2D2D2D' },
        surface:          '#2C1810',
        background:       '#1A0F08',
        divider:          '#3D2B1A',
        'text-primary':   '#F5E6C8',
        'text-secondary': '#A07840',
      },
      fontFamily: {
        display: ['Cinzel', 'serif'],
        body:    ['Lora', 'serif'],
      },
    },
  },
  plugins: [],
}
