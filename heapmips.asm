.text
.globl main

main:
    # 1. SETUP DE HARDWARE
    # Stack Pointer no topo da memória (Endereço 1020 = índice 255)
    addi $sp, $0, 1020
    
    # Constante auxiliar
    addi $k1, $0, 1

    # 2. CARREGAR DADOS (Direto na base 0)
    # Endereço 0: Tamanho (5)
    addi $t0, $0, 5
    sw   $t0, 0($0)

    # Elementos: 10, 3, 50, 2, 1
    addi $t0, $0, 10
    sw   $t0, 4($0)
    
    addi $t0, $0, 3
    sw   $t0, 8($0)
    
    addi $t0, $0, 50
    sw   $t0, 12($0)
    
    addi $t0, $0, 2
    sw   $t0, 16($0)
    
    addi $t0, $0, 1
    sw   $t0, 20($0)

    # 3. CHAMAR SORT
    addi $s0, $0, 0      # Base = 0
    lw   $s1, 0($s0)     # Tamanho
    
    addi $a0, $s0, 4     # &array[0]
    add  $a1, $s1, $0    # n
    jal  sort

    # 4. FIM
infinite_loop:
    j infinite_loop

# --- PROCEDIMENTOS (Idênticos ao anterior) ---
sort:
    addi $sp, $sp, -12
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    add  $s0, $a0, $0
    add  $s1, $a1, $0
sort_loop:
    slt  $at, $0, $s1
    beq  $at, $0, sort_done
    add  $a0, $s0, $0
    add  $a1, $s1, $0
    jal  build
    addi $s0, $s0, 4
    addi $s1, $s1, -1
    j    sort_loop
sort_done:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    addi $sp, $sp, 12
    jr   $ra

build:
    addi $sp, $sp, -16
    sw   $ra, 0($sp)
    sw   $a0, 4($sp)
    sw   $a1, 8($sp)
    srl  $t0, $a1, 1
    addi $t0, $t0, -1
build_loop:
    slt  $at, $t0, $0
    beq  $at, $k1, build_done
    sw   $t0, 12($sp)
    add  $a2, $t0, $0
    jal  heapify
    lw   $a0, 4($sp)
    lw   $a1, 8($sp)
    lw   $t0, 12($sp)
    addi $t0, $t0, -1
    j    build_loop
build_done:
    lw   $ra, 0($sp)
    addi $sp, $sp, 16
    jr   $ra

heapify:
    add  $t0, $a2, $0
    sll  $t1, $a2, 1
    addi $t1, $t1, 1
    addi $t2, $t1, 1
    slt  $at, $t1, $a1
    beq  $at, $0, check_swap
    sll  $t3, $t1, 2
    add  $t3, $a0, $t3
    lw   $t4, 0($t3)
    sll  $t5, $t0, 2
    add  $t5, $a0, $t5
    lw   $t6, 0($t5)
    slt  $at, $t4, $t6
    beq  $at, $0, check_right
    add  $t0, $t1, $0
check_right:
    slt  $at, $t2, $a1
    beq  $at, $0, check_swap
    sll  $t3, $t2, 2
    add  $t3, $a0, $t3
    lw   $t4, 0($t3)
    sll  $t5, $t0, 2
    add  $t5, $a0, $t5
    lw   $t6, 0($t5)
    slt  $at, $t4, $t6
    beq  $at, $0, check_swap
    add  $t0, $t2, $0
check_swap:
    beq  $t0, $a2, heapify_done
    sll  $t1, $a2, 2
    add  $t1, $a0, $t1
    sll  $t2, $t0, 2
    add  $t2, $a0, $t2
    lw   $3, 0($t1)
    lw   $4, 0($t2)
    sw   $4, 0($t1)
    sw   $3, 0($t2)
    add  $a2, $t0, $0
    j    heapify
heapify_done:
    jr   $ra