# Trabalho: Implementação de funções em assembly que operam sobre uma lista duplamente encadeada

**Referência do Arquivo Original:** `trabalho (2).pptx`
**Material de apoio (Moodle):** `DoublyLinkedList.c`

O programa fornecido implementa funções em C que operam sobre uma lista duplamente encadeada e contém alguns testes.
**Objetivo inicial:** Executar e entender as funções do programa.

---

## Estruturas de Dados: Lista Duplamente Encadeada

Esquema da estrutura (*Head* e *Tail* interligando os *StudentNodes*).

```c
struct Student {       
    char name[90];       
    unsigned int registration;    
    char course[50];    
};

struct Node {       
    struct Student *student;       
    struct Node *prev, *next;
};

struct DoubledLinkedList {       
    int size;       
    struct Node *head;   
    struct Node *tail;
};
```

---

## Funções Básicas
O programa implementa 4 funções em C que operam sobre as listas encadeadas:

*   **`CreateList()`:** Inicializa a lista.
*   **`InsertNode()`:** Insere um nodo na lista (de forma ordenada).
*   **`CloneList()`:** Cria um clone da lista.
*   **`PrintList()`:** Imprime a lista do primeiro ao último nodo.
*   **`PrintListReverse()`:** Imprime a lista do último nodo até o primeiro.

---

## Tarefa 1: Função `InsertNode` (Valor: 5,0)
**Objetivo:** Implementar em assembly do MIPS a função `InsertNode()` → `InsertNode_asm()`

*   A função insere estudantes na lista de acordo com o número da matrícula.
*   O estudante com a maior matrícula é o **primeiro** da lista.
*   Os demais são encadeados em ordem **decrescente**.

---

## Tarefa 2: Função `CloneList` (Valor: 5,0)
**Objetivo:** Implementar em assembly do MIPS a função `CloneList()` → `CloneList_asm()`

*   A função cria um clone da lista alocando memória para um novo descritor e para todos os nodos/estudantes.
*   Na implementação, esta função deve chamar as seguintes funções da biblioteca C:
    *   `malloc()`: para alocar memória para o descritor e os nodos clonados da lista.
    *   `strcpy()`: para setar os campos *name* e *course* da `struct Student`.
*   **Atenção:** As funções da biblioteca C não devem ser implementadas por você (apenas chamadas).

---

## Orientações de Implementação
*   **Atenção aos comentários do código:** Utilize trechos do código C nos comentários quando for conveniente.
*   **Exemplo:** Tomar como exemplo o arquivo `bubbleSort.asm` (disponível no Moodle).
*   **Convenções:** Muita atenção às convenções de uso dos registradores e da pilha (isso é fundamental).
*   **Regra de Ouro:** As funções/structs já implementadas em C **não devem ser alteradas** em hipótese alguma (nem declaração, nem implementação).

---

## Desenvolvimento no MipsIt
*   Criar um projeto no MipsIt baseado no programa `DoubleLinkedList.c` para o desenvolvimento do trabalho.
*   Substituir as chamadas das funções `InsertNode` e `CloneList` implementadas em C pelas respectivas implementações em assembly.
*   As implementações originais em C podem ser mantidas no código (apenas comente ou troque a chamada).
*   **Critério de Sucesso:** Depois das substituições, o resultado da execução deve ser **idêntico** ao do código original.

**Dica:** Substitua uma função por vez. A cada substituição, execute o programa e verifique se a saída continua correta.

---

## Regras de Entrega
*   **Equipes:** Grupos de até 3 alunos.
*   **Prazo:** 10/11 (2 semanas).
*   **Submissão:** Via Moodle (apenas **um** integrante deve ser o responsável por enviar).
*   **Arquivos a serem entregues:**
    1.  `InsertNode_asm.s`
    2.  `CloneList_asm.s`
    3.  **Arquivo texto:** descrevendo as dificuldades enfrentadas durante o desenvolvimento, quais funções funcionam e quais não.
*   **Atenção:** Colocar os nomes dos integrantes do grupo no cabeçalho dos arquivos.