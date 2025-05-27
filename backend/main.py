from datetime import datetime
from fastapi import FastAPI,APIRouter, HTTPException
from configrations import collection 
from database.models import Todo
from database.schemas import all_tasks
from bson.objectid  import ObjectId
app = FastAPI()
router = APIRouter()

@ router.get("/")
async def get_all_todos():
    data = collection.find({"is_deleted": False})
    return  all_tasks(data)

@router .post("/")
async def create_task (new_task: Todo):
    try:
        resp = collection.insert_one(dict(new_task))
        return {'status_code': 200, "id": str(resp.inserted_id) }
    except Exception as e:
        return HTTPException (status_code= 500, detail=f"Some error occured {e}")
    

@router .put("/{task_id}")
async def update_task( task_id:str, updated_task: Todo ):
    try:
        id = ObjectId(task_id)
        exesting_doc = collection.find_one ({"_id":id, "is_deleted":False})
        if not exesting_doc:
            return HTTPException(status_code= 404, detail= f"Task does not exist")
        updated_task.updated_at = datetime.timestamp(datetime.now())
        resp = collection.update_one({"_id":id}, {"$set":dict(updated_task)})
        return {"status code": 200, "message": " update thành công"}
     
    except Exception as e:
        return HTTPException(status_code= 404, detail= f"Task does not exist")
@router.delete("/{task_id}")
async def delete_task( task_id: str):
    try:
        id = ObjectId(task_id)
        exesting_doc = collection.find_one ({"_id":id, "is_deleted":False})
        if not exesting_doc:
            return HTTPException(status_code= 404, detail= f"Task does not exist")

        resp = collection.update_one({"_id":id}, {"$set":{"is_deleted":True}})
        return {"status code": 200, "message": " deleted thành công"}
     
    except Exception as e:
        return HTTPException(status_code= 404, detail= f"Task does not exist")
    
app.include_router(router)
