rin.img: rin.asm rin2016.data
	nasm -o rin.img rin.asm
	cat rin2016.data >> rin.img
	dd if=/dev/zero of=rin.img conv=notrunc count=2754 seek=126
