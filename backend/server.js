// Minimal AI proxy for CodeMentor AI. Node 18+, zero dependencies.
//   ANTHROPIC_API_KEY=sk-ant-... node server.js
// The key stays on the server; the app only talks to the three endpoints below.
import http from 'node:http';

const PORT = process.env.PORT || 8787;
const API_KEY = process.env.ANTHROPIC_API_KEY;
const MODEL = process.env.ANTHROPIC_MODEL || 'claude-sonnet-5-5';
const ORIGIN = process.env.ALLOWED_ORIGIN || '*';

if (!API_KEY) {
  console.error('Set ANTHROPIC_API_KEY before starting the server.');
  process.exit(1);
}

const TOPICS = ['Java', 'Python', 'Flutter', 'Swift', 'Android'];
const LEVELS = ['Beginner', 'Intermediate', 'Advanced'];
const LANGS = ['English', 'Hindi'];

// ---- tiny in-memory rate limit: 40 requests / 10 min / IP --------------------
const hits = new Map();
function limited(ip) {
  const now = Date.now();
  const recent = (hits.get(ip) || []).filter((t) => now - t < 600_000);
  recent.push(now);
  hits.set(ip, recent);
  return recent.length > 40;
}

async function claude({ system, messages, maxTokens = 900 }) {
  const r = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-api-key': API_KEY,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({ model: MODEL, max_tokens: maxTokens, system, messages }),
  });
  if (!r.ok) throw new Error(`Anthropic API ${r.status}`);
  const j = await r.json();
  return j.content.filter((b) => b.type === 'text').map((b) => b.text).join('');
}

function pick(value, allowed, fallback) {
  return allowed.includes(value) ? value : fallback;
}
const clip = (s, n) => String(s ?? '').slice(0, n);

const routes = {
  async '/api/questions'(b) {
    const topic = pick(b.topic, TOPICS, 'Java');
    const level = pick(b.level, LEVELS, 'Beginner');
    const language = pick(b.language, LANGS, 'English');
    const count = Math.min(10, Math.max(1, Number(b.count) || 5));
    const text = await claude({
      system: 'You are a senior technical interviewer. Reply with JSON only, no markdown.',
      messages: [{
        role: 'user',
        content: `Write ${count} ${level}-level interview questions about ${topic}. Write in ${language}. ` +
          'Return exactly {"questions":[{"question":"...","answer":"..."}]} where each answer is a concise model answer of 2-4 sentences.',
      }],
      maxTokens: 1800,
    });
    const json = JSON.parse(text.slice(text.indexOf('{'), text.lastIndexOf('}') + 1));
    return { questions: json.questions.slice(0, count) };
  },

  async '/api/interview'(b) {
    const topic = pick(b.topic, TOPICS, 'Java');
    const level = pick(b.level, LEVELS, 'Beginner');
    const language = pick(b.language, LANGS, 'English');
    const history = (Array.isArray(b.history) ? b.history : []).slice(-20).map((m) => ({
      role: m.role === 'assistant' ? 'assistant' : 'user',
      content: clip(m.content, 2000),
    }));
    const userTurns = history.filter((m) => m.role === 'user').length;
    const done = Boolean(b.end) || userTurns >= 5;
    const messages = [{ role: 'user', content: 'Please start the interview.' }, ...history];
    if (done) {
      messages.push({
        role: 'user',
        content: '[The interview is over. Briefly comment on my last answer if I gave one, then give a final evaluation: strengths, areas to improve, and an overall score out of 10.]',
      });
    }
    const text = await claude({
      system: `You are a friendly but rigorous technical interviewer for ${topic} at ${level} level. ` +
        `Respond in ${language}. Ask exactly 5 questions in total, one at a time. After each answer give 1-2 sentences ` +
        'of feedback, then ask the next question. Keep every message under 120 words.',
      messages,
      maxTokens: 500,
    });
    return { text, done };
  },

  async '/api/review'(b) {
    const topic = pick(b.topic, TOPICS, 'Java');
    const language = pick(b.language, LANGS, 'English');
    const text = await claude({
      system: `You are a patient ${topic} tutor. Review the student's answer. Explain what is right or wrong and give a nudge ` +
        `without simply stating the full solution. Respond in ${language}, under 120 words.`,
      messages: [{ role: 'user', content: `Task:\n${clip(b.task, 1500)}\n\nStudent answer:\n${clip(b.code, 3000)}` }],
      maxTokens: 400,
    });
    return { text };
  },
};

http
  .createServer(async (req, res) => {
    res.setHeader('Access-Control-Allow-Origin', ORIGIN);
    res.setHeader('Access-Control-Allow-Headers', 'content-type');
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    if (req.method === 'OPTIONS') return res.writeHead(204).end();

    const handler = req.method === 'POST' ? routes[req.url] : undefined;
    if (!handler) return res.writeHead(404).end('{"error":"not found"}');
    if (limited(req.socket.remoteAddress)) return res.writeHead(429).end('{"error":"rate limited"}');

    try {
      let raw = '';
      for await (const chunk of req) {
        raw += chunk;
        if (raw.length > 20_000) return res.writeHead(413).end('{"error":"too large"}');
      }
      const out = await handler(JSON.parse(raw || '{}'));
      res.writeHead(200).end(JSON.stringify(out));
    } catch (e) {
      console.error(e);
      res.writeHead(502).end('{"error":"upstream failure"}');
    }
  })
  .listen(PORT, () => console.log(`CodeMentor AI backend on :${PORT} (model ${MODEL})`));
