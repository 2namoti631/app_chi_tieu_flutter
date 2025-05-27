def individual_data(todo):
    return {
        "id": str(todo["_id"]),
        "title": todo["title"],
        "description": todo["description"],
        "status": todo["is_completed"],
    }

def all_tasks(todos):
    result = []
    for todo in todos:
        formatted = individual_data(todo)
        result.append(formatted)
    return result
