# CloneList_asm.s
#
# Grupo: Eduardo Zitske
#
# Entrada : $4  (list / src_list)
# Saida   : $2  (clonedList)
#
# Stack frame de 48 bytes (padrao GCC MIPS O32):
#   $29+ 0..15 : area reservada para argumentos de malloc/strcpy
#   $29+20     : $21 ($s5 = aux->student)
#   $29+24     : $20 ($s4 = node->student)
#   $29+28     : $19 ($s3 = node)
#   $29+32     : $18 ($s2 = aux)
#   $29+36     : $17 ($s1 = clonedList)
#   $29+40     : $16 ($s0 = src_list)
#   $29+44     : $31 ($ra)

.text
.globl CloneList_asm
.ent CloneList_asm

CloneList_asm:

    # prologo: reserva frame e salva registradores callee-saved
    addi $29, $29, -48
    sw $31, 44($29)
    sw $16, 40($29)
    sw $17, 36($29)
    sw $18, 32($29)
    sw $19, 28($29)
    sw $20, 24($29)
    sw $21, 20($29)

    move $16, $4               # s0 ($16) = list (src_list)

    # clonedList = malloc(sizeof(struct DoubledLinkedList)) = malloc(12)
    addi $4, $0, 12
    jal malloc
    move $17, $2               # s1 ($17) = clonedList ($v0 = $2)

    # CreateList(clonedList): size=0, head=NULL, tail=NULL
    sw $0, 0($17)               # clonedList->size = 0
    sw $0, 4($17)               # clonedList->head = NULL
    sw $0, 8($17)               # clonedList->tail = NULL

    # aux = list->head;
    lw $18, 4($16)              # s2 ($18) = aux = list->head

clone_loop:

    # while (aux != NULL)
    beq $18, $0, clone_done     # aux == NULL: fim da lista

    # node = malloc(sizeof(struct Node)) = malloc(12)
    addi $4, $0, 12
    jal malloc
    move $19, $2               # s3 ($19) = node

    # node->student = malloc(sizeof(struct Student)) = malloc(148)
    addi $4, $0, 148
    jal malloc
    move $20, $2               # s4 ($20) = node->student
    sw $20, 0($19)              # node->student = novo Student (offset 0 de Node)

    sw $0, 4($19)               # node->prev = NULL (offset 4 de Node)
    sw $0, 8($19)               # node->next = NULL (offset 8 de Node)

    lw $21, 0($18)              # s5 ($21) = aux->student (offset 0 de Node)

    # node->student->registration = aux->student->registration
    lw $8, 92($21)             # carrega registration (offset 92 de Student)
    sw $8, 92($20)             # copia registration

    # strcpy(node->student->name, aux->student->name)
    move $4, $20               # a0 ($4) = destino: node->student->name
    move $5, $21               # a1 ($5) = origem:  aux->student->name
    jal strcpy

    # strcpy(node->student->course, aux->student->course)
    addi $4, $20, 96           # a0 ($4) = destino: node->student->course (offset 96)
    addi $5, $21, 96           # a1 ($5) = origem:  aux->student->course (offset 96)
    jal strcpy

    # Encadear o novo no no final da lista clonada
    lw $8, 8($17)              # t0 ($8) = clonedList->tail (offset 8)
    beq $8, $0, clone_first    # lista clonada ainda vazia

    # lista clonada nao vazia: encadeia node depois do tail
    sw $8, 4($19)              # node->prev = tail
    sw $19, 8($8)              # tail->next = node
    sw $19, 8($17)              # clonedList->tail = node
    j clone_linked

clone_first:

    # lista clonada vazia: node vira head e tail
    sw $19, 4($17)              # clonedList->head = node
    sw $19, 8($17)              # clonedList->tail = node

clone_linked:

    # clonedList->size++
    lw $8, 0($17)
    addi $8, $8, 1
    sw $8, 0($17)

    # aux = aux->next;
    lw $18, 8($18)              # s2 ($18) = aux->next (offset 8 de Node)
    j clone_loop

clone_done:

    # return clonedList
    move $2, $17                # v0 ($2) = clonedList

    # epilogo: restaura registradores e frame
    lw $31, 44($29)
    lw $16, 40($29)
    lw $17, 36($29)
    lw $18, 32($29)
    lw $19, 28($29)
    lw $20, 24($29)
    lw $21, 20($29)
    addi $29, $29, 48
    jr $31

.end CloneList_asm
