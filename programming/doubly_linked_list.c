#include <stdio.h>
#include <stdlib.h>


typedef struct node {
    int data;
    struct node *next;
    struct node *prev;
} Node;

void insert_el(Node **head, Node **tail, int val) {

    Node *new_node = NULL;
    new_node = (Node *)malloc(sizeof(Node));
    new_node->data = val;
    new_node->prev = NULL;

    new_node->next = *head;

    if(!(*head) && !(*tail)) {
        *tail = new_node;
    }

    *head = new_node;

    if(new_node->next) {
        (new_node->next)->prev = new_node;
    }

}

void print_forward(Node *head) {

    if(!head) {
        return;
    }

    Node *temp = head;
    for(   ; temp; printf("%d ", temp->data), temp = temp->next);
    printf("\n");
}

void print_backward(Node *head) {

    if(!head) {
        return;
    }

    Node *temp = head;
    for(   ; temp; printf("%d ", temp->data), temp = temp->prev);
    printf("\n");
}

main() {
    Node *first = NULL, *last = NULL;
    int n = 0, i = 0, data = 0;

    printf("Enter the number of elements to be inserted: ");
    scanf("%d", &n);
    printf("Enter %d elements...", n);

    for(i = 0; i < n; i++) {
        scanf("%d", &data);
        insert_el(&first, &last, data);
    }
    print_forward(first);
    print_backward(last);
}
