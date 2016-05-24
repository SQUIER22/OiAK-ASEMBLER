SYS_EXIT = 1
WRITE = 4
READ = 3
EXIT_SUCC = 0
STDOUT = 1
STDIN = 0
BUFLEN = 64     #ILOSC ZNAKOW MOZLIWYCH DO WCZYTANIA
BINSTRINGBUF = 256

.bss
.comm hexstring, 64     #64 BAJTY NA NAPIS REPREZENTUJACY LICZBE SZESNASTKOWA
.comm binstring, 256    #64*4 BAJTY NA REPREZENTACJE BINARNA TEJ LICZBY

.text
newline: .ascii "\n"
newline_len = . - newline

.global _start
_start:
        movl $READ, %eax
        movl $STDIN, %ebx
        movl $hexstring, %ecx
        movl $BUFLEN, %edx
        int $0x80               #WCZYTANIE LICZBY OD UZYTKOWNIKA

        movl $0, %ecx           #WYCZYSZCZENIE ECX
        movl %eax, %r8d         #ILOSC WPROWADZONYCH ZNAKOW
        decl %r8d               #BEZ OSTATNIEGO ZNAKU CR

        movl $0, %edi           #ITERATOR

        LOOP:
                movb hexstring(,%edi,1), %cl    #WCZYTANIE ZNAKU
                mov %cl, %bl
                add $0xC6, %bl          #SPRAWDZENIE ZNAKU

                jc CHAR                 #SKOK DO OPERACJI WYKONYWANYCH NA LITERACH A,B,C,D,E,F
                jmp NUMBER              #SKOK DO OPERACJI WYKONYWANYCH NA CYFRACH 1,2,3,4,5,6,7,8,9,0

        CHAR:           #OPERACJE WYKONYWANE NA LITERACH
                sub $0x37, %cl  #UZYSKANIE WARTOSCI BINARNEJ DANEGO ZNAKU
                jmp PRE_DO_BINSTRING

        NUMBER:
                sub $0x30, %cl  #UZYSKANIE WARTOSCI BINARNEJ DANEJ CYFRY
                jmp PRE_DO_BINSTRING

        PRE_DO_BINSTRING:
                shll $28, %ecx  #PRZESUNIECIE WARTOSCI ZNAKU NA KONIEC REJESTRU
                movl $0, %r9d   #NUMER PRZESUNIECIA

        DO_BINSTRING:
                incl %r9d
                movl %r8d, %eax #KTORY ZNAK DEKODUJEMY
                movl %edi, %ebx
                subl %ebx, %eax #NUMER ZNAKU KTORY JEST WLASNIE DEKODOWANY
                imull $4, %eax  #NUMER ZNAKU*ILOSC BITOW (JEDNA CYFRA SZESNASTKOWA KODOWANA JEST NA 4 BITACH)
                subl %r9d, %eax #WYLICZONA POZYCJA BITU
                movl %eax, %esi #ZAPISANIE ITERATORA
                #PRZESUWANY 4 RAZY PATRZAC NA FLAGE CARRY
                shll $1, %ecx   #NAJBARDZIEJ ZNACZACY BIT JEST TERAZ W FLADZE CARRY
                jc JEDYNKA      #ZAPISZEMY DO CIAGU JEDYNKE
                jmp ZERO        #ZAPISZEMY DO CIAGU ZERO

        JEDYNKA:
                movb $'1', binstring(,%esi,1)   #ZAPISANIE JEDYNKI
                movl %r9d, %eax
                cmpl $4, %eax	#SPRAWDZENIE WARUNKOW KONCA PETLI DO_BINSTRING
                je NEXT_CHAR
                jmp DO_BINSTRING
        ZERO:
                movb $'0', binstring(,%esi,1)   #ZAPISANIE ZERA
                movl %r9d, %eax
                cmpl $4, %eax
                je NEXT_CHAR
                jmp DO_BINSTRING

        NEXT_CHAR:	#WCZYTANIE KOLEJNEGO ZNAKU, INKREMENTACJA GLOWNEGO ITERATORA
                incl %edi
                movl %r8d, %eax
                movl %edi, %ebx
                cmpl %ebx, %eax		#SPRAWDZENIE WARUNKOW KONCA PETLI, CZY OSTATNI WCZYTANY ZNAK NIE BYL OSTATNIM ZNAKIEM CIAGU
                je BINSTRING_DONE
                jmp LOOP


        BINSTRING_DONE:		#WYPISANIE FORMY BINARNEJ DANEGO CIAGU LICZB SZESNASTKOWYCH
                movl $WRITE, %eax
                movl $STDOUT, %ebx
                movl $binstring, %ecx
                movl $BINSTRINGBUF, %edx
                int $0x80


                movl $WRITE, %eax
                movl $STDOUT, %ebx
                movl $newline, %ecx
                movl $newline_len, %edx
                int $0x80

        movl $SYS_EXIT, %eax
        movl $EXIT_SUCC, %ebx
        int $0x80

