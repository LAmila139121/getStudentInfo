%module example
%{
#include "getStudentInfo.h"
%}

%include "typemaps.i"
%include "cstring.i"

/* 定義常數 */
%constant int MAX_NAME_LENGTH = 50;
%constant int SUBJECTS_NUM = 10;

/* 為 setById 的 Student* 參數添加 typemap */
%typemap(in) Student *data {
    // 獲取 name
    PyObject *name_attr = PyObject_GetAttrString($input, "name");
    if (!name_attr) {
        SWIG_exception_fail(SWIG_TypeError, "Without 'name' attribute");
    }
    const char* name = PyUnicode_AsUTF8(name_attr);
    if (!name) {
        Py_DECREF(name_attr);
        SWIG_exception_fail(SWIG_TypeError, "Invalid name string");
    }
    
    // 獲取 scores
    PyObject *scores_attr = PyObject_GetAttrString($input, "scores");
    if (!scores_attr) {
        Py_DECREF(name_attr);
        SWIG_exception_fail(SWIG_TypeError, "Without 'scores' attribute");
    }
    if (!PyList_Check(scores_attr) || PyList_Size(scores_attr) != SUBJECTS_NUM) {
        Py_DECREF(name_attr);
        Py_DECREF(scores_attr);
        SWIG_exception_fail(SWIG_ValueError, "Not a 10 scores list");
    }
    
    // 創建結構體並分配內存
    $1 = (Student *)malloc(sizeof(Student));
    if (!$1) {
        Py_DECREF(name_attr);
        Py_DECREF(scores_attr);
        SWIG_exception_fail(SWIG_MemoryError, "Failed to allocate memory");
    }
    
    // 分配並複製名字
    $1->name = strdup(name);
    $1->scores = (int *)malloc(sizeof(int) * SUBJECTS_NUM);
    if (!$1->name || !$1->scores) {
        if ($1->name) free($1->name);
        if ($1->scores) free($1->scores);
        free($1);
        Py_DECREF(name_attr);
        Py_DECREF(scores_attr);
        SWIG_exception_fail(SWIG_MemoryError, "Failed to allocate memory");
    }
    
    // 複製分數
    for (int i = 0; i < SUBJECTS_NUM; i++) {
        PyObject *score = PyList_GetItem(scores_attr, i);  // Borrowed reference
        if (!score) {
            free($1->name);
            free($1->scores);
            free($1);
            Py_DECREF(name_attr);
            Py_DECREF(scores_attr);
            SWIG_exception_fail(SWIG_TypeError, "Failed to get score");
        }
        
        long value = PyLong_AsLong(score);
        if (value == -1 && PyErr_Occurred()) {
            free($1->name);
            free($1->scores);
            free($1);
            Py_DECREF(name_attr);
            Py_DECREF(scores_attr);
            SWIG_exception_fail(SWIG_TypeError, "Invalid score value");
        }
        $1->scores[i] = (int)value;
    }
    
    // 釋放 Python 對象的引用，只需要一次
    Py_DECREF(name_attr);
    Py_DECREF(scores_attr);
}

%typemap(freearg) Student *data {
    if ($1) {
        free($1->name);
        free($1->scores);
        free($1);
    }
}

%typemap(out) Student * {
    if (!$1) {
        // 如果找不到學生，返回 None
        Py_INCREF(Py_None);
        $result = Py_None;
    } else {
        // 創建字典來存儲學生數據
        PyObject *student_dict = PyDict_New();
        
        PyDict_SetItemString(student_dict, "id", PyLong_FromLong($1->id));
        PyDict_SetItemString(student_dict, "name", PyUnicode_FromString($1->name));
        PyObject *scores_list = PyList_New(SUBJECTS_NUM);
        for (int j = 0; j < SUBJECTS_NUM; j++) {
            PyList_SetItem(scores_list, j, PyLong_FromLong($1->scores[j]));
        }
        PyDict_SetItemString(student_dict, "scores", scores_list);
        
        $result = student_dict;
        
        // 釋放 C 端的記憶體
        free($1->name);
        free($1->scores);
        free($1);
    }
}

%typemap(in) Student **students {
    if (!PyList_Check($input)) {
        SWIG_exception_fail(SWIG_TypeError, "Expected a list of students");
    }
    
    Py_ssize_t size = PyList_Size($input);
    $1 = (Student **)malloc(sizeof(Student *) * (size + 1));  // +1 for NULL terminator
    
    for (Py_ssize_t i = 0; i < size; i++) {
        PyObject *student_obj = PyList_GetItem($input, i);
        
        // 獲取 id
        PyObject *id_attr = PyObject_GetAttrString(student_obj, "id");
        if (!id_attr) {
            free($1);
            SWIG_exception_fail(SWIG_TypeError, "Without 'id' attribute");
        }
        int id = PyLong_AsLong(id_attr);
        Py_DECREF(id_attr);
        
        // 獲取 name
        PyObject *name_attr = PyObject_GetAttrString(student_obj, "name");
        if (!name_attr) {
            free($1);
            SWIG_exception_fail(SWIG_TypeError, "Without 'name' attribute");
        }
        const char* name = PyUnicode_AsUTF8(name_attr);
        Py_DECREF(name_attr);
        
        // 獲取 scores
        PyObject *scores_attr = PyObject_GetAttrString(student_obj, "scores");
        if (!scores_attr || !PyList_Check(scores_attr)) {
            free($1);
            Py_DECREF(scores_attr);            
            SWIG_exception_fail(SWIG_TypeError, "Without 'scores' attribute");
        }
        
        if (!PyList_Check(scores_attr) || PyList_Size(scores_attr) != SUBJECTS_NUM) {
            free($1);
            Py_DECREF(scores_attr);
            SWIG_exception_fail(SWIG_TypeError, "Not a 10 scores list");
        }
        
        // 創建新的 Student 結構體
        Student *student = (Student *)malloc(sizeof(Student));
        if(!student) {
            Py_DECREF(scores_attr);
            SWIG_exception_fail(SWIG_MemoryError, "Failed to allocate memory");
        }        

        student->id = id;
        student->name = strdup(name);
        student->scores = (int *)malloc(sizeof(int) * SUBJECTS_NUM);

        if (!student->name || !student->scores) {
            if(student->name)    free(student->name);
            if(student->scores)  free(student->scores);
            free(student);
            Py_DECREF(scores_attr);
            SWIG_exception_fail(SWIG_MemoryError, "Failed to allocate memory");
        }        
        for (int j = 0; j < SUBJECTS_NUM; j++) {
            PyObject *score = PyList_GetItem(scores_attr, j);
            student->scores[j] = PyLong_AsLong(score);
        }
        
        Py_DECREF(scores_attr);
        $1[i] = student;
    }
    
    $1[size] = NULL;  // NULL terminator
}

%typemap(freearg) Student **students {
    if ($1) {
        for (int i = 0; $1[i]; i++) {
            if ($1[i]->name) free($1[i]->name);
            if ($1[i]->scores) free($1[i]->scores);
            free($1[i]);
        }
        free($1);
    }
}

%typemap(out) Student ** {
    PyObject *list;
    size_t count = 0;
    
    if (!$1) {
        $result = PyList_New(0);  // 返回空列表
    } else {
        // 計算學生數量
        while ($1[count] != NULL) {
            count++;
        }
        
        // 創建 Python 列表
        list = PyList_New(count);
        
        // 轉換每個學生數據
        for (size_t i = 0; i < count; i++) {
            PyObject *student_dict = PyDict_New();
            
            PyDict_SetItemString(student_dict, "id", PyLong_FromLong($1[i]->id));
            PyDict_SetItemString(student_dict, "name", PyUnicode_FromString($1[i]->name));
            PyObject *scores_list = PyList_New(SUBJECTS_NUM);
            for (int j = 0; j < SUBJECTS_NUM; j++) {
                PyList_SetItem(scores_list, j, PyLong_FromLong($1[i]->scores[j]));
            }
            PyDict_SetItemString(student_dict, "scores", scores_list);            
            PyList_SetItem(list, i, student_dict);
        }

        $result = list;    

        // 釋放 C 端的記憶體
        for (size_t i = 0; i < count; i++) {
            free($1[i]->name);
            free($1[i]->scores);
            free($1[i]);
        }
        free($1);
    }
}

/* 宣告函數 */
int init();
void release();
Student *getById(int id);
int setById(int id, Student *data);
int setAll(Student **students);
Student **getAll();
/* 使用不同的參數名稱來區分 setById 的參數處理方式 */
//%rename(setById) wrap_setById;
//int _wrap_setById(int id, char *name_in, int *scores);

