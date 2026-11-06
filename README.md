# Neon Rush website: put it online

This folder holds the whole site:
- `index.html`: the website (rules, controls, leaderboard, rewards, FAQ)
- `play.html`: the game (opened by the "Play Now" buttons)
- `supabase-setup.sql`: the leaderboard database setup

## 1. Database (Supabase), once
1. supabase.com → your project (you can reuse the Candle Runner one) → **SQL Editor → New query**
2. Paste everything from `supabase-setup.sql` → **Run**
3. **Project Settings → API** → copy the **Project URL** and the **anon / publishable key**

## 2. Paste your keys in BOTH files
Open `index.html` **and** `play.html` in Notepad, press Ctrl+F, search `PASTE_YOUR`, and replace:
```
const SUPABASE_URL='https://xxxx.supabase.co';
const SUPABASE_KEY='your-anon-key';
```
In `index.html` you can also set:
```
const X_URL='https://x.com/YourHandle';
const TOKEN_URL='https://...your $CANDLE token page...';
```

## 3. Publish (Netlify)
Go to https://app.netlify.com/drop and drag this whole folder onto it.
You get a link like `neonrush.netlify.app`. That's your website, and **Play Now** opens the game.

To update later: edit the files, then drag the folder again (Deploys tab).
