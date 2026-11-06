        .option pic0                    # codigo non-PIC (chamadas "jal" diretas)
        .text
        .globl  CloneList_asm
        .ent    CloneList_asm

        .equ    DLL_SIZE,       12      # sizeof(struct DoubledLinkedList)
        .equ    NODE_SIZE,      12      # sizeof(struct Node)
        .equ    STUDENT_SIZE,   148     # sizeof(struct Student)
        .equ    STUDENT_REG,    92      # offset de registration
        .equ    STUDENT_COURSE, 96      # offset de course

CloneList_asm:
        # ---- Prologo: salva $ra e $s0-$s5; reserva area de argumentos ----
        addiu   $sp, $sp, -48
        sw      $ra, 44($sp)
        sw      $s0, 40($sp)
        sw      $s1, 36($sp)
        sw      $s2, 32($sp)
        sw      $s3, 28($sp)
        sw      $s4, 24($sp)
        sw      $s5, 20($sp)

        move    $s0, $a0                # $s0 = list (src_list)
        beq     $s0, $zero, clone_null
        nop

        # C: clonedList = malloc(sizeof(struct DoubledLinkedList));
        li      $a0, DLL_SIZE
        jal     malloc
        nop
        move    $s1, $v0                # $s1 = clonedList
        beq     $s1, $zero, clone_null
        nop

        # C: CreateList(clonedList);
        sw      $zero, 0($s1)           # clonedList->size = 0
        sw      $zero, 4($s1)           # clonedList->head = NULL
        sw      $zero, 8($s1)           # clonedList->tail = NULL

        # C: aux = list->head;
        lw      $s2, 4($s0)             # $s2 = aux

clone_loop:
        # C: while (aux != NULL)
        beq     $s2, $zero, clone_done
        nop

        # C: node = malloc(sizeof(struct Node));
        li      $a0, NODE_SIZE
        jal     malloc
        nop
        move    $s3, $v0                # $s3 = node

        # C: node->student = malloc(sizeof(struct Student));
        li      $a0, STUDENT_SIZE
        jal     malloc
        nop
        move    $s4, $v0                # $s4 = node->student
        sw      $s4, 0($s3)             # node->student = novo Student

        sw      $zero, 4($s3)           # node->prev = NULL
        sw      $zero, 8($s3)           # node->next = NULL

        # C: strcpy(node->student->name, aux->student->name);
        # C: node->student->registration = aux->student->registration;
        # C: strcpy(node->student->course, aux->student->course);
        lw      $s5, 0($s2)             # $s5 = aux->student
        lw      $t0, STUDENT_REG($s5)
        sw      $t0, STUDENT_REG($s4)   # copia registration

        move    $a0, $s4                # destino: node->student->name
        move    $a1, $s5                # origem : aux->student->name
        jal     strcpy
        nop

        addiu   $a0, $s4, STUDENT_COURSE # destino: node->student->course
        addiu   $a1, $s5, STUDENT_COURSE # origem : aux->student->course
        jal     strcpy
        nop

        # C: InsertNode(clonedList, node) -> anexa no fim (lista ja ordenada)
        lw      $t0, 8($s1)             # $t0 = clonedList->tail
        beq     $t0, $zero, clone_first
        nop

        # Lista clonada nao vazia: encadeia depois da tail
        sw      $t0, 4($s3)             # node->prev = tail
        sw      $s3, 8($t0)             # tail->next = node
        sw      $s3, 8($s1)             # clonedList->tail = node
        j       clone_linked
        nop

clone_first:
        # Lista clonada vazia: node e head e tail
        sw      $s3, 4($s1)             # clonedList->head = node
        sw      $s3, 8($s1)             # clonedList->tail = node

clone_linked:
        # C: clonedList->size++
        lw      $t0, 0($s1)
        addiu   $t0, $t0, 1
        sw      $t0, 0($s1)

        # C: aux = aux->next;
        lw      $s2, 8($s2)
        j       clone_loop
        nop

clone_done:
        # C: return clonedList;
        move    $v0, $s1
        j       clone_return
        nop

clone_null:
        move    $v0, $zero              # src_list == NULL -> retorna NULL

clone_return:
        # ---- Epilogo: restaura $ra e $s0-$s5 ----
        lw      $ra, 44($sp)
        lw      $s0, 40($sp)
        lw      $s1, 36($sp)
        lw      $s2, 32($sp)
        lw      $s3, 28($sp)
        lw      $s4, 24($sp)
        lw      $s5, 20($sp)
        addiu   $sp, $sp, 48
        jr      $ra
        nop

        .end    CloneList_asm

        .section .note.GNU-stack,"",@progbits
