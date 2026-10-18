# Codex + Strata (local 125B) results
## L1 todo CLI — PASS: 21 tests passed (1.41s), worked 10m 15s, $0
- tests drive real CLI via subprocess; --file/TODO_JSON isolation; fixed its own run() helper bug during run
- note: codex sandbox (bwrap) unavailable on test box -> ran danger-full-access ("YOLO mode")
## L2 invoice bug — PASS: found items[1:] skipping first item, 1-line fix, 4/4 tests, tests untouched, 34s, $0
## L3 snake.html — PASS: 443 lines, 13/13 headless checks (wall/self death, growth, speed-up at 5/10, hiscore persist, pause, restart), 3m 50s, $0
- extras: WASD, P pause, 180-degree reversal guard, food spawns only on free cells, "You win"
## L4 expense tracker (FastAPI+SQLite+vanilla SPA) — PASS: 44 pytest passed, 21m 51s, $0
- all 22 sample rows categorised correctly; idempotent re-import (UNIQUE dedup_key); tolerant amount/date parsing
- caught a REAL bug: SQLite thread affinity broke requests under uvicorn threadpool -> check_same_thread=False + busy_timeout, added regression test
- headless UI drive (jsdom) 26/26 checks; canvas bar chart with tooltips
- L1 session token usage: total 145,984 (input 140,397, output 5,587, reasoning 1,116)
- Browser check (clip 20): imported 22, 0 skipped, 0 invalid; categories Food 6, Transport 4, Bills 3, Entertainment 3, Income 2, Health 2, Shopping 1, Rent 1; INR currency; chart NOT yet recorded
