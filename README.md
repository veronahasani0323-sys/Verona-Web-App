# Partnership Desk

A single-page tracker for brand partnerships. It shows a summary strip, a "Needs attention" queue (overdue follow-ups, due this week, missing next steps), and the full pipeline as a table or a board.

It's written in plain HTML, CSS and JavaScript (`index.html`). There's no framework and no npm install.

## Files

| File | What it is |
|---|---|
| `index.html` | The whole app |
| `config.js` | Supabase settings. Left empty, the app runs in standalone mode |
| `scripts/build.mjs` | Vercel build step: copies the app to `dist/` and writes `config.js` from env vars (Node built-ins only) |
| `vercel.json` | Vercel settings: build command, output folder, security headers |
| `supabase/schema.sql` | Database table and row level security policies |
| `manifest.webmanifest`, `icons/` | Lets phones install the app on the home screen with its own icon |

## How data is saved

The app picks a storage mode on its own, in this order:

| Mode | When | Where data lives | Who sees it |
|---|---|---|---|
| claude.ai Artifact | Opened as an Artifact | The Artifact's shared database | Everyone with access to the Artifact |
| **Hosted (Supabase)** | `config.js` has a Supabase URL and key | Supabase Postgres, table `partnerships` | Only you, after you sign in with an email link. Syncs live across devices |
| Standalone | Anything else | This browser's `localStorage` | This browser only (a banner says so) |

## Deploy: Supabase + Vercel

### 1. Supabase (database and sign-in)

1. Create a project at [supabase.com](https://supabase.com). The free tier is enough. Pick an EU region if your partners are EU-based (GDPR).
2. **SQL Editor →** paste and run `supabase/schema.sql`.
3. **Project Settings → API keys:** copy the **Project URL** and the **publishable key** (`sb_publishable_…`; the legacy `anon` key also works). **Never** use the secret/`service_role` key: the build refuses it.

### 2. Vercel (hosting)

1. **Add New → Project →** import this GitHub repo. Leave Framework Preset as **Other**. `vercel.json` sets the build.
2. **Environment Variables:** add `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`, then deploy.
3. Copy your production URL, e.g. `https://partnership-desk.vercel.app`.

### 3. Connect them (needed for sign-in links)

In Supabase → **Authentication → URL Configuration**:
- **Site URL:** your Vercel production URL
- **Redirect URLs:** add the same URL. Also add `https://*-<your-vercel-team>.vercel.app/**` if you want sign-in on preview deployments.

Then open the site, enter your email, and click the link.

### 4. Lock it down (recommended)

Once your own account exists, go to **Authentication → Sign In / Providers** and turn off **Allow new users to sign up**. Row level security already keeps strangers away from your data. Turning sign-ups off also stops them from creating accounts on your project.

> Supabase's built-in email sender is rate-limited (a few emails per hour) and meant for testing. For daily use, set up custom SMTP (for example Resend or Postmark) under **Authentication → Emails → SMTP Settings**.

## Install on your phone

- **iPhone (Safari):** open the site → Share → **Add to Home Screen**.
- **Android (Chrome):** open the site → ⋮ menu → **Install app** (or **Add to Home screen**).

The installed app opens full screen with its own icon. It keeps its own sign-in separate from the browser, so sign in once inside it. Use the **6-digit code** from the email, because email links open in the browser instead of the installed app.

For the email to contain a code, the Supabase **Magic Link** template (Authentication → Emails) must include `{{ .Token }}`.

## Run locally

```bash
python3 -m http.server 8000
```

Open http://localhost:8000. That runs standalone mode. To test against Supabase locally:

```bash
SUPABASE_URL=https://xxxx.supabase.co SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxx node scripts/build.mjs
cd dist && python3 -m http.server 8000
```

Then add `http://localhost:8000` to the Supabase redirect URLs.

## Limitations

- **One owner per record.** Each partnership belongs to the account that created it. To share a desk with a manager or teammate, you'd need a team or workspace table and updated policies.
- **Free Supabase projects pause after a week of inactivity.** Unpause from the dashboard, or upgrade if you rely on it daily.
- **Standalone mode** (no Supabase) is per-browser and has no backup. Clearing site data erases it.
- **No export/import yet.** Supabase keeps daily backups on paid plans. On free, you can export the table as CSV from the Table Editor.
- **Records are stored as JSON** (`data` column), which mirrors the app's fields. That's flexible, but for reporting in SQL you'd query `data->>'brand'` and so on.
- Fonts and the Supabase client load from CDNs (Google Fonts, jsDelivr). Offline, fonts fall back to system fonts, but hosted mode needs a connection anyway.
- "Today" is set at page load. Reload a tab that's been open past midnight. Follow-ups skip weekends but not public holidays.
