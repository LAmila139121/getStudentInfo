#include "AVLTree.h"

int height(Node *node) {
    return node ? node->height : 0;
}

int get_balance(Node *node) {
    return node ? height(node->left) - height(node->right) : 0;
}

Node* create_node(Student *data) {
    Node *node = (Node *)malloc(sizeof(Node));
    node->data = data;
    node->height = 1; // 新節點高度初始為 1
    node->left = node->right = NULL;
    return node;
}

Node* right_rotate(Node *y) {
    Node *x = y->left;
    Node *T2 = x->right;

    // 執行旋轉
    x->right = y;
    y->left = T2;

    // 更新高度
    y->height = 1 + (height(y->left) > height(y->right) ? height(y->left) : height(y->right));
    x->height = 1 + (height(x->left) > height(x->right) ? height(x->left) : height(x->right));

    return x; // 返回新的根節點
}

Node* left_rotate(Node *x) {
    Node *y = x->right;
    Node *T2 = y->left;

    // 執行旋轉
    y->left = x;
    x->right = T2;

    // 更新高度
    x->height = 1 + (height(x->left) > height(x->right) ? height(x->left) : height(x->right));
    y->height = 1 + (height(y->left) > height(y->right) ? height(y->left) : height(y->right));

    return y; // 返回新的根節點
}

Node* insert_node(Node *node, Student *new_data, size_t *student_count) {
    // 樹的普通插入
    if (node == NULL) {
        return create_node(new_data);
    }

    if (new_data->id < node->data->id) {
        node->left = insert_node(node->left, new_data, student_count); // 更新左子樹
    } else if (new_data->id > node->data->id) {
        node->right = insert_node(node->right, new_data, student_count); // 更新右子樹
    } else {
        free(node->data); // 如果 ID 已存在，更新數據
        node->data = new_data;
        (*student_count)--;
        return node;
    }

    // 更新高度
    node->height = 1 + (height(node->left) > height(node->right) ? height(node->left) : height(node->right));

    // 平衡調整
    int balance = get_balance(node);

    // LL
    if (balance > 1 && new_data->id < node->left->data->id) {
        return right_rotate(node);
    }

    // RR
    if (balance < -1 && new_data->id > node->right->data->id) {
        return left_rotate(node);
    }

    // LR
    if (balance > 1 && new_data->id > node->left->data->id) {
        node->left = left_rotate(node->left);
        return right_rotate(node);
    }

    // RL
    if (balance < -1 && new_data->id < node->right->data->id) {
        node->right = right_rotate(node->right);
        return left_rotate(node);
    }

    return node;
}

void free_student(Student *student) {
    if (!student) {
        return;
    }
    if (student->name) {
        free(student->name);
        student->name = NULL;
    }
    if (student->scores) {
        free(student->scores);
        student->scores = NULL;
    }
    free(student);
}

void free_tree(Node *node) {
    if (!node) {
        return;
    }
    free_tree(node->left);
    free_tree(node->right);
    
    if (node->data) {
        free_student(node->data);
        node->data = NULL;
    }
    free(node);
}

Node *query_node(Node *node, int id){
    
    if(!node){
        return NULL;
    }
    if(node->data->id == id){
        return node;
    }
    if (node->data->id > id){
        return query_node(node->left, id);
    } else {
        return query_node(node->right, id);
    }
}

void inorder_get(Node *node, Student **students, size_t *index) {
    if (!node || !students || !index) {
        return;
    }
    inorder_get(node->left, students, index);

    Student *new_student = (Student *)malloc(sizeof(Student));
    if (new_student) {
        new_student->id = node->data->id;
        
        new_student->name = (char *)malloc(sizeof(char) * MAX_NAME_LENGTH);
        if (new_student->name) {
            strncpy(new_student->name, node->data->name, MAX_NAME_LENGTH - 1);
            new_student->name[MAX_NAME_LENGTH - 1] = '\0';
        }
        new_student->scores = (int *)malloc(sizeof(int) * SUBJECTS_NUM);
        if (new_student->scores) {
            memcpy(new_student->scores, node->data->scores, sizeof(int) * SUBJECTS_NUM);
        }
        students[*index] = new_student;
        (*index)++;
    }
    inorder_get(node->right, students, index);
}

void inorder_set(Node *node, FILE *fp) {
    if (!node) {
        return;
    }
    inorder_set(node->left, fp);
    Student *new_student = (Student *)malloc(sizeof(Student));
    if (new_student) {
        Student *student = node->data;
        fprintf(fp, "%d %s", student->id, student->name);
        for(int i = 0; i < SUBJECTS_NUM; i++){
            fprintf(fp, " %d", student->scores[i]);
        }
        fprintf(fp, "\n");
    }
    inorder_set(node->right, fp);
}