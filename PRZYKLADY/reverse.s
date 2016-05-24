SYSEXIT= 1      #zakonczenie programu
SYSREAD= 3      #czytanie
SYSWRITE= 4     #wypisywanie
STDOUT= 1       #standardowe wyjscie
STDIN= 0        #standardowe wejscie
EXIT_SUCCESS= 0 #program zakonczyl sie sukcesem
BUFLEN= 512     #dlugosc bufora tekstowego

.bss
.comm text, 512

.text
newline: .ascii "\n"
newline_len = . - newline


.global _start
_start:
        movl $SYSREAD, %eax     #wczytanie tekstu od uzytkownika
        movl $STDIN, %ebx
        movl $text, %ecx
        movl $BUFLEN, %edx
        int $0x80

        #inicjalizacja potrzebnych zmiennych
        mov $0, %edi    #licznik "od przodu"
        mov %eax, %edx  #ilosc wprowadzonych znakow
        dec %edx        #po odjeciu 1 staje sie licznikiem "od konca"
        jmp loop        #wejscie do petli odwracajacej napis

        loop:
                movb text(,%edi,1), %al #wczytywanie znakow od poczatku
                movb text(,%edx,1), %ah #wczytywanie znakow od konca
                movb %al, text(,%edx,1) #zamiana
                movb %ah, text(,%edi,1)
                inc %edi

                cmp %edx, %edi  #warunek konca: jesli wskaznik na poczatek bedzie rowny badz wiekszy niz wskaznik na koniec -> koniec
        jge end #napis odwrocony
                dec %edx        #zmniejszenie licznika konca
        jmp loop        #powtorzenie operacji

        end:
        movl $SYSWRITE, %eax    #wypisanie odwroconego napisu
        movl $STDOUT, %ebx
        movl $text, %ecx
        movl $BUFLEN, %edx
        int $0x80

        movl $SYSWRITE, %eax    #dodrukowanie znaku nowej linii dla lepszej czytelnosci
        movl $STDOUT, %ebx
        movl $newline, %ecx
        movl $newline_len, %edx
        int $0x80

        movl $SYSEXIT, %eax     #zakonczenie dzialania programu
        movl $EXIT_SUCCESS, %ebx
        int $0x80

