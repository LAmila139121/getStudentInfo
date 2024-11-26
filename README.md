# getStudentInfo

此專案有7個檔案：
### AVLTree.h  AVLTree.c
定義資料結構，有插入、更新、遍歷功能的AVL樹程式碼
### getStudentInfo.h  getStudentInfo.c
此作業的主要程式碼，共有6個function：
- init()
  在使用以下function前需先呼叫，讀取檔案資料
- release()
  於最後結束程式前需要呼叫，釋放記憶體以及將未更新資料寫入檔案
- getById(int id)
  
- setById(int id, Student *student)
- getAll()
- setAll(Student **students)
  
