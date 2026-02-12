"""Todo item component with urgency and inline scheduling edits."""

def:pub TodoItem(
    todo: dict,
    statusLabel: str,
    urgencyScore: float,
    editing: bool,
    editDueDate: str,
    editPriority: str,
    onToggle: any,
    onDelete: any,
    onStartEdit: any,
    onSaveEdit: any,
    onCancelEdit: any,
    onEditDueDateChange: any,
    onEditPriorityChange: any
) -> any {
    priority = todo.priority if todo.priority else "medium";
    priorityClass = "priority-pill priority-medium";
    if priority == "high" {
        priorityClass = "priority-pill priority-high";
    }
    if priority == "low" {
        priorityClass = "priority-pill priority-low";
    }

    statusClass = "status-pill status-upcoming";
    if statusLabel == "Completed" {
        statusClass = "status-pill status-completed";
    }
    if statusLabel == "Overdue" {
        statusClass = "status-pill status-overdue";
    }
    if statusLabel == "Due Today" {
        statusClass = "status-pill status-today";
    }
    if statusLabel == "No Deadline" {
        statusClass = "status-pill status-none";
    }

    return
        <div className={"todo-item " + ("todo-completed" if todo.completed else "") }>
            <div className="todo-main-row">
                <input
                    type="checkbox"
                    checked={todo.completed}
                    onChange={lambda -> None { onToggle(todo.id); }}
                    className="todo-checkbox"
                />
                <div className="todo-text-wrap">
                    <p className={("todo-title-completed" if todo.completed else "todo-title")}>
                        {todo.title}
                    </p>
                    <div className="todo-tags">
                        <span className={priorityClass}>{priority}</span>
                        {(
                            <span className="category-badge">{todo.category}</span>
                        ) if todo.category and todo.category != "other" else None}
                    </div>
                </div>
                <div className="todo-actions">
                    <button
                        onClick={lambda -> None { onStartEdit(todo); }}
                        className="mini-btn"
                    >
                        Edit
                    </button>
                    <button
                        onClick={lambda -> None { onDelete(todo.id); }}
                        className="todo-delete-btn"
                    >
                        Delete
                    </button>
                </div>
            </div>

            {(
                <div className="todo-edit-row">
                    <input
                        type="date"
                        value={editDueDate}
                        onChange={onEditDueDateChange}
                        className="todo-input small-input"
                    />
                    <select
                        value={editPriority}
                        onChange={onEditPriorityChange}
                        className="todo-input small-input"
                    >
                        <option value="high">High</option>
                        <option value="medium">Medium</option>
                        <option value="low">Low</option>
                    </select>
                    <button
                        onClick={lambda -> None { onSaveEdit(todo.id); }}
                        className="mini-btn mini-btn-primary"
                    >
                        Save
                    </button>
                    <button
                        onClick={onCancelEdit}
                        className="mini-btn"
                    >
                        Cancel
                    </button>
                </div>
            ) if editing else (
                <div className="todo-meta-row">
                    <span className="due-text">
                        {("Due: " + todo.due_date if todo.due_date else "Due: none")}
                    </span>
                    <span className={statusClass}>{statusLabel}</span>
                </div>
            )}

            <div className="urgency-track">
                <div className="urgency-fill" style={{"width": (urgencyScore.toFixed(0) + "%")}}></div>
            </div>
        </div>;
}
