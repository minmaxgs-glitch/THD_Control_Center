from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

import models

from database import engine

from routers import jobs
from routers import applications

# Create database tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="THD HR Control Center API"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(jobs.router)
app.include_router(applications.router)


@app.get("/")
def home():
    return {
        "message": "THD HR Control Center Backend Running"
    }
