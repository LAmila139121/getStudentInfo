#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_NAME_LENGTH     50
#define SUBJECTS_NUM        10
#define INIT_CAPACITY       100

typedef struct Student{
    int id;
    char *name;
    int *scores;
} Student;

typedef struct Node {
    Student *data;
    int height; // 節點高度
    struct Node *left, *right;
} Node;

Node* insert_node(Node *node, Student *new_data, size_t *student_count);
Node* query_node(Node *node, int id);
void free_tree(Node *node);
void inorder_get(Node *node, Student **students, size_t *index);
void inorder_set(Node *node, FILE *fp);
//void inorder_print(Node *node);

