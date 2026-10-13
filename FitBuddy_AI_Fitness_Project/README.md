# FitBuddy – AI Fitness Plan Generator using Gemini

Flutter Android/iOS app + Node.js Express API. Gemini API key stays on the server.

## Requirements
- Flutter SDK; Android Studio for Android. iOS builds require macOS + Xcode.
- Node.js LTS from https://nodejs.org/ (if `npm` is not recognized, install Node.js and reopen PowerShell).
- Gemini API key from https://aistudio.google.com/apikey

## Backend
1. Copy `server/.env.example` to `server/.env`; set `GEMINI_API_KEY`.
2. In `server/`, run `npm install`, then `npm run dev`.
3. Check `http://localhost:8080/health`.

## Mobile
1. In `mobile/`, run `flutter create . --platforms=android,ios` then `flutter pub get`.
2. Copy `mobile/.env.example` to `mobile/.env`.
3. Android emulator API URL: `http://10.0.2.2:8080`; iOS simulator: `http://localhost:8080`; physical phone: use your computer LAN IP for local testing.
4. Run `flutter run`.

The app asks for age, goal, experience, training days, session length, equipment, and limitations. It displays the AI-generated weekly schedule, exercises, habits, and safety notes.

## Production checklist
Use HTTPS, restrict CORS, configure authentication and usage limits, and keep secrets in your host's secret manager. Do not commit `.env`. AI plans are general wellness information, not medical advice. Seek qualified professional guidance for injuries, medical conditions, pregnancy, or uncertainty about exercise safety. Check current Gemini model availability before deploying.
