import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import { GoogleGenAI } from '@google/genai';
import { z } from 'zod';

const app = express();
const port = Number(process.env.PORT || 8080);
const ai = process.env.GEMINI_API_KEY ? new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY }) : null;
const model = process.env.GEMINI_MODEL || 'gemini-2.5-flash';

app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json({ limit: '30kb' }));
app.use('/api/', rateLimit({ windowMs: 60_000, limit: 20, standardHeaders: true, legacyHeaders: false }));

const schema = z.object({
  age: z.number().int().min(13).max(100),
  goal: z.enum(['Lose fat', 'Build muscle', 'Improve endurance', 'General fitness', 'Improve flexibility']),
  experience: z.enum(['Beginner', 'Intermediate', 'Advanced']),
  daysPerWeek: z.number().int().min(1).max(7),
  minutesPerSession: z.number().int().min(10).max(180),
  equipment: z.string().trim().min(1).max(300),
  limitations: z.string().trim().max(500).default('None')
});

app.get('/health', (_req, res) => res.json({ ok: true, service: 'FitBuddy API' }));

app.post('/api/fitness-plan', async (req, res) => {
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: 'Please check the form fields and try again.' });
  if (!ai) return res.status(503).json({ error: 'Set GEMINI_API_KEY in server/.env and restart the server.' });
  const p = parsed.data;
  const prompt = `You are FitBuddy, a careful general-fitness planning assistant. Return ONLY valid JSON with this structure:
{"title":"short title","summary":"2-3 sentences","weeklySchedule":[{"day":"Day 1","focus":"focus","workout":[{"exercise":"name","sets":"3","reps":"8-12 reps","rest":"60 seconds","notes":"short form cue"}]}],"habits":["habit"],"safetyNotes":["note"]}
Profile: age ${p.age}; goal ${p.goal}; experience ${p.experience}; ${p.daysPerWeek} training days/week; ${p.minutesPerSession} minutes/session; equipment ${p.equipment}; limitations ${p.limitations || 'None'}.
Schedule exactly ${p.daysPerWeek} training days. Keep sessions within about ${p.minutesPerSession} minutes including warm-up/cool-down. Adapt to equipment and experience. Include recovery, safe form cues, and conservative alternatives for limitations. Do not diagnose, prescribe treatment, recommend extreme dieting, or promise results.`;
  try {
    const result = await ai.models.generateContent({
      model, contents: prompt,
      config: { responseMimeType: 'application/json', temperature: 0.4 }
    });
    const raw = result.text || '';
    const start = raw.indexOf('{'), end = raw.lastIndexOf('}');
    if (start < 0 || end < start) throw new Error('Unexpected Gemini response');
    return res.json({ plan: JSON.parse(raw.slice(start, end + 1)), model });
  } catch (err) {
    console.error('Gemini request failed:', err?.message || err);
    return res.status(502).json({ error: 'Plan generation failed. Check the Gemini API key, model availability, and network.' });
  }
});
app.listen(port, () => console.log(`FitBuddy API listening on http://localhost:${port}`));
