! This program executes pow as a test program using the LC 2200 calling convention
! Check your registers ($v0) and memory to see if it is consistent with this program

        ! vector table
vector0:
        .fill 0x00000000                        ! device ID 0
        .fill 0x00000000                        ! device ID 1
        .fill 0x00000000                        ! ...
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000                        ! device ID 7
        ! end vector table

main:	lea $sp, initsp                         ! initialize the stack pointer
        lw $sp, 0($sp)                          ! finish initialization

        lea     $t0, vector0                   ! TODO FIX ME: Install timer interrupt handler into vector table
        lea     $t1, timer_handler
        sw      $t1, 0x0($t0)
!---------------------------------
                                                        ! TODO FIX ME: Install keyboard interrupt handler into vector table
                                                ! TODO FIX ME: Install timer interrupt handler into vector table
        lea     $t1, garden_handler
        sw      $t1, 0x1($t0)
        
        

        ei                                    ! Enable interrupts

        lea $a0, BASE                           ! load base for pow
        lw $a0, 0($a0)
        lea $a1, EXP                            ! load power for pow
        lw $a1, 0($a1)
        lea $at, POW                            ! load address of pow
        jalr $ra, $at                           ! run pow
        lea $a0, ANS                            ! load base for pow
        sw $v0, 0($a0)

        halt                                    ! stop the program here
        addi $v0, $zero, -1                     ! load a bad value on failure to halt

BASE:   .fill 2
EXP:    .fill 8
ANS:	.fill 0                                 ! should come out to 256 (BASE^EXP)

POW:    addi $sp, $sp, -1                       ! allocate space for old frame pointer
        sw $fp, 0($sp)

        addi $fp, $sp, 0                        ! set new frame pinter

        beq $a0, $zero, RET0                    ! if the base is 0, return 0
        beq $a1, $zero, RET1                    ! if the exponent is 0, return 1

        addi $a1, $a1, -1                       ! decrement the power

        lea $at, POW                            ! load the address of POW
        addi $sp, $sp, -2                       ! push 2 slots onto the stack
        sw $ra, -1($fp)                         ! save RA to stack
        sw $a0, -2($fp)                         ! save arg 0 to stack
        jalr $ra, $at                           ! recursively call POW
        add $a1, $v0, $zero                     ! store return value in arg 1
        lw $a0, -2($fp)                         ! load the base into arg 0
        lea $at, MULT                           ! load the address of MULT
        jalr $ra, $at                           ! multiply arg 0 (base) and arg 1 (running product)
        lw $ra, -1($fp)                         ! load RA from the stack
        addi $sp, $sp, 2

        beq $zero, $zero, FIN                   ! unconditional branch to FIN

RET1:   addi $v0, $zero, 1                      ! return a value of 1
        beq $zero, $zero, FIN                   ! unconditional branch to FIN

RET0:   add $v0, $zero, $zero                   ! return a value of 0

FIN:	lw $fp, 0($fp)                          ! restore old frame pointer
        addi $sp, $sp, 1                        ! pop off the stack
        jalr $zero, $ra

MULT:   add $v0, $zero, $zero                   ! return value = 0
        addi $t0, $zero, 0                      ! sentinel = 0
AGAIN:  add $v0, $v0, $a0                       ! return value += argument0
        addi $t0, $t0, 1                        ! increment sentinel
        bgt $a1, $t0, AGAIN                     ! while sentinel < argument1

        jalr $zero, $ra                         ! return from mult

timer_handler:

                                !TODO FIX ME
        addi    $sp, $sp, -15
        sw      $k0, 0($sp)
        ei

        sw      $at, 1($sp)
        sw      $v0, 2($sp)
        sw      $a0, 3($sp)
        sw      $a1, 4($sp)
        sw      $a2, 5($sp)
        sw      $t0, 6($sp)
        sw      $t1, 7($sp)
        sw      $t2, 8($sp)
        sw      $s0, 9($sp)
        sw      $s1, 10($sp)
        sw      $s2, 11($sp)
        sw      $sp, 12($sp)
        sw      $fp, 13($sp)
        sw      $ra, 14($sp)

        lea     $t0, ticks                      ! increment the counter ticks
        lw      $t1, 0($t0)
        lw      $t2, 0($t1)
        addi    $t2, $t2, 1
        sw      $t2, 0($t1)

        lw      $at, 1($sp)     ! restore registers
        lw      $v0, 2($sp)
        lw      $a0, 3($sp)
        lw      $a1, 4($sp)
        lw      $a2, 5($sp)
        lw      $t0, 6($sp)
        lw      $t1, 7($sp)
        lw      $t2, 8($sp)
        lw      $s0, 9($sp)
        lw      $s1, 10($sp)
        lw      $s2, 11($sp)
        lw      $sp, 12($sp)
        lw      $fp, 13($sp)
        lw      $ra, 14($sp)

        di
        lw      $k0, 0($sp)
        addi    $sp, $sp, 15
        reti
        

        

garden_handler:
        addi $sp, $sp, -15				!TODO FIX ME
        sw $k0, 0($sp)

        ei

        sw      $at, 1($sp)
        sw      $v0, 2($sp)
        sw      $a0, 3($sp)
        sw      $a1, 4($sp)
        sw      $a2, 5($sp)
        sw      $t0, 6($sp)
        sw      $t1, 7($sp)
        sw      $t2, 8($sp)
        sw      $s0, 9($sp)
        sw      $s1, 10($sp)
        sw      $s2, 11($sp)
        sw      $sp, 12($sp)
        sw      $fp, 13($sp)
        sw      $ra, 14($sp)

        lea     $t0, maxval                ! handler code
        lw      $t1, 0($t0)
        lw      $t2, 0($t1)
        in      $a0, 0x1
        bgt     $a0, $t2, abigger
        sw      $t2, 0($t1)
        beq     $zero, $zero, jump
abigger: sw     $a0, 0($t1)

jump:   lw      $at, 1($sp)
        lw      $v0, 2($sp)
        lw      $a0, 3($sp)
        lw      $a1, 4($sp)
        lw      $a2, 5($sp)
        lw      $t0, 6($sp)
        lw      $t1, 7($sp)
        lw      $t2, 8($sp)
        lw      $s0, 9($sp)
        lw      $s1, 10($sp)
        lw      $s2, 11($sp)
        lw      $sp, 12($sp)
        lw      $fp, 13($sp)
        lw      $ra, 14($sp)

        di

        lw $k0, 0($sp)
        addi $sp, $sp, 15

        reti

initsp: .fill 0xA000

ticks:  .fill 0xFFFF
maxval: .fill 0xFFE0
