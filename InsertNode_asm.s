        .option pic0                    # codigo non-PIC (chamadas "jal" diretas)
        .text
        .globl  InsertNode_asm
        .ent    InsertNode_asm

InsertNode_asm:
        move    $t0, $a0                # $t0 = list
        move    $t1, $a1                # $t1 = newNode

        # C: newNode->prev = NULL; newNode->next = NULL;
        sw      $zero, 4($t1)
        sw      $zero, 8($t1)

        # C: newNode->student->registration (carregado uma unica vez)
        lw      $t5, 0($t1)             # $t5 = newNode->student
        lw      $t2, 92($t5)            # $t2 = registration do novo aluno

        # C: if (list->size == 0)
        lw      $t5, 0($t0)
        bne     $t5, $zero, in_nonempty
        nop

        # C: list->head = newNode; list->tail = newNode;
        sw      $t1, 4($t0)
        sw      $t1, 8($t0)
        j       in_done
        nop

in_nonempty:
        # C: aux = list->head;
        lw      $t3, 4($t0)             # $t3 = aux

in_loop:
        # C: while (aux != NULL)
        beq     $t3, $zero, in_tail     # aux == NULL -> inserir no fim
        nop

        # C: aux->student->registration
        lw      $t5, 0($t3)             # $t5 = aux->student
        lw      $t4, 92($t5)            # $t4 = registration de aux

        # C: if (newNode->student->registration >= aux->student->registration)
        #    "registration" e unsigned int, por isso sltu (comparacao sem sinal)
        sltu    $t6, $t2, $t4           # $t6 = (novo < aux)
        bne     $t6, $zero, in_next     # novo < aux -> continua percorrendo
        nop

        # C: if (novo == aux) return STUDENT_ALREADY_INSERTED;
        beq     $t2, $t4, in_dup
        nop

        # C: else break;  (novo > aux -> posicao encontrada)
        j       in_found
        nop

in_next:
        # C: aux = aux->next;
        lw      $t3, 8($t3)
        j       in_loop
        nop

in_found:
        # C: if (aux == list->head) { ... novo head ... }
        lw      $t5, 4($t0)             # $t5 = list->head
        beq     $t3, $t5, in_head
        nop

        # C: else { insercao entre aux->prev e aux }
        lw      $t6, 4($t3)             # $t6 = aux->prev
        sw      $t1, 8($t6)             # aux->prev->next = newNode
        sw      $t6, 4($t1)             # newNode->prev = aux->prev
        sw      $t1, 4($t3)             # aux->prev = newNode
        sw      $t3, 8($t1)             # newNode->next = aux
        j       in_done
        nop

in_head:
        # C: aux->prev = newNode; newNode->next = aux; list->head = newNode;
        sw      $t1, 4($t3)
        sw      $t3, 8($t1)
        sw      $t1, 4($t0)
        j       in_done
        nop

in_tail:
        # C: else if (aux == NULL) { insercao depois de list->tail }
        lw      $t5, 8($t0)             # $t5 = list->tail
        sw      $t5, 4($t1)             # newNode->prev = list->tail
        sw      $t1, 8($t5)             # list->tail->next = newNode
        sw      $t1, 8($t0)             # list->tail = newNode
        j       in_done
        nop

in_dup:
        # C: return STUDENT_ALREADY_INSERTED;
        li      $v0, -1
        j       in_return
        nop

in_done:
        # C: list->size++;
        lw      $t5, 0($t0)
        addiu   $t5, $t5, 1
        sw      $t5, 0($t0)

        # C: return INSERTION_OK;
        move    $v0, $zero

in_return:
        jr      $ra
        nop

        .end    InsertNode_asm

        .section .note.GNU-stack,"",@progbits
