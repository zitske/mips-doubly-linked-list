# InsertNode_asm.s
#
# Grupo: Eduardo Zitske
#
# Assinatura C (DoublyLinkedList.c):
#   void InsertNode_asm(struct DoubledLinkedList *list, struct Node *newNode);
#
# Entrada:
#   $4 ($a0) = list
#   $5 ($a1) = newNode
#
# Offsets das structs (MIPS32):
#   DoubledLinkedList: size=0, head=4, tail=8  (sizeof=12)
#   Node:              student=0, prev=4, next=8 (sizeof=12)
#   Student:           name=0, registration=92, course=96 (sizeof=148)

.text
.globl InsertNode_asm
.ent InsertNode_asm

InsertNode_asm:

    # Obter a matricula do novo estudante (new_reg)
    lw $8, 0($5)               # $8 = newNode->student (offset 0 de Node)
    lw $9, 92($8)              # $9 = new_reg = newNode->student->registration (offset 92)

    # Verificar se a lista esta vazia (list->head == NULL)
    lw $10, 4($4)              # $10 = curr = list->head (offset 4 de DoubledLinkedList)
    beq $10, $0, insert_empty  # Se head == NULL, insere na lista vazia

insert_loop:

    # Se percorreu toda a lista (curr == NULL), insere no final (tail)
    beq $10, $0, insert_tail

    # Obter a matricula do no atual (curr_reg)
    lw $8, 0($10)              # $8 = curr->student
    lw $11, 92($8)             # $11 = curr_reg = curr->student->registration

    # Se new_reg > curr_reg, devemos inserir ANTES de curr (ordem decrescente)
    # (sltu $8, $11, $9 -> $8 = 1 se curr_reg < new_reg)
    sltu $8, $11, $9
    bne $8, $0, insert_before_curr

    # Caso contrario, avanca para o proximo no (curr = curr->next)
    lw $10, 8($10)             # $10 = curr->next (offset 8 de Node)
    j insert_loop

insert_before_curr:

    # Inserir newNode antes de curr:
    # Passo 1: Obter prev_node = curr->prev
    lw $12, 4($10)             # $12 = prev_node = curr->prev (offset 4 de Node)

    # Passo 2: Configurar ponteiros de newNode
    sw $12, 4($5)              # newNode->prev = prev_node
    sw $10, 8($5)              # newNode->next = curr

    # Passo 3: Atualizar curr->prev = newNode
    sw $5, 4($10)              # curr->prev = newNode

    # Passo 4: Atualizar o ponteiro anterior ou head
    beq $12, $0, insert_new_head # Se prev_node == NULL, newNode vira novo head

    # Se prev_node != NULL, prev_node->next = newNode
    sw $5, 8($12)              # prev_node->next = newNode
    j insert_finish

insert_new_head:

    # newNode vira o novo head da lista
    sw $5, 4($4)               # list->head = newNode
    j insert_finish

insert_tail:

    # Inserir newNode apos o tail atual
    lw $13, 8($4)              # $13 = tail = list->tail (offset 8)

    sw $13, 4($5)              # newNode->prev = tail
    sw $0, 8($5)               # newNode->next = NULL
    sw $5, 8($13)              # tail->next = newNode
    sw $5, 8($4)               # list->tail = newNode
    j insert_finish

insert_empty:

    # Lista vazia: newNode vira head e tail
    sw $0, 4($5)               # newNode->prev = NULL
    sw $0, 8($5)               # newNode->next = NULL
    sw $5, 4($4)               # list->head = newNode
    sw $5, 8($4)               # list->tail = newNode

insert_finish:

    # Incrementar list->size (list->size++)
    lw $8, 0($4)               # $8 = list->size (offset 0)
    addi $8, $8, 1             # $8 = list->size + 1
    sw $8, 0($4)               # list->size = $8

    # Retornar da funcao
    jr $31

.end InsertNode_asm
