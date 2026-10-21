from fastapi import HTTPException, status

class BusinessException(HTTPException):
    def __init__(self, detail: str):
        super().__init__(status_code=status.HTTP_400_BAD_REQUEST, detail=detail)

class NotFoundException(HTTPException):
    def __init__(self, resource_name: str, id_or_code: str | int):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=f"{resource_name} với định danh '{id_or_code}' không tồn tại trong hệ thống."
        )

class ConflictException(HTTPException):
    def __init__(self, detail: str):
        super().__init__(status_code=status.HTTP_409_CONFLICT, detail=detail)

class ForbiddenException(HTTPException):
    def __init__(self, detail: str = "Không có quyền thực hiện thao tác này."):
        super().__init__(status_code=status.HTTP_403_FORBIDDEN, detail=detail)

