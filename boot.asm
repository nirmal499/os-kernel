ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start		; CODE_SEG becomes 0x8
DATA_SEG equ gdt_data - gdt_start		; DATA_SEG becomes 0x16

jmp 0:start		; This will make our code segment 0x0

start:
	cli		; Clear Interrupts
	mov ax, 0x00
	mov ds, ax
	mov es, ax
	mov ax, 0x00
	mov ss, ax
	mov sp, 0x7c00
	sti		; Enables interrupts

.load_protected:
	cli
	lgdt [gdt_descriptor]
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax

	jmp CODE_SEG:load32		; CS becomes 0x08

; GDT
gdt_start:
gdt_null:
	dd 0x0
	dd 0x0

; Offset 0x8
gdt_code:			; CS SHOULD POINT TO THIS
	dw 0xffff		; Segment limit first 0-15 bits
	dw 0			; Base first 0-15 bits
	db 0 			; Base 16-23 bits
	db 0x9a			; Access byte
	db 11001111b	; High 4 bit flags and the low 4 bit flags
	db 0			; Base 24-31 bits

; Offset 0x16
gdt_data:			; DS, SS, ES, FS, GS SHOULD POINT TO THIS
	dw 0xffff		; Segment limit first 0-15 bits
	dw 0			; Base first 0-15 bits
	db 0 			; Base 16-23 bits
	db 0x92			; Access byte
	db 11001111b	; High 4 bit flags and the low 4 bit flags
	db 0			; Base 24-31 bits

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
	mov ebp, 0x00200000			; ebp is 32-bit register. In hex each digit takes 4 bits
	mov esp, ebp

	jmp $

print:
	mov bx, 0
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
	int 0x10
	ret

times 510-($ - $$) db 0
dw 0xAA55