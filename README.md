# TaskFlow Orbit (EECS 449 Extra Credit 1)

## Student Info
- Name: Junjia Zheng
- UMID: 77453623

## What This Project Includes
This repo implements the full tutorial stack from the Jac **Build Your First App** sequence (Parts 1-3) and adds a custom feature called **Deadline Command Center**.

Base tutorial functionality included:
- Multi-user todo app with auth (`jacSignup`, `jacLogin`, `jacLogout`)
- Graph-persistent todos
- AI todo categorization via byLLM
- AI meal planning that generates structured shopping lists

Custom feature added:
- Due dates + priority levels on todos
- Urgency scoring per task (visual urgency bar)
- Advanced filtering (status, priority, category, search)
- Priority/urgency sorting modes
- Inline edit flow for deadline + priority
- Bulk action: **Rescue Overdue** (marks overdue tasks complete)
- Dashboard metrics (active, overdue, due today, high priority)

## Why This Feature Is Non-Trivial
The feature spans server graph logic + frontend state orchestration + UI design:
- Server data model updates in `main.jac` (`Todo.due_date`, `Todo.priority`)
- New walkers in `main.jac`:
  - `UpdateTodoMeta`
  - `CompleteOverdueTodos`
- Client logic updates in `frontend.cl.jac` and `frontend.impl.jac`:
  - status derivation
  - urgency scoring
  - filtering/sorting pipeline
  - inline edit handlers
- New reusable UI behavior in `components/TodoItem.cl.jac`

## Project Structure
- `/Users/junjia_zheng/Desktop/EECS 449/EC1/main.jac`: server nodes, AI functions, walkers
- `/Users/junjia_zheng/Desktop/EECS 449/EC1/frontend.cl.jac`: client app state + render tree
- `/Users/junjia_zheng/Desktop/EECS 449/EC1/frontend.impl.jac`: client method implementations
- `/Users/junjia_zheng/Desktop/EECS 449/EC1/components/AuthForm.cl.jac`: login/signup component
- `/Users/junjia_zheng/Desktop/EECS 449/EC1/components/TodoItem.cl.jac`: task card with schedule editing + urgency display
- `/Users/junjia_zheng/Desktop/EECS 449/EC1/components/IngredientItem.cl.jac`: meal ingredient item UI
- `/Users/junjia_zheng/Desktop/EECS 449/EC1/styles.css`: complete visual system and responsive styling
- `/Users/junjia_zheng/Desktop/EECS 449/EC1/docs/CODEBASE_GUIDE.md`: detailed deep-dive guide

## Setup and Run
1. Create and activate a local virtual environment:
```bash
python3 -m venv .venv
source .venv/bin/activate
```

2. Install Jac dependencies (recommended for this project on Jac 0.10.0):
```bash
python -m pip install --upgrade pip
python -m pip install "jaclang==0.10.0" jac-client byllm watchdog
```

Official quick-guide default (meta package):
```bash
pip install jaseci
```
Minimal language-only alternative:
```bash
pip install jaclang
```

3. Verify you are running the expected Jac version:
```bash
jac --version
```

4. Export an LLM API key (Anthropic used in this code):
```bash
export ANTHROPIC_API_KEY="your-key"
```

5. From repo root, start the app:
```bash
jac start main.jac
```

6. Open:
- [http://localhost:8000](http://localhost:8000)

If port `8000` is busy:
```bash
jac start main.jac --port 3000
```

Compatibility note:
- This codebase has been updated to use `Root entry/exit` walker signatures (latest breaking-change guidance), while keeping lowercase `root` instance operations (`root spawn`, `root ++>`) unchanged.

## How To Use
1. Sign up or log in.
2. Add todo tasks with optional due date + priority.
3. Use filter and sort controls to manage workload.
4. Use **Rescue Overdue** to bulk complete overdue tasks.
5. Use AI meal planner to generate shopping lists.
