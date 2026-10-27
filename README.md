# MIPS Doubly Linked List Implementation (`mips-doubly-linked-list`)

This repository contains the hybrid C / MIPS32 Assembly implementation of key operations on a **Doubly Linked List** (`DoubledLinkedList`), developed for the *Computer Architecture and Organization* course.

---

## 📋 Task Checklist & Implementation Steps

### Project Setup
- [ ] Set up **MipsIt** IDE environment and import `DoublyLinkedList.c`
- [ ] Create assembly source files (`InsertNode_asm.s` and `CloneList_asm.s`) in the project tree

### Function 1: `InsertNode_asm.s`
- [ ] Set up function entry and register usage
- [ ] Read `$a0` (pointer to `DoubledLinkedList`) and `$a1` (pointer to already-allocated `Node`)
- [ ] Load `student` pointer from `newNode->student` (offset 0 of `$a1`)
- [ ] Read `registration` from `student->registration` (offset 92 of student)
- [ ] Traverse the list starting at `head` (`$a0 + 4`) to find correct insertion point (sorted descending by `registration`)
- [ ] Update pointer connections (`prev`, `next`) for adjacent nodes
- [ ] Update `head` and `tail` pointers if inserting at boundary positions (empty list, head, or tail)
- [ ] Increment `list->size` counter (`$a0 + 0`)

### Function 2: `CloneList_asm.s`
- [ ] Set up stack frame to save caller/callee registers (`$s0-$s7`, `$ra`)
- [ ] Call `malloc` to allocate memory for the new `DoubledLinkedList` descriptor
- [ ] Handle null/empty source list check (`$a0 == NULL`)
- [ ] Loop through each node of the source list:
  - [ ] Allocate memory for new `Node` and new `Student`
  - [ ] Copy `registration` integer field
  - [ ] Call `strcpy` to duplicate `name` and `course` string buffers
  - [ ] Call `InsertNode_asm` or manually link the new node to the cloned list
- [ ] Restore stack frame and return pointer to cloned list in `$v0`

### Testing & Delivery
- [ ] Compile using `Build -> Rebuild All` in MipsIt
- [ ] Upload to MIPS simulator and verify with test cases
- [ ] Complete the development report / difficulty assessment document

---

## 📌 Project Overview

The core goal is to replace standard C list-manipulation routines with custom MIPS Assembly functions (`.s`) while strictly adhering to MIPS register calling conventions and stack frame management (GCC MIPS ABI).

### Target Functions Implemented in Assembly:
1. **`InsertNode_asm`**: Inserts an already-allocated node (`struct Node *newNode`) into the list sorted in **descending order** by registration number (`Student.registration`).
2. **`CloneList_asm`**: Performs a **deep copy** of the entire doubly linked list by allocating new memory blocks for the descriptor, nodes, and student structs, invoking standard C library helpers (`malloc`, `strcpy`).

---

## 📐 Data Structures

Defined in `DoublyLinkedList.c`:

```c
struct Student {
    char name[90];             // Offset 0  (90 bytes)
    unsigned int registration; // Offset 92 (4 bytes - word aligned)
    char course[50];           // Offset 96 (50 bytes)
};

struct Node {
    struct Student *student;   // Offset 0 (4 bytes pointer)
    struct Node *prev;         // Offset 4 (4 bytes pointer)
    struct Node *next;         // Offset 8 (4 bytes pointer)
};

struct DoubledLinkedList {
    int size;                  // Offset 0 (4 bytes integer)
    struct Node *head;         // Offset 4 (4 bytes pointer)
    struct Node *tail;         // Offset 8 (4 bytes pointer)
};
```

---

## 🛠️ Detailed Function Specifications

### 1. `InsertNode_asm(struct DoubledLinkedList *list, struct Node *newNode)`
* **File**: `InsertNode_asm.s`
* **Inputs**: `$a0` = `list`, `$a1` = `newNode` (already allocated in memory)
* **Behavior**:
  * Receives pointer to the list descriptor (`$a0`) and pointer to the pre-allocated node (`$a1`).
  * Navigates the doubly linked list from `head` to find the correct insertion position according to `Student.registration` (highest registration number comes first).
  * Updates four pointers (`prev`, `next`, `head`, `tail`) and increments `list->size`.

### 2. `CloneList_asm(struct DoubledLinkedList *src_list)`
* **File**: `CloneList_asm.s`
* **Inputs**: `$a0` = `src_list`
* **Output**: `$v0` = pointer to new cloned list
* **Behavior**:
  * Calls `malloc()` via C ABI to allocate memory for the new `DoubledLinkedList` descriptor, each `Node`, and each `Student`.
  * Uses `strcpy()` to duplicate the `name` and `course` strings.
  * Preserves caller/callee-saved registers (`$s0-$s7`, `$ra`) on the stack frame before making nested function calls (`jal`).

---

## 💻 Environment & Tools

* **IDE / Toolchain**: MipsIt Framework (MIPS32 GCC Cross-Compiler).
* **Simulator**: MIPS Architectural Simulator.
* **Test Harness**: `DoublyLinkedList.c`.

---

## 🚀 How to Run

1. Open **MipsIt** IDE and create a new project based on `DoublyLinkedList.c`.
2. Include assembly source files (`InsertNode_asm.s` and `CloneList_asm.s`).
3. Compile: `Build -> Rebuild All`.
4. Run: `Build -> Upload -> To Simulator`.
