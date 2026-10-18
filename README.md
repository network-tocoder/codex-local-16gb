# Codex on a 16GB GPU 

Everything behind the NetworkCoder video **"I Ran Codex for FREE on a 16GB GPU"**: the exact setup, the config, the prompts, the test inputs, the raw results and every screenshot. Use it to check the numbers or rerun the tests yourself.

**Stack:** RTX 5060 Ti 16GB · Qwen 3.8 Flash Next 125B (IQ3_S, 3-bit) · Strata v0.1.39 · OpenAI Codex CLI v0.162.1 · 100% offline

▶️ Video: `https://www.youtube.com/watch?v=b2T5ineu7ek`

---

## Results

| Level | Job | Result | Time* |
|---|---|---|---|
| 1 | Python to-do CLI + tests | ✅ 21/21 tests (1.41s) | 10m 15s |
| 2 | Find the bug in an invoice calculator | ✅ 1-line fix, 4/4 tests, tests untouched | 34s |
| 3 | Snake game in one HTML file | ✅ 443 lines, 13/13 headless checks | 3m 50s |
| 4 | Expense tracker (FastAPI + SQLite + vanilla JS) | ✅ 44 tests + 26/26 UI checks, found & fixed a real SQLite threading bug | 21m 51s |

\* Codex's own "Worked for" time. **Level 1's time is inflated**: another job was sharing the engine during that run. Levels 2–4 ran clean.

Level 1 used **145,984 tokens** (140,397 input, 5,587 output). Cost: **$0**.

Full log: [`results/Codex_results_log.md`](results/Codex_results_log.md) · Screenshots: [`screenshots/`](screenshots/)

## Engine speed (Strata, measured on this PC)

| | |
|---|---|
| Auto-tune (CPU workers 47 → 31 → 24, then expert-cache tuning) | 39.0 → 57.8 → 73.5 → **77.7 tok/s** |
| Chat decode | 69.7 tok/s (first token 0.50 s) |
| Prompt reading, 4K / 16K | 1,125 / 1,634 tok/s |
| Agent decode | 74.2 tok/s |
| Agent prompt-cache hit | 68.8% (avg turn first token 3.82 s) |
| Experts in RAM / cached on GPU | 46.8 GiB / ~4,600 experts (8.8 GiB) |

Benchmark run at 64K context; the Codex tests ran at 128K. Screenshots: `24_strata_tuned_77.7toks_all_set.png`, `25_strata_benchmark_results_server_start.png`.

---

## Setup

### 1. Hardware check
```bash
nvidia-smi        # RTX 5060 Ti, 16311 MiB
```

### 2. Strata (v0.1.39 or newer)
v0.1.39 added the OpenAI **Responses** endpoint (`/v1/responses`) that Codex needs. Install Strata, pick **Qwen 3.8 Flash Next (IQ3_S)** in its setup, and let it self-tune. It serves an OpenAI-compatible API at `http://127.0.0.1:8082/v1`.

Strata: `[add link]`

### 3. Install Codex
```bash
npm i -g @openai/codex
codex --version   # codex-cli 0.162.1
```

### 4. Point Codex at Strata — `~/.codex/config.toml`
```toml
model_reasoning_effort = "medium"
model = "strata"
model_provider = "strata"
model_context_window = 131072
show_raw_agent_reasoning = true

[model_providers.strata]
name = "Strata (local)"
base_url = "http://127.0.0.1:8082/v1"
wire_api = "responses"
stream_idle_timeout_ms = 600000
```
- `wire_api = "responses"`: uses Strata's Responses endpoint.
- `stream_idle_timeout_ms = 600000`: gives a local model 10 minutes to think before Codex times out.
- Codex warns that it doesn't know a model called `strata` and uses default metadata. That's harmless.

### 5. Quick test
```bash
mkdir -p ~/codex_test && cd ~/codex_test && git init -q
codex exec "Say hello and list the files in this folder"
# header should show: model: strata / provider: strata
```

### 6. Two snags (and the fixes)
1. **`--full-auto` no longer exists** in v0.162.1:
   ```
   error: unexpected argument '--full-auto' found
   ```
2. **The sandbox failed on the test machine**, even after `apt install -y bubblewrap`:
   ```
   bwrap: No permissions to create new namespace ...
   ```
   Launch used instead (shows as **"YOLO mode"**):
   ```bash
   codex --sandbox danger-full-access --ask-for-approval never
   ```
   > ⚠️ Only do this on a throwaway machine or inside a container. On your own computer, keep the sandbox on.

---

## Rerun the tests

Each level runs in its own empty folder (`~/codex_test/l1_todo`, `l2_invoice`, `l3_snake`, `l4_expenses`).

**Level 1 — to-do CLI**
```
Build a command-line to-do app in Python: todo.py.
Commands: add "<text>", list, done <id>, delete <id>. Save tasks to tasks.json in this folder.
List shows id, [x] or [ ], and the text. Unknown id prints "ERR: no such task".
Write pytest tests in test_todo.py covering every command and the error, run them, and fix until all pass.
```

**Level 2 — find the bug.** Build the buggy project first:
```bash
bash tests/level2_invoice/make_codex_l2.sh
```
```
This is a shop's invoice calculator. Some tests in test_invoice.py are failing. Find the root cause, fix it in invoice.py (do not change the tests), and run the tests unti… [paste full prompt]
```

**Level 3 — Snake**
```
Create snake.html: a complete Snake game in one HTML file (no libraries). Arrow keys to move, food grows the snake, score shown on screen, speed increases every 5 food, ga… [paste full prompt]
```

**Level 4 — expense tracker.** Put [`tests/level4_expenses/bank_statement.csv`](tests/level4_expenses/bank_statement.csv) (22 sample transactions) in the folder.
```
Build a personal expense tracker web app in this folder:
- Python FastAPI backend + SQLite, single-page HTML/JS frontend (no frameworks)
- add / edit / delete expenses (da… [paste full prompt]
```
Expected import (browser check, `screenshots/20_L4_browser_import_CLEAN.mp4`): 22 imported, 0 skipped, 0 invalid. Food 6 · Transport 4 · Bills 3 · Entertainment 3 · Income 2 · Health 2 · Shopping 1 · Rent 1. Re-importing the same file gives 0 imported, 22 duplicates.

---

## Honest limits
- Slower than a cloud model: 22 minutes for the big app.
- One request at a time on one card.
- No web search in this setup.
- One run per test. Your results will vary.

## Screenshots
| File | Shows |
|---|---|
| `00_strata_supported_models.png` | Strata's supported models page |
| `01_nvidia_smi_5060ti_16GB.png` | The GPU |
| `01_codex_install_0.162.1.png` | Codex install + version |
| `02_codex_config_strata.png` | The config file |
| `03_codex_exec_model_strata_first_run.png` | First run: model/provider = strata |
| `04_bubblewrap_reasoning_medium.png` | bubblewrap install + reasoning effort |
| `05_codex_welcome_strata_medium.png` | Codex running on "strata medium" |
| `06`–`09` | Level 1: prompt, sandbox failure, YOLO mode, 21 tests passed |
| `10`–`11` | Level 2: the bug found and fixed in 34s |
| `12`–`14` | Level 3: headless test harness, autoplay bot, 13/13 checks |
| `15`–`18`, `20` | Level 4: build, 44 tests, server, browser, CSV import |
| `24`–`25` | Strata auto-tune (77.7 tok/s) and benchmark |
