/*
 * test_asm.c - Harness de teste para InsertNode_asm / CloneList_asm.
 *
 * O arquivo DoublyLinkedList.c original NAO e alterado. Ele e incluido
 * abaixo com o main renomeado para dll_original_main, para reaproveitar as
 * structs e as funcoes auxiliares (CreateList, PrintList, etc.).
 *
 * Build (exemplo com cross-compiler):
 *   mips-linux-gnu-gcc -o test_asm test_asm.c InsertNode_asm.s CloneList_asm.s
 *
 * No MipsIt:
 *   - adicione test_asm.c, InsertNode_asm.s e CloneList_asm.s ao build;
 *   - exclua DoublyLinkedList.c do build (ele ja e incluido por este arquivo).
 */

#define main dll_original_main
#include "DoublyLinkedList.c"
#undef main

/* Prototipos das funcoes implementadas em assembly */
int InsertNode_asm(struct DoubledLinkedList *list, struct Node *newNode);
struct DoubledLinkedList *CloneList_asm(struct DoubledLinkedList *list);

static int failures = 0;

static void check(int condition, const char *what) {
    if (condition) {
        printf("[OK]   %s\n", what);
    } else {
        printf("[FAIL] %s\n", what);
        failures++;
    }
}

static struct Node *makeNode(const char *name, unsigned int registration, const char *course) {
    struct Node *node = (struct Node *)malloc(sizeof(struct Node));
    node->student = (struct Student *)malloc(sizeof(struct Student));
    strcpy(node->student->name, name);
    node->student->registration = registration;
    strcpy(node->student->course, course);
    return node;
}

/* Verifica se head/tail, prev/next e size estao coerentes */
static int checkLinks(struct DoubledLinkedList *list) {
    struct Node *aux = list->head;
    struct Node *prev = NULL;
    int count = 0;

    while (aux != NULL) {
        if (aux->prev != prev)
            return 0;
        prev = aux;
        aux = aux->next;
        count++;
    }

    return (prev == list->tail && count == list->size);
}

/* Verifica se a lista esta em ordem decrescente de registration */
static int checkSorted(struct DoubledLinkedList *list) {
    struct Node *aux = list->head;

    while (aux != NULL && aux->next != NULL) {
        if (aux->student->registration < aux->next->student->registration)
            return 0;
        aux = aux->next;
    }

    return 1;
}

/* Verifica se o clone nao compartilha Node nem Student com a origem */
static int checkCloneIsDeep(struct DoubledLinkedList *src, struct DoubledLinkedList *clone) {
    struct Node *a = src->head;
    struct Node *b = clone->head;

    while (a != NULL && b != NULL) {
        if (a == b)
            return 0;
        if (a->student == b->student)
            return 0;
        if (a->student->registration != b->student->registration)
            return 0;
        if (strcmp(a->student->name, b->student->name) != 0)
            return 0;
        if (strcmp(a->student->course, b->student->course) != 0)
            return 0;

        a = a->next;
        b = b->next;
    }

    return (a == NULL && b == NULL);
}

int main(void) {
    struct DoubledLinkedList list;
    struct DoubledLinkedList *cloned;
    struct DoubledLinkedList empty;
    struct DoubledLinkedList *emptyClone;
    struct Node *node;

    CreateList(&list);

    node = makeNode("Ozzy Osbourne", 666, "Heavy Metal");
    check(InsertNode_asm(&list, node) == INSERTION_OK,
          "insercao em lista vazia");

    node = makeNode("Ozzy Osbourne", 666, "Heavy Metal");
    check(InsertNode_asm(&list, node) == STUDENT_ALREADY_INSERTED,
          "rejeita registration duplicado");

    node = makeNode("Scott Ian", 670, "Thrash Metal");
    check(InsertNode_asm(&list, node) == INSERTION_OK,
          "insercao no inicio (novo head)");

    node = makeNode("Vince Neil", 668, "Hard Rock");
    check(InsertNode_asm(&list, node) == INSERTION_OK,
          "insercao no meio");

    node = makeNode("Lemmy Kilmister (R.I.P.)", 660, "Extreme Rock and Roll");
    check(InsertNode_asm(&list, node) == INSERTION_OK,
          "insercao no fim (novo tail)");

    node = makeNode("Robert Johnson (R.I.P.)", 671, "Delta Blues");
    check(InsertNode_asm(&list, node) == INSERTION_OK,
          "insercao no inicio (novo head)");

    node = makeNode("Robert Johnson (R.I.P.)", 671, "Delta Blues");
    check(InsertNode_asm(&list, node) == STUDENT_ALREADY_INSERTED,
          "rejeita duplicado no head");

    check(list.size == 5, "list->size == 5");
    check(list.head != NULL && list.head->student->registration == 671,
          "head tem o maior registration");
    check(list.tail != NULL && list.tail->student->registration == 660,
          "tail tem o menor registration");
    check(checkLinks(&list), "ponteiros prev/next consistentes");
    check(checkSorted(&list), "ordem decrescente");

    printf("\nLista original:\n");
    PrintList(&list);
    printf("\nLista original (inversa):\n");
    PrintListReverse(&list);

    cloned = CloneList_asm(&list);
    check(cloned != NULL, "CloneList_asm retorna lista");
    check(cloned != NULL && cloned->size == list.size, "clone tem o mesmo size");
    check(cloned != NULL && checkLinks(cloned), "clone tem prev/next consistentes");
    check(cloned != NULL && checkSorted(cloned), "clone esta ordenado");
    check(cloned != NULL && checkCloneIsDeep(&list, cloned), "clone e copia profunda");

    printf("\nLista clonada:\n");
    if (cloned != NULL) {
        PrintList(cloned);
        printf("\nLista clonada (inversa):\n");
        PrintListReverse(cloned);
    }

    CreateList(&empty);
    emptyClone = CloneList_asm(&empty);
    check(emptyClone != NULL && emptyClone->size == 0 &&
          emptyClone->head == NULL && emptyClone->tail == NULL,
          "clone de lista vazia");
    check(CloneList_asm(NULL) == NULL, "CloneList_asm(NULL) retorna NULL");

    printf("\n%s (%d falha(s))\n",
           failures == 0 ? "TODOS OS TESTES PASSARAM" : "HOUVE FALHAS",
           failures);

    return failures == 0 ? 0 : 1;
}
