from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# User schemas
class UserBase(BaseModel):
    email: str

class UserCreate(BaseModel):
    email: str
    password: str

class UserResponse(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

# Token schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

# Lecture Session schemas
class LectureSessionBase(BaseModel):
    title: Optional[str] = None

class LectureSessionCreate(LectureSessionBase):
    pass

class LectureSessionResponse(LectureSessionBase):
    id: int
    owner_id: int
    transcript: Optional[str] = None
    audio_duration: Optional[int] = None
    processing_status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Slide schemas
class SlideBase(BaseModel):
    title: str
    content: str

class SlideCreate(SlideBase):
    slide_number: int
    session_id: int

class SlideUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None

class SlideResponse(SlideBase):
    id: int
    session_id: int
    slide_number: int
    confidence_data: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Processing schemas
class ProcessingStartResponse(BaseModel):
    session_id: int
    task_id: str
    status: str
    message: str

class ProcessingStatusResponse(BaseModel):
    status: str
    progress: Optional[int] = None
    error: Optional[str] = None

class SessionWithSlidesResponse(BaseModel):
    session: LectureSessionResponse
    slides: List[SlideResponse]

# Export schemas
class ExportRequest(BaseModel):
    format: str  # "pdf" or "pptx"

class ExportStartResponse(BaseModel):
    export_id: int
    status: str
    message: str

class ExportStatusResponse(BaseModel):
    status: str
    download_url: Optional[str] = None
    error: Optional[str] = None
    expires_at: Optional[datetime] = None