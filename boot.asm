; created own interrupt
ORG 0
BITS 16

_start:
    jmp short start ;jump to the 'start' label to skip the padding bytes
    nop

 times 33 db 0 ; reserve 33 bytes for potential BIOS Parameter Block space

start:
    jmp 0x7c0: step2 ; this will make code egment start at 0x7c0

step2:
    cli ; clear interrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti ; enables interrupts

    mov ah, 2 ; read sector command
    mov al, 1 ; one sector to read
    mov ch, 0 ; cylinder low 8 bits
    mov cl, 2 ; read sector 2
    mov dh, 0 ; head number
    mov bx, buffer
    int 0x13 ; invoke the read command
    jc error

    mov si, buffer
    call print

    jmp $

error:
      mov si, error_message
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

error_message: db 'Failed to load setcor', 0

times 510-($ - $$) db 0
dw 0xAA55

buffer: 