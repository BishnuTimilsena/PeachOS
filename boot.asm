; created own interrupt
ORG 0
BITS 16
_start:
    jmp short start ;jump to the 'start' label to skip the padding bytes
    nop

 times 33 db 0 ; reserve 33 bytes for potential BIOS Parameter Block space


start:
    jmp 0x7c0: step2 ; this will make code egment start at 0x7c0

handle_zero:
    mov ah, 0eh
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret ;interrupt finished

handle_one:
     mov ah, 0eh
     mov al, 'V'
     mov bx, 0x00
     int 0x10
     iret

step2:
    cli ; clear interrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti ; enables interrupts

    mov word[ss:0x00], handle_zero
    mov word[ss:0x02], 0x7c0
    
    ;mov ax, 0x00
    ;div ax

    mov word[ss:0x04], handle_one
    mov word[ss:0x06], 0x7c0

    int 1

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
  int 0x10 ; BIOS interrupt to display character in AL
  ret

message: db 'Hello World!', 0

times 510-($ - $$) db 0
dw 0xAA55