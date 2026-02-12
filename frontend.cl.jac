"""TaskFlow Orbit - Client UI."""

import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

import "./styles.css";

import from .components.TodoItem { TodoItem }
import from .components.AuthForm { AuthForm }
import from .components.IngredientItem { IngredientItem }

sv import from main {
    AddTodo, ListTodos, ToggleTodo, DeleteTodo,
    UpdateTodoMeta, CompleteOverdueTodos,
    GenerateShoppingList, ListMealPlan, ClearMealPlan
}

def:pub app -> any {
    has isLoggedIn: bool = False,
        checkingAuth: bool = True,
        isSignup: bool = False,
        username: str = "",
        password: str = "",
        error: str = "",
        loading: bool = False,
        todos: list = [],
        newTodoText: str = "",
        newDueDate: str = "",
        newPriority: str = "medium",
        filterText: str = "",
        filterStatus: str = "all",
        filterPriority: str = "all",
        filterCategory: str = "all",
        sortMode: str = "urgency",
        editingTodoId: str = "",
        editDueDate: str = "",
        editPriority: str = "medium",
        todosLoading: bool = True,
        mealInput: str = "",
        ingredients: list = [],
        ingredientsLoading: bool = False;

    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
    }

    can with [isLoggedIn] entry {
        if isLoggedIn {
            fetchTodos();
            fetchMealPlan();
        }
    }

    async def fetchTodos -> None;
    async def addTodo -> None;
    async def toggleTodo(todoId: str) -> None;
    async def deleteTodo(todoId: str) -> None;
    async def saveEdit(todoId: str) -> None;
    def startEdit(todo: dict) -> None;
    def cancelEdit -> None;
    async def completeOverdue -> None;

    async def handleLogin -> None;
    async def handleSignup -> None;
    def handleLogout -> None;
    async def handleSubmit(e: any) -> None;
    def handleTodoKeyPress(e: any) -> None;

    async def fetchMealPlan -> None;
    async def generateIngredients -> None;
    async def clearIngredients -> None;
    def handleMealKeyPress(e: any) -> None;
    def getIngredientsTotal -> float;

    def getTodayDate -> str;
    def getStatusLabel(todo: dict) -> str;
    def getUrgencyScore(todo: dict) -> float;
    def getDashboard -> dict;
    def getDisplayTodos -> list;

    if checkingAuth {
        return
            <div className="loading-shell">
                <div className="loading-orb"></div>
                <p>Connecting to TaskFlow Orbit...</p>
            </div>;
    }

    if isLoggedIn {
        dashboard = getDashboard();
        displayTodos = getDisplayTodos();
        totalCost = getIngredientsTotal();

        return
            <div className="app-container">
                <div className="bg-glow bg-glow-one"></div>
                <div className="bg-glow bg-glow-two"></div>
                <div className="app-content">
                    <div className="card hero-card">
                        <div className="card-header">
                            <div>
                                <p className="eyebrow">Deadline Command Center</p>
                                <h1 className="app-title">TaskFlow Orbit</h1>
                                <p className="app-subtitle">
                                    AI-categorized tasks, urgency intelligence, and meal planning.
                                </p>
                            </div>
                            <button onClick={handleLogout} className="btn-signout">
                                Sign Out
                            </button>
                        </div>
                    </div>

                    <div className="stats-grid">
                        <div className="stat-card">
                            <p className="stat-label">Total Tasks</p>
                            <p className="stat-value">{dashboard.total}</p>
                        </div>
                        <div className="stat-card">
                            <p className="stat-label">Active</p>
                            <p className="stat-value">{dashboard.active}</p>
                        </div>
                        <div className="stat-card alert-card">
                            <p className="stat-label">Overdue</p>
                            <p className="stat-value">{dashboard.overdue}</p>
                        </div>
                        <div className="stat-card">
                            <p className="stat-label">Due Today</p>
                            <p className="stat-value">{dashboard.due_today}</p>
                        </div>
                        <div className="stat-card">
                            <p className="stat-label">High Priority</p>
                            <p className="stat-value">{dashboard.high_priority}</p>
                        </div>
                    </div>

                    <div className="two-column-layout">
                        <div className="column-left">
                            <div className="card">
                                <h2 className="section-title">Add Task</h2>
                                {(
                                    <div className="auth-error">{error}</div>
                                ) if error else None}
                                <div className="add-grid">
                                    <input
                                        type="text"
                                        value={newTodoText}
                                        onChange={lambda e: any -> None { newTodoText = e.target.value; }}
                                        onKeyPress={handleTodoKeyPress}
                                        placeholder="What needs to happen?"
                                        className="todo-input"
                                    />
                                    <input
                                        type="date"
                                        value={newDueDate}
                                        onChange={lambda e: any -> None { newDueDate = e.target.value; }}
                                        className="todo-input"
                                    />
                                    <select
                                        value={newPriority}
                                        onChange={lambda e: any -> None { newPriority = e.target.value; }}
                                        className="todo-input"
                                    >
                                        <option value="high">High Priority</option>
                                        <option value="medium">Medium Priority</option>
                                        <option value="low">Low Priority</option>
                                    </select>
                                    <button
                                        onClick={lambda -> None { addTodo(); }}
                                        className="btn-add"
                                    >
                                        Add Task
                                    </button>
                                </div>
                                <div className="action-row">
                                    <button
                                        onClick={lambda -> None { completeOverdue(); }}
                                        disabled={dashboard.overdue == 0}
                                        className="btn-secondary"
                                    >
                                        Rescue Overdue ({dashboard.overdue})
                                    </button>
                                </div>
                            </div>

                            <div className="card">
                                <h2 className="section-title">Filter + Sort</h2>
                                <div className="filter-grid">
                                    <input
                                        type="text"
                                        value={filterText}
                                        onChange={lambda e: any -> None { filterText = e.target.value; }}
                                        placeholder="Search tasks"
                                        className="todo-input"
                                    />
                                    <select
                                        value={filterStatus}
                                        onChange={lambda e: any -> None { filterStatus = e.target.value; }}
                                        className="todo-input"
                                    >
                                        <option value="all">All Statuses</option>
                                        <option value="active">Active</option>
                                        <option value="completed">Completed</option>
                                        <option value="overdue">Overdue</option>
                                        <option value="today">Due Today</option>
                                    </select>
                                    <select
                                        value={filterPriority}
                                        onChange={lambda e: any -> None { filterPriority = e.target.value; }}
                                        className="todo-input"
                                    >
                                        <option value="all">All Priorities</option>
                                        <option value="high">High</option>
                                        <option value="medium">Medium</option>
                                        <option value="low">Low</option>
                                    </select>
                                    <select
                                        value={filterCategory}
                                        onChange={lambda e: any -> None { filterCategory = e.target.value; }}
                                        className="todo-input"
                                    >
                                        <option value="all">All Categories</option>
                                        <option value="work">Work</option>
                                        <option value="personal">Personal</option>
                                        <option value="shopping">Shopping</option>
                                        <option value="health">Health</option>
                                        <option value="other">Other</option>
                                    </select>
                                    <select
                                        value={sortMode}
                                        onChange={lambda e: any -> None { sortMode = e.target.value; }}
                                        className="todo-input"
                                    >
                                        <option value="urgency">Sort by Urgency</option>
                                        <option value="priority">Sort by Priority</option>
                                    </select>
                                </div>
                                <p className="tiny-meta">
                                    Showing {displayTodos.length} of {todos.length} tasks
                                </p>
                            </div>

                            <div className="card">
                                <h2 className="section-title">Tasks</h2>
                                {(
                                    <div className="loading-message">Loading tasks...</div>
                                ) if todosLoading else (
                                    <div>
                                        {(
                                            <div className="empty-message">
                                                No tasks yet. Add one above.
                                            </div>
                                        ) if displayTodos.length == 0 else (
                                            <div>
                                                {[
                                                    <TodoItem
                                                        key={todo.id}
                                                        todo={todo}
                                                        statusLabel={getStatusLabel(todo)}
                                                        urgencyScore={getUrgencyScore(todo)}
                                                        editing={editingTodoId == todo.id}
                                                        editDueDate={editDueDate}
                                                        editPriority={editPriority}
                                                        onToggle={toggleTodo}
                                                        onDelete={deleteTodo}
                                                        onStartEdit={startEdit}
                                                        onSaveEdit={saveEdit}
                                                        onCancelEdit={cancelEdit}
                                                        onEditDueDateChange={lambda e: any -> None { editDueDate = e.target.value; }}
                                                        onEditPriorityChange={lambda e: any -> None { editPriority = e.target.value; }}
                                                    /> for todo in displayTodos
                                                ]}
                                            </div>
                                        )}
                                    </div>
                                )}
                            </div>

                            <div className="remaining-count">
                                {todos.filter(
                                    lambda t: any -> bool { return not t.completed; }
                                ).length} tasks still in flight
                            </div>
                        </div>

                        <div className="column-right">
                            <div className="card">
                                <h2 className="section-title">AI Meal Planner</h2>
                                <p className="panel-subtitle">
                                    Describe your meal and get a structured shopping list.
                                </p>
                                <div className="add-row">
                                    <input
                                        type="text"
                                        value={mealInput}
                                        onChange={lambda e: any -> None { mealInput = e.target.value; }}
                                        onKeyPress={handleMealKeyPress}
                                        placeholder="e.g. vegetable curry for 5"
                                        className="todo-input"
                                    />
                                    <button
                                        onClick={lambda -> None { generateIngredients(); }}
                                        disabled={ingredientsLoading}
                                        className="btn-generate"
                                    >
                                        {("Generating..." if ingredientsLoading else "Generate")}
                                    </button>
                                </div>
                            </div>

                            <div className="card">
                                {(
                                    <div className="loading-message">
                                        <div className="generating-spinner"></div>
                                        Synthesizing your shopping list...
                                    </div>
                                ) if ingredientsLoading else (
                                    <div>
                                        {(
                                            <div className="empty-message">
                                                Your generated ingredients appear here.
                                            </div>
                                        ) if ingredients.length == 0 else (
                                            <div>
                                                {[
                                                    <IngredientItem
                                                        key={ing.name}
                                                        ingredient={ing}
                                                    /> for ing in ingredients
                                                ]}
                                                <div className="ingredients-footer">
                                                    <div className="ingredients-total">
                                                        Total: ${totalCost.toFixed(2)}
                                                    </div>
                                                    <button
                                                        onClick={lambda -> None { clearIngredients(); }}
                                                        className="btn-clear"
                                                    >
                                                        Clear
                                                    </button>
                                                </div>
                                            </div>
                                        )}
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>
                </div>
            </div>;
    }

    return
        <AuthForm
            isSignup={isSignup}
            username={username}
            password={password}
            error={error}
            loading={loading}
            onUsernameChange={lambda e: any -> None { username = e.target.value; }}
            onPasswordChange={lambda e: any -> None { password = e.target.value; }}
            onSubmit={handleSubmit}
            onToggleMode={lambda -> None { isSignup = not isSignup; error = ""; }}
        />;
}
