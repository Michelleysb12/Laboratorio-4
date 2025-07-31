.data
# Mensajes del semáforo
msg_verde:      .asciiz "Semáforo en verde, esperando pulsador (presione 's')\n"
msg_pulsado:    .asciiz "Pulsador activado: en 20 segundos, el semáforo cambiará a amarillo\n"
msg_amarillo:   .asciiz "Semáforo en amarillo, en 10 segundos, semáforo en rojo\n"
msg_rojo:       .asciiz "Semáforo en rojo, en 30 segundos, semáforo en verde\n"
newline:        .asciiz "\n"

# Variables de estado
estado:         .word 0      # 0=verde, 1=espera_amarillo, 2=amarillo, 3=rojo
tiempo_inicio:  .word 0      # Tiempo de referencia para temporizador

.text
.globl main

main:
    # Inicialización
    li $v0, 4
    la $a0, msg_verde
    syscall
    
    # Obtener tiempo inicial
    li $v0, 30
    syscall
    sw $a0, tiempo_inicio
    
main_loop:
    # Verificar entrada de teclado
    li $v0, 11           # Verificar si hay entrada de teclado
    syscall
    beq $v0, 0, check_timer  # Si no hay entrada, verificar temporizador
    
    # Leer tecla
    li $v0, 12           # Leer carácter
    syscall
    
    # Verificar si es 's' y estamos en estado verde
    lw $t0, estado
    bne $t0, 0, check_timer  # Solo procesar 's' en estado verde
    bne $v0, 's', check_timer
    
    # Cambiar a estado "espera amarillo"
    li $t0, 1
    sw $t0, estado
    
    # Obtener nuevo tiempo de referencia
    li $v0, 30
    syscall
    sw $a0, tiempo_inicio
    
    # Mostrar mensaje
    li $v0, 4
    la $a0, msg_pulsado
    syscall
    
    j main_loop

check_timer:
    # Verificar temporizador según el estado actual
    lw $t0, estado
    beq $t0, 0, main_loop  # Estado verde - solo espera pulsador
    
    # Obtener tiempo actual
    li $v0, 30
    syscall
    lw $t1, tiempo_inicio
    sub $t2, $a0, $t1     # $t2 = tiempo transcurrido en ms
    
    # Dependiendo del estado, verificar diferentes tiempos
    beq $t0, 1, check_20_sec  # Espera amarillo - 20 segundos
    beq $t0, 2, check_10_sec  # Amarillo - 10 segundos
    beq $t0, 3, check_30_sec  # Rojo - 30 segundos
    
    j main_loop

check_20_sec:
    # Verificar si han pasado 20 segundos (20000 ms)
    blt $t2, 20000, main_loop
    
    # Cambiar a estado amarillo
    li $t0, 2
    sw $t0, estado
    
    # Reiniciar temporizador
    li $v0, 30
    syscall
    sw $a0, tiempo_inicio
    
    # Mostrar mensaje
    li $v0, 4
    la $a0, msg_amarillo
    syscall
    
    j main_loop

check_10_sec:
    # Verificar si han pasado 10 segundos (10000 ms)
    blt $t2, 10000, main_loop
    
    # Cambiar a estado rojo
    li $t0, 3
    sw $t0, estado
    
    # Reiniciar temporizador
    li $v0, 30
    syscall
    sw $a0, tiempo_inicio
    
    # Mostrar mensaje
    li $v0, 4
    la $a0, msg_rojo
    syscall
    
    j main_loop

check_30_sec:
    # Verificar si han pasado 30 segundos (30000 ms)
    blt $t2, 30000, main_loop
    
    # Volver a estado verde
    li $t0, 0
    sw $t0, estado
    
    # Reiniciar temporizador
    li $v0, 30
    syscall
    sw $a0, tiempo_inicio
    
    # Mostrar mensaje inicial
    li $v0, 4
    la $a0, msg_verde
    syscall
    
    j main_loop