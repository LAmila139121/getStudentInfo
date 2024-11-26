#include "getStudentInfo.h"

Node *root; 
size_t student_count = 0;     
size_t capacity = 0;          

int init() {
    FILE *fp = fopen(DATA, "r");
    if (!fp) {
        printf("open fail\n");
        return ERR_OPEN_FAIL;
    }

    while (!feof(fp)) {
        Student *student = malloc(sizeof(Student));
        if(!student) {
            fclose(fp);
            return ERR_OUT_OF_MEM;
        }
        student->name = malloc(sizeof(char) * MAX_NAME_LENGTH);
        student->scores = malloc(sizeof(int) * SUBJECTS_NUM);
    	if (!student->name || !student->scores) {
        	if (student->name) free(student->name);
        	if (student->scores) free(student->scores);
        	free(student);
			fclose(fp);
        	return ERR_OUT_OF_MEM;
    	}
       
        if (fscanf(fp, "%d %s", &student->id, student->name) != 2) {
            break;
        }
        for (int i = 0; i < SUBJECTS_NUM; i++) {
            if (fscanf(fp, "%d", &student->scores[i]) != 1) {
                break;
            }
        }
        root = insert_node(root, student, &student_count);
        student_count++;
    }
    fclose(fp);
    return SUCCESS;
}

void release() {
    FILE *fp = fopen(DATA, "w");
    if (!fp) {
        return;
    }
    inorder_set(root, fp);
    fclose(fp);
    free_tree(root);
}

Student *getById(int id){
    Node *node = query_node(root, id);
    if(!node)   return NULL;
    
    Student *student = malloc(sizeof(Student));
    if(!student) {
        return NULL;
    }    

    student->name = malloc(sizeof(char) * MAX_NAME_LENGTH);
    student->scores = malloc(sizeof(int) * SUBJECTS_NUM);  
    if (!student->name || !student->scores) {
        if (student->name) free(student->name);
        if (student->scores) free(student->scores);
        free(student);
        return NULL;
    }
    student->id = id;
    strncpy(student->name, node->data->name, MAX_NAME_LENGTH);
    for(int i = 0; i < SUBJECTS_NUM; i++){
        student->scores[i] = node->data->scores[i];
    }
    return student;
}

int setById(int id, Student *student) {
    if (!student) return ERR_LOAD_FAIL;
    
    Student *new_student = malloc(sizeof(Student));
    if(!new_student) {
        return ERR_OUT_OF_MEM;
    }
       
    new_student->id = id;
    new_student->name = strdup(student->name);
    new_student->scores = malloc(sizeof(int) * SUBJECTS_NUM); 
    
    if (!new_student->name || !new_student->scores) {
        if (new_student->name) free(new_student->name);
        if (new_student->scores) free(new_student->scores);
        free(new_student);
        return ERR_OUT_OF_MEM;
    }
    
    memcpy(new_student->scores, student->scores, sizeof(int) * SUBJECTS_NUM);
    root = insert_node(root, new_student, &student_count);
    student_count++;
    return SUCCESS;
}

Student **getAll() {
    if (!root) {
        return NULL;
    }
    Student **all_students = malloc(sizeof(Student *) * (student_count + 1));
    if (!all_students) {
        return NULL;
    }

    size_t index = 0;
    inorder_get(root, all_students, &index);
    all_students[index] = NULL;
    
    return all_students;
}

int setAll(Student **students) {
    if (!students) {
        return ERR_LOAD_FAIL;
    }

    FILE *fp = fopen(DATA, "w");
    if (!fp) {
        return ERR_OPEN_FAIL;
    }

    Node *old_root = root;
    root = NULL;
	size_t new_student_count = 0;

    
    for (int i = 0; students[i] != NULL; i++) {
        fprintf(fp, "%d %s",students[i]->id, students[i]->name);
        for(int j = 0; j < SUBJECTS_NUM; j++)
            fprintf(fp, " %d", students[i]->scores[j]);
        fprintf(fp, "\n");

        Student *new_student = (Student *)malloc(sizeof(Student));
        if (!new_student) {
            free_tree(root);
            root = old_root;
			fclose(fp);
            return ERR_OUT_OF_MEM;
        }
        
        new_student->id = students[i]->id;
        new_student->name = strdup(students[i]->name);
        new_student->scores = (int *)malloc(SUBJECTS_NUM * sizeof(int));     
        if (!new_student->name || !new_student->scores) {
            if (new_student->name) free(new_student->name);
            if (new_student->scores) free(new_student->scores);
            free(new_student);
            root = old_root;
			fclose(fp);            
            return ERR_OUT_OF_MEM;
        }   

        memcpy(new_student->scores, students[i]->scores, SUBJECTS_NUM * sizeof(int));
        root = insert_node(root, new_student, &new_student_count);
        new_student_count++;
    }
    
    if (old_root) {
        free_tree(old_root);
    }
    student_count = new_student_count;
    fclose(fp);
    return SUCCESS;
}
