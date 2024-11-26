from ctypes import *
from dataclasses import dataclass
from typing import List, Optional

# 定義常數
MAX_NAME_LENGTH = 50
SUBJECTS_NUM = 10

# 定義錯誤碼
SUCCESS = 1
ERR_BASE = 0
ERR_OUT_OF_MEM = ERR_BASE - 1
ERR_OPEN_FAIL = ERR_BASE - 2
ERR_LOAD_FAIL = ERR_BASE - 3
ERR_SAVE_FAIL = ERR_BASE - 4
ERR_NOT_FOUND = ERR_BASE - 5

# 定義 Student 結構
class StudentStruct(Structure):
    _fields_ = [
        ("id", c_int),
        ("name", c_char_p),
        ("scores", POINTER(c_int))
    ]

@dataclass
class Student:
    id: int
    name: str
    scores: List[int]

    @classmethod
    # C的struct轉成class
    def from_struct(cls, struct: StudentStruct) -> Optional['Student']:
        if not struct:
            return None
        
        # 正確處理字串
        name = struct.name.decode('utf-8') if struct.name else ""
        
        # 處理分數陣列
        scores = [struct.scores[i] for i in range(SUBJECTS_NUM)]
        
        return cls(
            id=struct.id,
            name=name,
            scores=scores
        )
    # 從class轉成C的struct
    def to_struct(self) -> StudentStruct:
        struct = StudentStruct()
        struct.id = self.id
        
        # 處理字串
        struct.name = c_char_p(self.name.encode('utf-8'))
        
        # 處理分數陣列
        scores_array = (c_int * SUBJECTS_NUM)(*self.scores)
        struct.scores = cast(scores_array, POINTER(c_int))
        return struct

# 加載共享庫
try:
    lib = CDLL("./_example_ctypes.so")
except OSError as e:
    print(f"Error loading library: {e}")
    exit(1)

# 設定函數參數和返回類型
lib.init.restype = c_int
lib.release.restype = None

lib.getById.argtypes = [c_int]
lib.getById.restype = POINTER(StudentStruct)

lib.setById.argtypes = [c_int, POINTER(StudentStruct)]
lib.setById.restype = c_int

lib.getAll.restype = POINTER(POINTER(StudentStruct))

lib.setAll.argtypes = [POINTER(POINTER(StudentStruct))]
lib.setAll.restype = c_int

def init() -> bool:
    return lib.init() == SUCCESS

def release():
    lib.release()

def get_by_id(student_id: int) -> Optional[Student]:
    result = lib.getById(student_id)
    if not result:
        return None
    try:
        return Student.from_struct(result.contents)
    except Exception as e:
        print(f"Error converting struct: {e}")
        return None

def set_by_id(student_id: int, student: Student) -> bool:
    try:
        struct = student.to_struct()
        return lib.setById(student_id, byref(struct)) == SUCCESS
    except Exception as e:
        print(f"Error setting student: {e}")
        return False

def get_all() -> List[Student]:
    result = lib.getAll()
    if not result:
        return []
    
    students = []
    i = 0
    while result[i]:
        try:
            student = Student.from_struct(result[i].contents)
            if student:
                students.append(student)
        except Exception as e:
            print(f"Error converting student {i}: {e}")
        i += 1
    
    return students

def set_all(students: List[Student]) -> bool:
    try:
        # 創建一個 C 的指針陣列
        arr_type = POINTER(StudentStruct) * (len(students) + 1) 
        student_array = arr_type()
        
        # 轉換每個學生並存入陣列
        for i, student in enumerate(students):
            struct = student.to_struct()
            student_array[i] = pointer(struct)
        
        # 設置 NULL 結尾
        student_array[len(students)] = None
        
        # 調用 C 函數
        result = lib.setAll(student_array)
        return result == SUCCESS
    except Exception as e:
        print(f"Error in set_all: {e}")
        import traceback
        traceback.print_exc()
        return False

# 測試用例
if __name__ == "__main__":
    if not init():
        print("init failed")
        exit(1)

    try:
        # 讀取單個學生
        student = get_by_id(2)
        if student:
            print(f"ID: {student.id}")
            print(f"Name: {student.name}")
            print(f"Scores: {student.scores}")
        else:
            print("Not Found\n")

        # 新增/更新學生
        new_student = Student(
            id=5,
            name="Harry",
            scores=[10, 85, 88, 92, 87, 89, 91, 86, 88, 90]
        )

        if set_by_id(5, new_student):
            print("set success\n")
        else:
            print("set failed\n")

        # 讀取所有學生
        all_students = get_all()
        for student in all_students:
            print(f"ID: {student.id}")
            print(f"Name: {student.name}")
            print(f"Scores: {student.scores}")
            print()

        test_students = [
            Student(id=1, name="Alice", scores=[90, 85, 88, 92, 87, 89, 91, 86, 88, 90]),
            Student(id=2, name="Bob", scores=[85, 88, 90, 87, 89, 92, 86, 88, 90, 91]),
            Student(id=3, name="Charlie", scores=[88, 92, 87, 89, 91, 86, 88, 90, 85, 87])
        ]

        if set_all(test_students):
            print("set all success\n")

        # 讀取所有學生
        all_students = get_all()
        for student in all_students:
            print(f"ID: {student.id}")
            print(f"Name: {student.name}")
            print(f"Scores: {student.scores}")
            print()

    except Exception as e:
        print(f"程式執行錯誤: {e}")
    finally:
        print("\nrelease...")
        release()
