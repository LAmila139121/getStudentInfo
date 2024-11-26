# getStudentInfo
<br>

## 檔案說明

### AVLTree.h、AVLTree.c
定義資料結構，有插入、更新、遍歷功能的AVL樹程式碼

<br>

### getStudentInfo.h、getStudentInfo.c
此作業的主要程式碼，共有6個function：
- `int init()`: 在使用以下function前需先呼叫，讀取檔案資料
- `void release()`: 於最後結束程式前需要呼叫，釋放記憶體以及將未更新資料寫入檔案
- `Student* getById(int id)`: 使用ID獲取單一學生資料
- `int setById(int id, Student* data)`: 使用ID設置單一學生資料
- `Student** getAll()`: 獲取全部學生資料
- `int setAll(Student** students)`: 設置全部學生資料(此函式會一併更新檔案)

<br>

### example.i
接口檔案，供後續編譯動態連結庫使用

<br>

### Makefile
使用說明：
- 編譯全部檔案:
```bash
make all
```

- 只編譯SWIG作法所需檔案
```bash
make swig
```

- 只編譯ctypes作法所需檔案
```bash
make ctypes
```
- 刪除編譯的檔案
```bash
make clean
```

<br>

### swig_test.py
使用SWIG所編譯的`.so`編寫成的測試程式

<br>

### ctype_test.py
直接編譯`.so`，並配合Python的module `ctypes`的測試程式

<br>
<br>

## SWIG vs Ctypes (C to Python)

### 性能測試
測試分別呼叫同一個函式(`getById()` and `setById()`) 100000次  
分別測試5次求平均:   
| Function | SWIG | CTypes |
|----------|------|--------|
| `setById()` | 0.149 s | 0.118 s |
| `getById()` | 0.335 s | 0.438 s |
 

<br>

### 記憶體用量

利用此函式獲取內存中實際佔用的空間	 

```python
def get_memory():
    gc.collect()
    return process.memory_info().rss / 1024 / 1024
```  
分別測試5次求平均:  
| SWIG | CTypes |
|------|--------|
| 0.646 MB | 2.198 MB |


<br>

## 性能差異原因
|      | SWIG | CTypes |
|------|------|--------|
|wrap    |在編譯時就建立了 Python 和 C 之間的綁定|在運行時動態載入和綁定函數，需要額外的運行時開銷|
|type轉換|在編譯時就會完成類型轉換的邏輯，通過 typemap 機制優化轉換過程|每次調用都需要在運行時進行類型轉換|
|記憶體管理|提供優化的管理機制，減少記憶體分配和釋放的開銷|需要在每次調用時處理記憶體分配，可能導致更多的記憶體操作|
|優化|可以利用 C/C++ 編譯器的優化功能，生成針對特定平台的高效代碼|因為是動態加載的，無法充分利用編譯器的優化|

<br>

## 兩者操作差異

### SWIG
- 需要寫`.i`檔並進行編譯，會自動產生 wrap 的 code，用`typemap`去進行 C 和 Python 間的型別轉換
- 除了 C 語言外，也支援其他程式語言的轉換
- 可以將 C 的異常和錯誤轉換為相應的 Python 異常

### CTypes
- 是 Python 標準庫的 module，直接 import 就可以用
- 無須編譯，直接可以用`CDLL()`函式後進行調用
- ctypes 有提供基本的類別(ex: `c_int`, `c_char`…)供映射使用，轉換沒有 SWIG 複雜，但複雜的資料結構還是需要另外處理
- 比較仰賴 C 回傳值來檢查錯誤


<br>

## 結論
**SWIG** 適合需要多次呼叫函式的狀況，或用在大型和資料結構複雜的程式專案，由於可以支援多程式語言的轉換，多語言環境也比較適合使用   
**Ctypes** 適合不需要複雜的資料結構，簡單的函數調用的小專案




