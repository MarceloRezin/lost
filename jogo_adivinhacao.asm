;Jogo de advinhação
;Dado um número aleatório entre 1 e 100
;perguntar ao jogador qual o palpite
;ir respondendo alto de mais, baixo de mais ou acertou
;ao acertar, perguntar se quer jogar novamente, se sim, o pc reinicia -> Não fiz

%define ORIGEM 0x7c00
%define ENTER 0x0d

org ORIGEM
bits 16

start:
	xor ax, ax
	mov ds, ax
	mov es, ax

	;pilha
	mov ss, ax
	mov sp, [ORIGEM]

	jmp clear_screen

wait_func:
	mov ah, 0x86
	mov cx, 0x001e ;h word
	mov dx, 0x8480 ;l word
	int 0x15 ;wait int

clear_screen:
	mov ax, 0x0003
	int 0x10

	xor dx, dx

print_boas_vindas:
	mov ax, boas_vindas
	mov cx, introducao-boas_vindas
	call print_str

	jmp main

print_str:
	; recebe o inicio da string em AX
	; recebe o tamanho em CX

	push bp
	push bx
	push dx

	mov bp, ax
	mov ax, 0x1301
	mov bx, 0x02
	
	call query_cursor
	xor dl, dl ;Sempre do incio da linha atual
	int 0x10

	pop dx
	pop bx
	pop bp
	
	ret

inc_curson_p:
	push ax
	push bx
	push cx
	push dx

	call query_cursor

	;abaixa o cursor
	mov ah, 0x02
	xor dl, dl
	inc dh ;abaixa cursor
	int 0x10

	pop dx
	pop cx
	pop bx
	pop ax

	ret

query_cursor:
	;retorna em DX a posicao do cursor: DH row, DL, column
	push ax
	push bx
	push cx

	;recupera a posicao do cursor
	mov ah, 0x03
	xor bh, bh ;page 0
	int 0x10 ; depois disso, dh tem row dl tem column

	pop cx
	pop bx
	pop ax

	ret

rand_number:

	;retorna em dx o valor aleatório
	push ax
	push cx

	xor ax, ax
	xor dx, dx

	int 0x1a ;pega o system tick

	mov ax, dx

	xor dx, dx
	mov cx, 100
	div cx ; resto da divisao fica em dx

	inc dx ; 0 - 99 + 1 = 1 - 100

	pop cx
	pop ax

	ret

read_palpite:
	; le o papite digitado, aceita apenas números. TODO: backspce
	; retorna em dx o valor que foi lido

	push ax
	push bx
	push cx

	xor ax, ax
	mov ax, ENTER ;Usa o enter pra saber quando parar
	push ax

	; leitura do teclado
	; AL terá o ascii lido
.ler_teclado:
	xor ah, ah 
	int 0x16

	cmp al, ENTER
	;cmp al, 0x0d
	je .retorno

	;Ignora o que não for número
	cmp al, 0x39 ; > 9
	jg read_palpite
	
	cmp al, 0x30 ; < 0
	jl read_palpite

	mov ah, 0x0e
	mov bl, 0
	int 0x10

	xor ah, ah
	sub al, 0x30 ; ascii para digito
	push ax

	jmp .ler_teclado
.retorno:
	call processar_palpite

	pop cx
	pop bx
	pop ax

	ret

processar_palpite:
	;Calcula o palpite na pilha até encontrar o enter

	xor bx, bx
	xor dx, dx

.calcular_valor:

	pop cx
	pop ax

	push cx
	
	cmp ax, ENTER
	je .retorno
	
	mov cx, bx ; bx gurda a posição do digito
	push dx
	call expoente_base_10
	
	mul dx
	pop dx
	add dx, ax

	inc bx

	jmp .calcular_valor
.retorno:
	ret
	
expoente_base_10:
	; Expoente CX
	; Resultado DX
	
	push ax

	mov ax, 10
	mov dx, 1
.calculo:
	cmp cx, 0
	je .retorno
	
	mul dx;
	mov dx, ax
	
	dec cx
	jmp .calculo
	
.retorno:
	pop ax
	ret

main:
	call inc_curson_p

	mov ax, introducao
	mov cx, maior-introducao
	call print_str

	;start random
	call rand_number
	push dx ;DX tem o numero random 

.tentativa:
	call inc_curson_p

	call read_palpite

	call inc_curson_p

	mov ax, dx
	pop dx
	push dx ;devolve pra pilha o valor random obtido

	cmp ax, dx
	jg .maior
	jl .menor
	je .igual

.maior:
	mov ax, maior
	mov cx, menor-maior
	call print_str

	jmp .tentativa

.menor:
	mov ax, menor
	mov cx, igual-menor
	call print_str

	jmp .tentativa

.igual:
	mov ax, igual
	mov cx, pad-igual
	call print_str

	jmp halt

halt:
	;parada da CPU
	cli
	hlt

boas_vindas:
	db 'Bem vindo ao LOS/T ...'

introducao:
	db 'Este eh o jogo da advinhacao. Digite um palpipe entre 1 e 100:'

maior:
	db 'Seu palpite foi muito alto! Tente novamente:'

menor:
	db 'Seu palpite foi muito baixo! Tente novamente:'

igual:
	db 'Voce acertou!'

pad:
	times 510-($-$$) db 0

bios_sign:
	dw 0xaa55
