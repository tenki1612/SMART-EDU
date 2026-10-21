from typing import Tuple

class GradeCalculator:
    @staticmethod
    def calculate_total_and_status(
        attendance: float, 
        midterm: float, 
        final: float
    ) -> Tuple[float, str]:
        """
        FR-74: Tổng hợp kết quả học tập từ điểm số
        Công thức: Chuyên cần 20%, Giữa kỳ 30%, Cuối kỳ 50%
        Điều kiện Đạt (PASSED): Tổng kết >= 5.0 và Điểm cuối kỳ >= 4.0
        """
        total = round(attendance * 0.2 + midterm * 0.3 + final * 0.5, 2)
        status = "PASSED" if (total >= 5.0 and final >= 4.0) else "FAILED"
        return total, status

