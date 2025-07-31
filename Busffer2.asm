.data
buffer:         .space 256        # Buffer de 256 bytes
buffer_size:    .word  256        # Tamaño del buffer
head:           .word  0          # Puntero de escritura
tail:           .word  0          # Puntero de lectura
time_msg:       .asciiz "\nTiempo completado. Contenido del buffer:\n"
newline:        .asciiz "\n"

.text
.globl main

main:
    # Inicialización
    la $s0, buffer        # $s0 = dirección del buffer
    lw $s1, buffer_size   # $s1 = tamaño del buffer
    sw $zero, head        # Inicializar head a 0
    sw $zero, tail        # Inicializar tail a 0
    
    # Configurar temporizador (simulado)
    li $v0, 30            # Syscall para obtener tiempo del sistema
    syscall
    move $s2, $a0         # $s2 = tiempo inicial (ms)
    li $s3, 20000         # $s3 = intervalo de tiempo (20,000 ms)

main_loop:
    # Verificar si ha pasado el tiempo
    li $v0, 30            # Obtener tiempo actual
    syscall
    sub $t0, $a0, $s2     # $t0 = tiempo transcurrido
    blt $t0, $s3, check_input  # Si no han pasado 20 seg, verificar entrada
    
    # Tiempo completado - imprimir buffer
    la $a0, time_msg
    li $v0, 4
    syscall
    
    jal print_buffer      # Imprimir contenido del buffer
    
    # Reiniciar buffer y temporizador
    sw $zero, head
    sw $zero, tail
    li $v0, 30           # Obtener nuevo tiempo de referencia
    syscall
    move $s2, $a0
    j main_loop

check_input:
    # Verificar si hay entrada disponible
    li $v0, 11           # Syscall para verificar entrada de teclado
    syscall
    beq $v0, $zero, main_loop  # Si no hay entrada, volver al bucle
    
    # Leer carácter
    li $v0, 12           # Syscall para leer carácter
    syscall
    move $t0, $v0        # $t0 = carácter leído
    
    # Almacenar en buffer circular
    lw $t1, head         # $t1 = índice head
    add $t2, $s0, $t1    # $t2 = dirección de buffer + head
    sb $t0, 0($t2)       # Almacenar carácter
    
    # Actualizar head (circular)
    addi $t1, $t1, 1     # Incrementar head
    blt $t1, $s1, no_wrap # Verificar si hay que ajustar
    li $t1, 0            # Volver al inicio del buffer
no_wrap:
    sw $t1, head         # Guardar nuevo valor de head
    
    j main_loop

print_buffer:
    # Imprimir contenido del buffer
    lw $t0, tail         # $t0 = tail (índice de lectura)
    lw $t1, head         # $t1 = head (índice de escritura)
    beq $t0, $t1, empty_buffer  # Si tail == head, buffer vacío
    
print_loop:
    # Obtener carácter
    add $t2, $s0, $t0    # $t2 = dirección de buffer + tail
    lb $a0, 0($t2)       # $a0 = carácter a imprimir
    
    # Imprimir carácter
    li $v0, 11
    syscall
    
    # Actualizar tail (circular)
    addi $t0, $t0, 1     # Incrementar tail
    blt $t0, $s1, no_wrap_tail # Verificar si hay que ajustar
    li $t0, 0            # Volver al inicio del buffer
no_wrap_tail:
    bne $t0, $t1, print_loop  # Continuar hasta tail == head
    
empty_buffer:
    # Imprimir nueva línea al final
    la $a0, newline
    li $v0, 4
    syscall
    
    jr $ra               # Retornar