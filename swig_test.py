import example
from dataclasses import dataclass
from typing import List

@dataclass
class Student:
    id: int
    name: str
    scores: List[int]

    @classmethod
    def from_dict(cls, data: dict):
        if data is None:
            return None
        return cls(
            id=data['id'],
            name=data['name'],
            scores=data['scores']
        )

# 初始化
if example.init() != 1:
    print("初始化失敗")
    exit(1)

try:
    student_data = example.getById(2)
    if student_data is not None:
        student = Student.from_dict(student_data)
        print(f"找到學生：")
        print(f"ID: {student.id}")
        print(f"Name: {student.name}")
        print(f"Scores: {student.scores}")
    else:
        print("找不到學生")
    
    # 使用 setById
    new_student = Student(
        id=6,
        name="Leo",
        scores=[70, 55, 88, 92, 87, 89, 91, 86, 88, 90]
    )
    status = example.setById(6, new_student)
    if status == 1:
        print("更新成功")
    else:
        print("更新失敗")

    student_data2 = example.getById(4)
    if student_data2 is not None:
        student = Student.from_dict(student_data2)
        print(f"找到學生：")
        print(f"ID: {student.id}")
        print(f"Name: {student.name}")
        print(f"Scores: {student.scores}")
    else:
        print("找不到學生")

#    students_table = [
#        Student(1, "John", [85, 90, 88, 92, 87, 85, 89, 91, 90, 88]),
#        Student(2, "Alice", [90, 92, 88, 85, 87, 89, 91, 86, 88, 90]),
#        Student(3, "Bob", [88, 85, 90, 87, 89, 92, 86, 88, 90, 91])
#    ]
#    status = example.setAll(students_table)
#    if status == 1:
#        print("成功設置所有學生數據")
#    else:
#        print("設置失敗")

    students_data = example.getAll()
    
    # 將字典數據轉換為 Student 物件
    students = [Student.from_dict(data) for data in students_data]
    
    # 顯示數據
    for student in students:
        print(f"ID: {student.id}")
        print(f"Name: {student.name}")
        print(f"Scores: {student.scores}")
        print()
finally:
    example.release()
