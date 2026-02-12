# Codebase Familiarization Guide

This document is a practical walkthrough for understanding this repository quickly and deeply.

## 1. Fast Orientation (10 Minutes)
Open these files in this order:
1. `/Users/junjia_zheng/Desktop/EECS 449/EC1/README.md`
2. `/Users/junjia_zheng/Desktop/EECS 449/EC1/main.jac`
3. `/Users/junjia_zheng/Desktop/EECS 449/EC1/frontend.cl.jac`
4. `/Users/junjia_zheng/Desktop/EECS 449/EC1/frontend.impl.jac`
5. `/Users/junjia_zheng/Desktop/EECS 449/EC1/components/TodoItem.cl.jac`
6. `/Users/junjia_zheng/Desktop/EECS 449/EC1/styles.css`

Goal of this pass:
- See what is server-side vs client-side
- See where data is stored
- See where UI actions map to walkers

## 2. Mental Model of the Architecture
The app has three layers:

1. Graph + AI server layer (`main.jac`)
- Defines persistent nodes (`Todo`, `MealIngredient`)
- Defines AI-powered functions (`categorize`, `generate_ingredients`)
- Defines walkers used as authenticated API operations

2. Client app declaration layer (`frontend.cl.jac`)
- Declares state
- Declares methods
- Renders the full UI tree
- Imports server walkers via `sv import`

3. Client method implementation layer (`frontend.impl.jac`)
- Implements business logic for every declared method
- Spawns walkers (`root spawn ...`)
- Handles local state updates, filtering, sorting, and urgency calculations

Component layer:
- `components/AuthForm.cl.jac` for login/signup
- `components/TodoItem.cl.jac` for each task row + inline edit
- `components/IngredientItem.cl.jac` for meal planner results

Visual layer:
- `styles.css` contains all layout/typography/color/motion behavior

## 3. Server Deep Dive (`main.jac`)
Read in this sequence:

1. Entry point
- `cl { ... def:pub app ... }` mounts the client app.

2. AI contract types
- `Category`, `Unit`, `Ingredient`, `sem` declarations define structured AI I/O.

3. Persistent graph nodes
- `Todo` contains all task fields including custom feature fields:
  - `due_date`
  - `priority`
- `MealIngredient` stores generated meal planner output.

4. Todo walkers
- `AddTodo`: creates categorized todo with deadline+priority
- `ListTodos`: accumulator pattern to collect all todos
- `ToggleTodo`, `DeleteTodo`: mutate/remove one todo
- `UpdateTodoMeta` (custom): inline update for due date + priority
- `CompleteOverdueTodos` (custom): bulk action using date comparison

5. Meal planner walkers
- `GenerateShoppingList`
- `ListMealPlan`
- `ClearMealPlan`

Key concept:
- `walker:priv` guarantees authenticated, per-user root isolation.

## 4. Frontend Deep Dive

### 4.1 `frontend.cl.jac`
Focus on three sections:

1. Imports
- Runtime auth helpers from `@jac/runtime`
- `sv import` walker contracts from `main`

2. State
- Auth state (`isLoggedIn`, `username`, `password`)
- Todo CRUD state (`todos`, `newTodoText`, etc.)
- Custom feature state:
  - creation controls: `newDueDate`, `newPriority`
  - filter controls: `filterText`, `filterStatus`, `filterPriority`, `filterCategory`
  - view controls: `sortMode`
  - inline edit state: `editingTodoId`, `editDueDate`, `editPriority`

3. Render logic
- Auth gate (login form vs app)
- Dashboard metrics cards
- Add-task panel
- Filter/sort panel
- Todo list panel (uses `TodoItem`)
- Meal planner panel

### 4.2 `frontend.impl.jac`
This file is the behavior engine.

Read method groups in this order:

1. Data sync methods
- `fetchTodos`, `fetchMealPlan`

2. Todo mutations
- `addTodo`, `toggleTodo`, `deleteTodo`
- `startEdit`, `cancelEdit`, `saveEdit`
- `completeOverdue`

3. Auth flow
- `handleLogin`, `handleSignup`, `handleLogout`, `handleSubmit`

4. Derived intelligence
- `getStatusLabel`
- `getUrgencyScore`
- `getDashboard`
- `getDisplayTodos`

Important implementation pattern:
- Spawn walker, then update local UI state immediately (or refresh list) for responsive UX.

## 5. End-to-End Request Traces

### Trace A: Add Task
1. User fills title/date/priority in UI.
2. `addTodo()` spawns `AddTodo` walker.
3. `AddTodo` calls `categorize()` AI function.
4. New `Todo` node is persisted to user root.
5. UI appends returned todo to `todos` state.

### Trace B: Rescue Overdue
1. User clicks `Rescue Overdue`.
2. `completeOverdue()` computes today date and spawns `CompleteOverdueTodos(today=...)`.
3. Walker traverses user todos and completes overdue ones.
4. Client refetches todos with `fetchTodos()`.

### Trace C: Inline Schedule Edit
1. User clicks `Edit` on a todo row.
2. `startEdit(todo)` hydrates edit state.
3. User changes due date/priority and clicks `Save`.
4. `saveEdit(todoId)` spawns `UpdateTodoMeta`.
5. Updated data merges back into local `todos` state.

## 6. Styling System (`styles.css`)
Read top-to-bottom once.

The file is organized as:
1. Tokens (`:root`) for color/system constants
2. Global background + glow effects
3. Layout (`app-content`, grid systems)
4. Generic controls (inputs, buttons)
5. Todo-specific styles (badges, status, urgency meter)
6. Meal planner styles
7. Auth styles
8. Media queries for responsive behavior

Tips:
- If you need a UI tweak, first look for an existing class token instead of adding a new one.
- Most visual hierarchy comes from typography + border opacity, not large shadows.

## 7. Practical Review Checklist
Use this checklist while running the app:

1. Auth isolation
- Create two users.
- Verify each user sees only their own todos/meal plan.

2. Deadline Command Center behavior
- Add tasks with mixed priorities and due dates.
- Verify dashboard counters update correctly.
- Verify filters and sort modes produce expected ordering.
- Verify `Rescue Overdue` only affects overdue incomplete tasks.

3. Inline edit
- Edit due date/priority for existing task.
- Refresh page and verify persistence.

4. Meal planner persistence
- Generate ingredients, refresh, ensure data remains.

## 8. How To Extend the Project Safely
If you want to add another feature, follow this workflow:

1. Add node fields / walkers in `main.jac` first.
2. Expose walkers via `sv import` in `frontend.cl.jac`.
3. Add method declarations in `frontend.cl.jac`.
4. Implement methods in `frontend.impl.jac`.
5. Update components only after data flow works.
6. Finish with CSS polish and responsive checks.

## 9. Suggested Study Path (90 Minutes)
1. 15 min: Read `main.jac` walker-by-walker.
2. 20 min: Read `frontend.impl.jac` method-by-method.
3. 20 min: Run app and trace each UI action to server walker.
4. 15 min: Inspect `TodoItem` component to understand edit and urgency UI.
5. 20 min: Modify one style token and one filter rule to verify mastery.

By the end, you should be able to answer:
- Which walker runs for each button?
- Where each piece of state lives and why?
- How client derived logic (urgency/filtering) differs from persisted graph data?
