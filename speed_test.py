import time
import statistics
from typing import List, Callable
import gc

def run_benchmark(func: Callable, iterations: int, rounds: int = 5) -> dict:
    """
    執行效能測試並返回統計資料
    """
    times = []
    for _ in range(rounds):
        gc.collect()  # 強制垃圾回收
        start = time.perf_counter()
        for i in range(iterations):
            func(i % 10 + 1)  # 使用1-10的ID循環
        end = time.perf_counter()
        times.append(end - start)
    
    return {
        'mean': statistics.mean(times),
    }

def format_results(name: str, stats: dict) -> str:
    """格式化結果輸出"""
    return f"""
{name}:
    AVG: {stats['mean']:.6f} seconds
"""

def benchmark_both_implementations(iterations: int = 100000):
    # 測試 SWIG
    print("import SWIG module...")
    import_start = time.perf_counter()
    import example as swig_example
    import_end = time.perf_counter()
    swig_import_time = import_end - import_start
    
    print("import CTypes module...")
    import_start = time.perf_counter()
    from ctype_test import get_by_id as ctype_get_by_id, set_by_id as ctype_set_by_id
    from ctype_test import Student as CtypeStudent, init as ctype_init, release as ctype_release
    import_end = time.perf_counter()
    ctype_import_time = import_end - import_start
    
    print("\n")
    print(f"import SWIG: {swig_import_time:.6f} seconds")
    print(f"import CTypes: {ctype_import_time:.6f} seconds")
    
    # 初始化兩個系統
    print("\ninit...")
    swig_example.init()
    ctype_init()
    
    # 準備測試資料
    test_scores = [85, 90, 88, 92, 87, 85, 89, 91, 90, 88]
    
    # getById 測試
    print(f"\nrun getById {iterations} times...")
    swig_get_stats = run_benchmark(swig_example.getById, iterations)
    ctype_get_stats = run_benchmark(ctype_get_by_id, iterations)
    
    # setById 測試
    print(f"\nrun setById {iterations} times...")
    def swig_set_test(i: int):
        student_data = CtypeStudent(
            id=i,
            name=f"Student{i}",
            scores=test_scores
        )
        swig_example.setById(i, student_data)
    
    def ctype_set_test(i: int):
        student = CtypeStudent(
            id=i,
            name=f"Student{i}",
            scores=test_scores
        )
        ctype_set_by_id(i, student)
    
    swig_set_stats = run_benchmark(swig_set_test, iterations)
    ctype_set_stats = run_benchmark(ctype_set_test, iterations)
    
    # 清理
    swig_example.release()
    ctype_release()
    
    # 輸出結果
    print("\n===== speed test =====")
    print("\ngetById:")
    print(format_results("SWIG", swig_get_stats))
    print(format_results("CTypes", ctype_get_stats))
    
    print("\nsetById:")
    print(format_results("SWIG", swig_set_stats))
    print(format_results("CTypes", ctype_set_stats))

if __name__ == "__main__":
    benchmark_both_implementations()
