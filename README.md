# Partnership Desk

A single-page tracker for brand partnerships. It shows a summary strip, a "Needs attention" queue (overdue follow-ups, due this week, missing next steps), and the full pipeline as a table or a board.

It's one file, `index.html`, written in plain HTML, CSS and JavaScript. There's no build step, no framework and nothing to install.

## Run it

Pick one:

- **Quickest:** double-click `index.html` to open it in a browser.
- **Local server (recommended):** serve the folder so the browser treats it as a normal website:

  ```bash
  python3 -m http.server 8000
  ```

  Then open <http://localhost:8000>.
- **Hosting:** any static host works (GitHub Pages, Netlify, Vercel, Cloudflare Pages). Point it at the repository root. `index.html` is the entry point.

## How data is saved

The app has two storage modes and picks one on its own:

| Where it runs | Where data lives | Shared? |
|---|---|---|
| As a claude.ai Artifact | The Artifact's shared database (`window.claude.use("db")`) | Yes, with everyone who can open the Artifact |
| Anywhere else (file, localhost, static host) | This browser's `localStorage`, key `pd.partnerships.v1` | No, only this browser on this device |

In standalone mode, a yellow banner at the top reminds you that data stays local.

## Limitations

- **Standalone data is per-browser.** Nothing syncs across devices, browsers or people. Clearing site data, using a private window, or switching browsers means you start with an empty tracker. Each origin keeps its own storage, so `file://`, `localhost:8000` and a hosted URL each have separate data.
- **No backup or export yet.** If the data matters, don't rely on `localStorage` alone. Add an export/import feature or a real backend before you depend on it.
- **No accounts or permissions in standalone mode.** Anyone using the browser can edit everything.
- **Fonts load from Google Fonts.** When you're offline, the app falls back to system fonts and still works.
- **"Today" is set when the page loads.** If you leave a tab open past midnight, reload it to refresh the due dates.
- Follow-ups fall due 4 working days (Mon–Fri) after the last contact unless you set a date. Public holidays aren't counted.
