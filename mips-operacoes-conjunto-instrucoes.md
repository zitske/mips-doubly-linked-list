# Guia de Operações e Conjunto de Instruções da Arquitetura MIPS32

## 1. Fundamentos da Arquitetura MIPS32

A arquitetura MIPS32 é uma arquitetura do tipo RISC (*Reduced Instruction Set Computer*) baseada no modelo **Load/Store**. Nesse modelo, as operações lógicas e aritméticas não acessam a memória principal diretamente; elas operam exclusivamente sobre dados armazenados no banco de registradores internos. O acesso à memória ocorre apenas por meio de instruções dedicadas de transferência de dados (*Load* para leitura e *Store* para escrita).

### 1.1 Modelo de Memória e Alinhamento

O MIPS32 utiliza endereçamento por byte (*byte addressing*) com barramento de dados e endereços de 32 bits, permitindo o endereçamento de até $2^{32}$ bytes ($4\text{ GiB}$) de memória.

Ao transferir palavras completas de 32 bits (`lw` e `sw`), a arquitetura exige o **alinhamento de palavra**: o endereço de memória deve ser obrigatoriamente um múltiplo de 4 (endereços terminados em `00` na representação binária). Para a transferência de meias-palavras de 16 bits (`lh`, `lhu` e `sh`), o endereço deve ser par (múltiplo de 2).

### 1.2 Banco de Registradores de Propósito Geral e Registradores Especiais

O MIPS32 dispõe de 32 registradores de propósito geral de 32 bits (denominados de `$0` a `$31`), além de registradores especiais para operações de multiplicação, divisão e controle de execução.

| Número | Nome Mnemônico | Função e Convenção de Uso (GCC / MipsIt ABI) | Preservado na Chamada? |
| :--- | :--- | :--- | :--- |
| `$0` | `$zero` | Constante permanente com valor zero ($0\text{x}00000000$) | Não aplicável (somente leitura) |
| `$1` | `$at` | Reservado para o montador (*Assembler Temporary*) | Não |
| `$2–$3` | `$v0–$v1` | Valores de retorno de subrotinas e códigos de chamada do sistema | Não |
| `$4–$7` | `$a0–$a3` | Parâmetros de entrada / argumentos de subrotinas | Não |
| `$8–$15` | `$t0–$t7` | Registradores temporários (não preservados pela subrotina) | Não |
| `$16–$23` | `$s0–$s7` | Registradores salvos (devem ser preservados na pilha pela subrotina) | Sim (*Callee-saved*) |
| `$24–$25` | `$t8–$t9` | Registradores temporários adicionais | Não |
| `$26–$27` | `$k0–$k1` | Reservados para o núcleo do sistema operacional / interrupções | Não |
| `$28` | `$gp` | Ponteiro para a área global de dados (*Global Pointer*) | Sim |
| `$29` | `$sp` | Ponteiro de pilha (*Stack Pointer*) | Sim |
| `$30` | `$fp` | Ponteiro de quadro da pilha (*Frame Pointer*) | Sim |
| `$31` | `$ra` | Endereço de retorno de subrotina (*Return Address*, gravado por `jal`) | Sim (em subrotinas não-folha) |

Além dos registradores de propósito geral, a arquitetura possui:
* **`Hi` e `Lo`**: Registradores especiais de 32 bits utilizados em operações de multiplicação (guardando o produto de 64 bits) e divisão (guardando o quociente em `Lo` e o resto em `Hi`).
* **`PC` (*Program Counter*)**: Registrador de 32 bits que armazena o endereço da instrução em execução.

---

## 2. Formatos de Instrução de 32 Bits

Todas as instruções da arquitetura MIPS32 possuem tamanho fixo de 32 bits (4 bytes). As instruções são categorizadas em três formatos principais conforme o tipo de operandos que utilizam.

### 2.1 Visão Geral dos Campos

Toda instrução inicia com um campo de **`opcode`** de 6 bits (bits 31 a 26), que identifica a operação principal ou a classe da instrução.

| Formato | Bits 31–26 (6b) | Bits 25–21 (5b) | Bits 20–16 (5b) | Bits 15–11 (5b) | Bits 10–6 (5b) | Bits 5–0 (6b) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Tipo-R** | `opcode` ($000000$) | `rs` (Fonte 1) | `rt` (Fonte 2) | `rd` (Destino) | `shamt` (Shift) | `funct` (Função) |
| **Tipo-I** | `opcode` | `rs` (Base/Fonte) | `rt` (Destino/Alvo) | `constante imediata / offset` (16 bits) | | |
| **Tipo-J** | `opcode` | `endereço de destino` (26 bits) | | | | |

### 2.2 Formato Tipo-R (Register)

Utilizado para a maioria das instruções lógicas e aritméticas entre registradores. O campo `opcode` possui o valor $0$. A operação específica é definida pelo campo `funct` (bits 5 a 0).
* **`rs` (5 bits)**: Registrador fonte 1 (*Register Source*).
* **`rt` (5 bits)**: Registrador fonte 2 (*Register Target*).
* **`rd` (5 bits)**: Registrador de destino do resultado (*Register Destination*).
* **`shamt` (5 bits)**: Quantidade de deslocamento em bits (*Shift Amount*), usado em `sll`, `srl` e `sra`.
* **`funct` (6 bits)**: Código de função estendido que especifica a operação exata da ULA.

### 2.3 Formato Tipo-I (Immediate)

Utilizado para instruções aritméticas/lógicas com constantes imediatas, transferências de memória (`lw`, `sw`, `lb`, `sb`, etc.) e desvios condicionais (`beq`, `bne`).
* **`rs` (5 bits)**: Registrador base ou registrador de comparação 1.
* **`rt` (5 bits)**: Registrador de destino (para `lw` e `addi`) ou registrador de fonte/dado (para `sw` e `beq`).
* **`imediato / offset` (16 bits)**: Valor numérico constante de 16 bits. Para acesso à memória e desvios, representa um deslocamento em complemento de 2.

### 2.4 Formato Tipo-J (Jump)

Utilizado por instruções de salto incondicional (`j` e `jal`).
* **`endereço` (26 bits)**: Endereço de destino codificado em palavras (a ser multiplicado por 4 e concatenado aos 4 bits mais significativos do `PC` atual para formar o endereço de 32 bits final).

---

## 3. Especificação Detalhada das Operações Nativas MIPS32

### 3.1 Operações Aritméticas

As operações aritméticas executam adição, subtração, multiplicação e divisão sobre inteiros de 32 bits.

| Mnemônico | Sintaxe em Assembly | Formato | Operação Realizada |
| :--- | :--- | :--- | :--- |
| `add` | `add rd, rs, rt` | Tipo-R | `$rd \leftarrow \$rs + \$rt` (gera *trap* em caso de overflow) |
| `addu` | `addu rd, rs, rt` | Tipo-R | `$rd \leftarrow \$rs + \$rt` (sem detecção de overflow) |
| `sub` | `sub rd, rs, rt` | Tipo-R | `$rd \leftarrow \$rs - \$rt` (gera *trap* em caso de overflow) |
| `subu` | `subu rd, rs, rt` | Tipo-R | `$rd \leftarrow \$rs - \$rt` (sem detecção de overflow) |
| `addi` | `addi rt, rs, imm` | Tipo-I | `$rt \leftarrow \$rs + \text{sign\_ext}(imm)` (com overflow trap) |
| `addiu` | `addiu rt, rs, imm` | Tipo-I | `$rt \leftarrow \$rs + \text{sign\_ext}(imm)` (sem overflow trap) |
| `mult` | `mult rs, rt` | Tipo-R | `[Hi:Lo] \leftarrow \$rs \times \$rt` (multiplicação com sinal) |
| `multu` | `multu rs, rt` | Tipo-R | `[Hi:Lo] \leftarrow \$rs \times \$rt` (multiplicação sem sinal) |
| `div` | `div rs, rt` | Tipo-R | `Lo \leftarrow \$rs / \$rt` (quociente); `Hi \leftarrow \$rs \% \$rt` (resto) |
| `divu` | `divu rs, rt` | Tipo-R | `Lo \leftarrow \$rs / \$rt`; `Hi \leftarrow \$rs \% \$rt` (sem sinal) |
| `mfhi` | `mfhi rd` | Tipo-R | `$rd \leftarrow Hi` (copia registrador especial `Hi`) |
| `mflo` | `mflo rd` | Tipo-R | `$rd \leftarrow Lo` (copia registrador especial `Lo`) |

### 3.2 Operações Lógicas e Bitwise

Realizam operações binárias bit a bit sobre operandos de 32 bits.

| Mnemônico | Sintaxe em Assembly | Formato | Operação Realizada |
| :--- | :--- | :--- | :--- |
| `and` | `and rd, rs, rt` | Tipo-R | `$rd \leftarrow \$rs \text{ AND } \$rt` |
| `andi` | `andi rt, rs, imm` | Tipo-I | `$rt \leftarrow \$rs \text{ AND } \text{zero\_ext}(imm)` (extensão a zero) |
| `or` | `or rd, rs, rt` | Tipo-R | `$rd \leftarrow \$rs \text{ OR } \$rt` |
| `ori` | `ori rt, rs, imm` | Tipo-I | `$rt \leftarrow \$rs \text{ OR } \text{zero\_ext}(imm)` |
| `xor` | `xor rd, rs, rt` | Tipo-R | `$rd \leftarrow \$rs \text{ XOR } \$rt` |
| `xori` | `xori rt, rs, imm` | Tipo-I | `$rt \leftarrow \$rs \text{ XOR } \text{zero\_ext}(imm)` |
| `nor` | `nor rd, rs, rt` | Tipo-R | `$rd \leftarrow \text{NOT}(\$rs \text{ OR } \$rt)` |
| `lui` | `lui rt, imm` | Tipo-I | `$rt(31:16) \leftarrow imm$; $rt(15:0) \leftarrow 0\text{x}0000` |

### 3.3 Operações de Deslocamento (Shift)

Utilizadas para deslocamento binário de bits, muito empregadas para multiplicações e divisões eficientes por potências de 2.

| Mnemônico | Sintaxe em Assembly | Formato | Operação Realizada |
| :--- | :--- | :--- | :--- |
| `sll` | `sll rd, rt, shamt` | Tipo-R | `$rd \leftarrow \$rt \ll shamt` (preenche com zeros à direita) |
| `srl` | `srl rd, rt, shamt` | Tipo-R | `$rd \leftarrow \$rt \gg shamt` (deslocamento lógico à esquerda com zeros) |
| `sra` | `sra rd, rt, shamt` | Tipo-R | `$rd \leftarrow \$rt \gg shamt` (deslocamento aritmético, preserva sinal) |
| `sllv` | `sllv rd, rt, rs` | Tipo-R | `$rd \leftarrow \$rt \ll \$rs(4:0)` (quantidade de deslocamento em registrador) |
| `srlv` | `srlv rd, rt, rs` | Tipo-R | `$rd \leftarrow \$rt \gg \$rs(4:0)` (deslocamento lógico por registrador) |
| `srav` | `srav rd, rt, rs` | Tipo-R | `$rd \leftarrow \$rt \gg \$rs(4:0)` (deslocamento aritmético por registrador) |

### 3.4 Operações de Comparação e Teste

Instruções da família *Set on Less Than* avaliam relações de ordem e armazenam o valor booleano $1$ (verdadeiro) ou $0$ (falso) no registrador de destino.

| Mnemônico | Sintaxe em Assembly | Formato | Operação Realizada |
| :--- | :--- | :--- | :--- |
| `slt` | `slt rd, rs, rt` | Tipo-R | Se $\$rs < \$rt$ (com sinal), $\$rd \leftarrow 1$; senão $\$rd \leftarrow 0$ |
| `slti` | `slti rt, rs, imm` | Tipo-I | Se $\$rs < \text{sign\_ext}(imm)$, $\$rt \leftarrow 1$; senão $\$rt \leftarrow 0$ |
| `sltu` | `sltu rd, rs, rt` | Tipo-R | Se $\$rs < \$rt$ (sem sinal), $\$rd \leftarrow 1$; senão $\$rd \leftarrow 0$ |
| `sltiu` | `sltiu rt, rs, imm` | Tipo-I | Se $\$rs < \text{sign\_ext}(imm)$ (sem sinal), $\$rt \leftarrow 1$; senão $\$rt \leftarrow 0$ |

### 3.5 Operações de Transferência de Dados / Memória

Todas as instruções de acesso à memória utilizam o modo de endereçamento **base + deslocamento** (`offset(rs)`), onde o endereço final de memória é calculado pela soma $\text{MEM}[\$rs + \text{sign\_ext}(offset)]$.

| Mnemônico | Sintaxe em Assembly | Formato | Operação Realizada |
| :--- | :--- | :--- | :--- |
| `lw` | `lw rt, offset(rs)` | Tipo-I | `$rt \leftarrow \text{MEM}_{32}[\$rs + offset]$` (carrega palavra de 32 bits) |
| `sw` | `sw rt, offset(rs)` | Tipo-I | `$\text{MEM}_{32}[\$rs + offset] \leftarrow \$rt$` (armazena palavra de 32 bits) |
| `lh` | `lh rt, offset(rs)` | Tipo-I | Carrega meia-palavra (16 bits) e realiza **extensão de sinal** para 32 bits |
| `lhu` | `lhu rt, offset(rs)` | Tipo-I | Carrega meia-palavra (16 bits) e realiza **extensão com zeros** |
| `sh` | `sh rt, offset(rs)` | Tipo-I | Armazena os 16 bits menos significativos de `$rt$` na memória |
| `lb` | `lb rt, offset(rs)` | Tipo-I | Carrega um byte (8 bits) e realiza **extensão de sinal** para 32 bits |
| `lbu` | `lbu rt, offset(rs)` | Tipo-I | Carrega um byte (8 bits) e realiza **extensão com zeros** |
| `sb` | `sb rt, offset(rs)` | Tipo-I | Armazena o byte menos significativo de `$rt$` na memória |

### 3.6 Operações de Controle de Fluxo (Desvios e Saltos)

As instruções de controle alteram a sequência de execução do programa de forma condicional ou incondicional. Nos desvios condicionais (`beq` e `bne`), o campo `offset` é especificado em palavras de 32 bits e é somado ao $(\text{PC} + 4)$.

| Mnemônico | Sintaxe em Assembly | Formato | Operação Realizada |
| :--- | :--- | :--- | :--- |
| `beq` | `beq rs, rt, label` | Tipo-I | Se $\$rs == \$rt$, desvia para $\text{PC} + 4 + (offset \times 4)$ |
| `bne` | `bne rs, rt, label` | Tipo-I | Se $\$rs \neq \$rt$, desvia para $\text{PC} + 4 + (offset \times 4)$ |
| `j` | `j label` | Tipo-J | Desvio incondicional: $\text{PC} \leftarrow \text{PC}(31:28) \mathbin{\Vert} (address \times 4)$ |
| `jal` | `jal label` | Tipo-J | Subrotina: $\$ra \leftarrow \text{PC} + 4$; $\text{PC} \leftarrow \text{destino}$ |
| `jr` | `jr rs` | Tipo-R | Salto indireto por registrador: $\text{PC} \leftarrow \$rs$ (ex.: `jr $ra`) |

---

## 4. Mapeamento de Pseudo-Instruções do Montador

Os ambientes de montagem (como MARS e MipsIt) oferecem **pseudo-instruções** para facilitar a escrita de código. O montador traduz automaticamente cada pseudo-instrução em uma ou mais instruções nativas MIPS32 antes da execução.

| Pseudo-Instrução | Significado / Ação | Tradução pelo Montador (Instruções Nativas MIPS) |
| :--- | :--- | :--- |
| `li $rt, imm32` | Carrega constante de 32 bits | `lui $rt, imm(31:16)`<br>`ori $rt, $rt, imm(15:0)` |
| `la $rt, label` | Carrega endereço de memória de rótulo | `lui $1, &label(31:16)`<br>`ori $rt, $1, &label(15:0)` |
| `move $rd, $rs` | Copia conteúdo entre registradores | `addu $rd, $zero, $rs` (ou `or $rd, $rs, $zero`) |
| `not $rd, $rs` | Inverte todos os bits (complemento de 1) | `nor $rd, $rs, $zero` |
| `neg $rd, $rs` | Inverte o sinal numérico (negativo) | `sub $rd, $zero, $rs` |
| `subi $rt, $rs, imm` | Subtrai valor imediato constante | `addi $rt, $rs, -imm` |
| `b $label` | Desvio incondicional relativo | `beq $zero, $zero, label` |
