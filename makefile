all:
	gcc -g CRT.s -o CRT.out;
	gdb CRT.out

compile:
	gcc -g CRT.s -o CRT.out;

clean:
	rm CRT.out

debug:
	gdb CRT.out

children:
	touch childrem
	rm children
