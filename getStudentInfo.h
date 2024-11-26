#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "AVLTree.h"

#define ALL                 1
#define SINGLE              0

#define SUCCESS             1
#define ERR_BASE            0
#define ERR_OUT_OF_MEM		ERR_BASE-1
#define ERR_OPEN_FAIL		ERR_BASE-2
#define ERR_LOAD_FAIL		ERR_BASE-3
#define ERR_SAVE_FAIL		ERR_BASE-4
#define ERR_NOT_FOUND       ERR_BASE-5

#define DATA    "data.csv"

// 全域變數：指向平衡樹的根節點
extern Node *root;
extern size_t student_count;  // 當前的學生數量
extern size_t capacity;       // 當前陣列容量

int init();
void release();

Student *getById(int id);
int setById(int id, Student *data);
Student **getAll();
int setAll(Student **students);
