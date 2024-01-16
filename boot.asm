ORG 0
BITS 16

start:
	cli		; Clear Interrupts
	mov ax, 0x7c0
	mov ds, ax
	mov es, ax
	mov ax, 0x00
	mov ss, ax
	mov sp, 0x7c00
	sti		; Enables interrupts

	; AH = 02h
	; AL = number of sectors to read (must be nonzero)
	; CH = low eight bits of cylinder number
	; CL = sector number 1-63 (bits 0-5)
	; DH = head number
	; DL = drive number (bit 7 set for hard disk)
	; ES:BX -> data buffer

	mov ah, 2	; READ SECTOR COMMAND
	mov al, 1	; ONE SECTOR TO READ
	mov ch, 0	; CYLINDER LOW EIGHT BITS
	mov cl, 2	; READ SECTOR TWO
	mov dh, 0	; HEAD NUMBER
	mov bx, buffer
	int 0x13	; INVOKE THE INTERRUPT

	jc error

	mov si, buffer
	call print

	jmp $

error:
	mov si, error_message
	call print
	
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

error_message: db "Failed to load sector", 0

times 510-($ - $$) db 0
dw 0xAA55

buffer: