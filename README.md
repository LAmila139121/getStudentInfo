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

<br>

## 問題的回覆

### 沒有看到基本型態轉換的定義
swig對於基本型態會自動進行轉換，這部分不需要我們編寫，像基本的資料型態(int, float, char)、字串、基本結構等它可以幫我們做轉換。  <br>  
但這次作業的結構用到動態空間，所以會需要自行定義。

<br>

### `.i`檔上面的`%{ #include "getStudentInfo.h"%}`已經引用一次了，為何下面還需要宣告一次函式
接口檔案 `%{  %}` 區塊中的內容會直接複製到生成的 C wrapper 代碼中，但 SWIG 不會解析這些內容來生成介面。這區塊主要是為了讓 wrapper 代碼能夠訪問到必要的 C header。  <br>  
後面的函數宣告是告訴 SWIG 需要為哪些函數生成 Python 綁定，SWIG 需要知道這些函數的 signature 才能正確生成對應的 Python API。  <br>  
直接在下方 #include 整個 `.h` 其實可能可以編譯，只是如果有部分是SWIG無法直接處理的(像巨集、C++的模板等等)，就可能會有錯誤發生。或是可能有不希望或不需要讓 python 呼叫的函式，我只要在下面進行必要的函式宣告，把想給 python 使用的函式給 SWIG 做處理就好。  

<br>

### SWIG扮演甚麼角色，做了什麼讓Python可以使用C的函式
`swig -python example.i` 編譯會產出 `example.py`、`example_wrap.c`。  <br>  
`example.py` -> 是一個 module，包含 Python API，會去調用 `.so`  
`example_wrap.c` -> 生成的包裝代碼，負責將 Python 調用映射到 C  <br>  
`gcc -fPIC -Wall -I/usr/include/python3.9 -shared example_wrap.c getStudentInfo.o AVLTree.o -o _example.so` 會產生 `.so` 檔，它會基於 `example_wrap.c` 去使用 C 的函數。  <br>  
Python import 產生的.py -> .py調用.so -> .so 介由 wrap.c的轉換去用C的函式  

<br>

### 為何用Py_DECREF()
Python 的 reference count 可以被用於內存與資源的管理，利用此數量來判斷資料有無被使用和是不是需要釋放。 <br>  
而Python 在引用時有分strong reference/weak reference，Python 中引用預設是 strong reference ，它在每次的引用後 reference count會 +1，如果後續引用數變成 0，就會自動進行釋放  
沒有使用到這個資料後，就需要調用 `Py_DECREC()` 管理他的 reference count 直到 0，有點類似於C在資料使用完使用 free 一樣，加上 `Py_DECREF()` 可以避免內存洩漏。

<br>

### 關於.i檔中，有未改到的錯誤，明明未宣告$1，但為何free沒有出現編譯錯誤 
```c
%typemap(in) Student *data {
    // 獲取 name
    PyObject *name_attr = PyObject_GetAttrString($input, "name");

    if (!name_attr) {
        free($1);
        SWIG_exception_fail(SWIG_TypeError, "Without 'name' attribute");
    }
}
```
在 typemap 中，有特別規定的變數，像是 `$input` 是輸入要進行型態轉變的物件， `$result` 是要回傳的值。  
而 `$n` 在函式裡表示映射時的的特定型態。  
```c
%typemap(in)(int argc, char **argv) {
	//....
}
``` 
這邊 `$1` 會等於 `int argc`, `$2` 等於 `char **argv`  <br>  
所以在我的.i檔中，`$1` 會自動 = `Student *data` ，編譯就不會出現問題，不過如果運行時進入判斷式還是會發生錯誤。

<br>

### 網站推薦的作法 
仔細看在昨天提到的網站上，雖然有很多種做法比較，但因為SWIG可以用在多語言的轉換，所以並非只單純 C to Python 的比較，那有列在上方的 C to Python 就只有 Ctypes 和 CFFI  <br>  
裡面 Ctypes 並沒有被打分評價，而 CFFI 和 SWIG 分數高的是 SWIG ，也是最多人去評價的。  
如果是單純瀏覽器查詢這些工具的比較，也會看到大部分比較推薦 SWIG ，雖然處理複雜資料的學習曲線比較陡峭，但大家還是比較推崇這個用法。
