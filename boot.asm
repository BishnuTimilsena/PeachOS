ORG 0X7C00
BITS 16

start:
    mov si, message
    call print
    jmp $

print:
  mov bx, 0 ;Page number set to 0

.loop:
  lodsb
  cmp al, 0
  je .done
  call print_char
  jmp .loop

.done:
  ret
    
print_char:
  mov ah, 0eh
  int 0x10 ;display character on the screen
  ret

message: db 'Hello World!', 0

times 510-($ - $$) db 0
dw 0xAA55