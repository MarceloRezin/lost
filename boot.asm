%define ORIGEM 0x7c00

org ORIGEM
bits 16

main:
	xor ax, ax
	mov ds, ax
	mov es, ax

	;pilha
	mov ss, ax
	mov sp, [ORIGEM]

clear_screen:
	mov al, 0x03
	int 0x10

print_str:
        mov ax, 0x1301
	mov bx, 0x02
	mov cx, pad-msg
	xor dx, dx
	mov bp, msg
	int 0x10

halt:
	;parada da CPU
	cli
	hlt

msg:
	db 'Carregando SO ...'

pad:
	times 510-($-$$) db 0

bios_sign:
	dw 0xaa55
