"""TaskFlow Orbit - Multi-user todo app with AI meal planning and deadline command center."""

cl {
    import from frontend { app as ClientApp }

    def:pub app -> any {
        return
            <ClientApp />;
    }
}

import from byllm.lib { Model }
import from uuid { uuid4 }

glob llm = Model(model_name="claude-sonnet-4-5-20250929");
# Compatibility bridge: Jac 0.9.15 runtime does not expose `Root` in
# walker annotation eval, while newer docs/syntax require `Root`.
glob Root = type(root);

# --- AI Types ---

enum Category { WORK, PERSONAL, SHOPPING, HEALTH, OTHER }

enum Unit { PIECE, LB, OZ, CUP, TBSP, TSP, CLOVE, BUNCH }

obj Ingredient {
    has name: str;
    has quantity: float;
    has unit: Unit;
    has cost: float;
    has carby: bool;
}

sem Ingredient.cost = "Estimated cost in USD";
sem Ingredient.carby = "True if this ingredient is high in carbohydrates";

"""Categorize a todo based on its title."""
def categorize(title: str) -> Category by llm();

"""Generate a shopping list of ingredients needed for a described meal."""
def generate_ingredients(meal_description: str) -> list[Ingredient] by llm();

# --- Data Nodes ---

node Todo {
    has id: str,
        title: str,
        completed: bool = False,
        category: str = "other",
        due_date: str = "",
        priority: str = "medium";
}

node MealIngredient {
    has name: str,
        quantity: float,
        unit: str,
        cost: float,
        carby: bool;
}

# --- Todo Walkers ---

walker:priv AddTodo {
    has title: str,
        due_date: str = "",
        priority: str = "medium";

    can create with Root entry {
        category = "other";
        try {
            category = str(categorize(self.title)).split(".")[-1].lower();
        } except Exception {
            category = "other";
        }
        normalized_priority = self.priority.lower();
        if normalized_priority != "high" and normalized_priority != "medium" and normalized_priority != "low" {
            normalized_priority = "medium";
        }
        new_todo = here ++> Todo(
            id=str(uuid4()),
            title=self.title,
            category=category,
            due_date=self.due_date,
            priority=normalized_priority
        );
        report {
            "id": new_todo[0].id,
            "title": new_todo[0].title,
            "completed": new_todo[0].completed,
            "category": new_todo[0].category,
            "due_date": new_todo[0].due_date,
            "priority": new_todo[0].priority
        };
    }
}

walker:priv ListTodos {
    has todos: list = [];

    can collect with Root entry {
        visit [-->];
    }

    can gather with Todo entry {
        self.todos.append({
            "id": here.id,
            "title": here.title,
            "completed": here.completed,
            "category": here.category,
            "due_date": here.due_date,
            "priority": here.priority
        });
    }

    can report_all with Root exit {
        report self.todos;
    }
}

walker:priv ToggleTodo {
    has todo_id: str;

    can search with Root entry {
        visit [-->];
    }

    can toggle with Todo entry {
        if here.id == self.todo_id {
            here.completed = not here.completed;
            report {
                "id": here.id,
                "completed": here.completed
            };
        }
    }
}

walker:priv DeleteTodo {
    has todo_id: str;

    can search with Root entry {
        visit [-->];
    }

    can delete with Todo entry {
        if here.id == self.todo_id {
            del here;
            report {"deleted": self.todo_id};
        }
    }
}

walker:priv UpdateTodoMeta {
    has todo_id: str,
        due_date: str = "",
        priority: str = "medium";

    can search with Root entry {
        visit [-->];
    }

    can update with Todo entry {
        if here.id == self.todo_id {
            normalized_priority = self.priority.lower();
            if normalized_priority != "high" and normalized_priority != "medium" and normalized_priority != "low" {
                normalized_priority = "medium";
            }
            here.due_date = self.due_date;
            here.priority = normalized_priority;
            report {
                "id": here.id,
                "due_date": here.due_date,
                "priority": here.priority
            };
        }
    }
}

walker:priv CompleteOverdueTodos {
    has today: str,
        completed_count: int = 0;

    can scan with Root entry {
        visit [-->];
    }

    can complete with Todo entry {
        if not here.completed and here.due_date and here.due_date < self.today {
            here.completed = True;
            self.completed_count = self.completed_count + 1;
        }
    }

    can report_summary with Root exit {
        report {"completed": self.completed_count};
    }
}

# --- Meal Planner Walkers ---

walker:priv GenerateShoppingList {
    has meal_description: str;

    can generate with Root entry {
        visit [-->];
        ingredients: list = [];
        try {
            ingredients = generate_ingredients(self.meal_description);
        } except Exception {
            ingredients = [];
        }
        result: list = [];
        for ing in ingredients {
            ing_data = {
                "name": ing.name,
                "quantity": ing.quantity,
                "unit": str(ing.unit).split(".")[-1].lower(),
                "cost": ing.cost,
                "carby": ing.carby
            };
            here ++> MealIngredient(
                name=ing_data["name"],
                quantity=ing_data["quantity"],
                unit=ing_data["unit"],
                cost=ing_data["cost"],
                carby=ing_data["carby"]
            );
            result.append(ing_data);
        }
        report result;
    }

    can clear_old with MealIngredient entry {
        del here;
    }
}

walker:priv ListMealPlan {
    has ingredients: list = [];

    can collect with Root entry {
        visit [-->];
    }

    can gather with MealIngredient entry {
        self.ingredients.append({
            "name": here.name,
            "quantity": here.quantity,
            "unit": here.unit,
            "cost": here.cost,
            "carby": here.carby
        });
    }

    can report_all with Root exit {
        report self.ingredients;
    }
}

walker:priv ClearMealPlan {
    can collect with Root entry {
        visit [-->];
    }

    can clear with MealIngredient entry {
        del here;
        report {"cleared": True};
    }
}
