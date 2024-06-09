ASM_FILE=boot.asm
#ASM_FILE=jogo_adivinhacao.asm

make:
	nasm $(ASM_FILE) -f bin -o boot.bin
	cp boot.bin boot.img
	truncate -s 1440k boot.img

run:
	qemu-system-i386 -drive file=boot.img,format=raw,index=0,if=floppy
