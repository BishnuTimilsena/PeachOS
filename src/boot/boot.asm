ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start ;jump to the 'start' label to skip the padding bytes
    nop

 times 33 db 0 ; reserve 33 bytes for potential BIOS Parameter Block space

start:
    jmp 0:step2 ; this will make code egment start at 0x7c0

step2:
    cli ; clear interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; enables interrupts

.load_protected:  
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32
    
;GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code:     ;CS should point to this
    dw 0xffff ;Segment limit fist 0-15 bits
    dw 0      ; Base first 0-15 bits
    db 0      ; Base 16-32 bits
    db 0x9a   ;Acessed bits
    db 11001111b ; HIgh 4 bit flags and the low 4 bit flags
    db 0         ; Basse 24-31 bits

; offset 0x10
gdt_data:     ; DS, SSS, ES, FS, GS
    dw 0xffff ;Segment limit fist 0-15 bits
    dw 0      ; Base first 0-15 bits
    db 0      ; Base 16-32 bits
    db 0x92   ;Acessed bits
    db 11001111b ; HIgh 4 bit flags and the low 4 bit flags
    db 0         ; Basse 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1
    dd gdt_start

[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp
    
    ;Enable the A20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    jmp $

times 510-($ - $$) db 0
dw 0xAA55

