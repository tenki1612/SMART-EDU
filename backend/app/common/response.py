from typing import Generic, TypeVar, Optional, List, Any
from pydantic import BaseModel

T = TypeVar("T")

class ApiResponse(BaseModel, Generic[T]):
    success: bool = True
    code: str = "SUCCESS"
    message: str = "Thành công"
    data: Optional[T] = None

class PagedResponse(BaseModel, Generic[T]):
    success: bool = True
    code: str = "SUCCESS"
    message: str = "Thành công"
    data: List[T]
    total: int
    page: int
    page_size: int

