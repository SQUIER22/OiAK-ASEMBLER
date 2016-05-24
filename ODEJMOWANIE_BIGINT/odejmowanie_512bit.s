.code32

SYS_EXIT = 1
WRITE = 4
READ = 3
EXIT_SUCC = 0
STDOUT = 1
STDIN = 0
BUFLEN = 128
BINLEN = 512


.section .data
formatstring:
.ascii "\nOdjemna:\t%X %X %X %X %X %X %X %X\nOdjemnik:\t%X %X %X %X %X %X %X %X\n\0"	#formatstring dla funkcji printf

testwynik:
.ascii "\nTest odejmowania z przeniesieniem: %X\n\0"

formatresult:
.ascii "\nWynik odejmowania:\t%X %X %X %X %X %X %X %X\n\0"

odjemna:
.long 0xFFFFFFFF, 0x98765432, 0x00030041, 0x12345679, 0x12120012, 0x0, 0xABCD9870, 0x123	#inter jako l.e. zeby miec b.e czytam od tylu
odjemnik:
.long 0xAAAAAAAA, 0x22222222, 0x99999999, 0xAAAAAAAA, 0x11111111, 0x9821, 0xA84905, 0x2784

wynik:
.long 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0	#miejscie na wynik

.section .text
.globl main 
main:
	movl $8, %edi	#jedna duza liczba sklada sie z 5 malych
	
	PUSHARGS:	#argumenty dla printfa
	decl %edi	#indeksujemy od zera
	pushl odjemnik(,%edi,4)	#ostatnie argumenty printf
	cmpl $0, %edi	#po wprowadzeniu 5 wywolaj printf
	je NEXT
	jmp PUSHARGS
	
	NEXT:
	movl $8, %edi

	PUSHNEXT:
	decl %edi
	pushl odjemna(,%edi,4)
	cmpl $0, %edi
	je CALLPRINTF
	jmp PUSHNEXT
	
	CALLPRINTF:
	pushl $formatstring	#pierwszy argument printf
	call printf
	

	#Operacja odejmowania odjemnika od odjemnej!
	#
	#Odjemna =	FFFFFFFF11111111AAAAAAAA9999999922222222
	#Odjemnik =	AAAAAAAA2222222299999999AAAAAAAA11111111
	#
	#Wynik =	55555554EEEEEEEF11111110EEEEEEEF11111111	

	#INIT
	movl $8, %edi	#wskaznik na najmlodsze 4 bajty
	movl $0, %edx	#rejestr edx bedzie sluzyl do zapamietania przeniesienia

	SUBTRACT:
	decl %edi	#kolejne 4 bajty
	movl odjemna(,%edi,4), %eax	#wczytanie odjemnej do eax
	movl odjemnik(,%edi,4), %ebx	#wczytanie odjemnika do ebx
	cmpl $1, %edx	#czy byla pozyczka
	je SONE		#jesli byla pozyczka z poprzedniej pozycji od odjemnej odejmij jeszcze jeden
	jmp CONTINUE

	SONE:
	subl %edx, %eax	#Odjecie pozyczonej jedynki
	jmp CONTINUE

	CONTINUE:
	subl %ebx, %eax	#eax = eax - ebx
	jc SAVECARRY
	movl $0, %edx	#wyzerowanie pozyczki i zapisanie wyniku
	jmp SAVERESULT

	SAVERESULT:
	movl %eax, wynik(,%edi,4)	#zapisanie wyniku odjecia
	cmpl $0, %edi	#sprawdzenie czy koniec	
	je END
	jmp SUBTRACT

	SAVECARRY:
	movl $1, %edx	#zapamietanie pozyczki
	jmp SAVERESULT

	END:
	movl $8, %edi

	PUSHRESULT:
	decl %edi
	pushl wynik(,%edi,4)
	cmpl $0, %edi
	je PRINT
	jmp PUSHRESULT

	PRINT:
	pushl $formatresult
	call printf
	

	pushl $0
	call exit
