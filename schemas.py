from pydantic import BaseModel


# ====================
# JOB SCHEMAS
# ====================

class JobBase(BaseModel):
    title: str
    department: str
    status: str
    description: str


class JobCreate(JobBase):
    pass


class JobResponse(JobBase):
    id: int

    class Config:
        orm_mode = True


# ====================
# APPLICATION SCHEMAS
# ====================

class ApplicationBase(BaseModel):
    student_name: str
    email: str
    stage: str
    job_id: int


class ApplicationCreate(ApplicationBase):
    pass


class ApplicationResponse(ApplicationBase):
    id: int

    class Config:
        orm_mode = True
