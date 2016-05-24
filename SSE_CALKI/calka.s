#########################################
# Funckja liczaca calke z funkcji:      #
# y = x^3 - 7x + 2                      #
# calka(dokladnosc, poczatek, koniec)   #
#########################################
.bss
# zmienne funkcji calka
.comm prec, 4
.comm begin, 4
.comm end, 4
.comm suma, 4
.comm _dx, 4


# zmienne funkcji f
.comm x, 4

# zmienne funkcji make_x
.comm xp, 4
.comm i, 4
.comm dx, 4

#zmienna do przetransportowania wyniku
.comm result, 4
.comm temp, 4

.data
seven: .long 7
two: .long 2

.text
.global calka

.type calka, @function
.type f, @function
.type make_x, @function

calka:
        pushq %rbp
        movq %rsp, %rbp
#################################################
# Do funkcji sa przekazywane 3 parametry        #
# Pierwszy arg to dokladnosc w %rsi             #
# Drugi to poczatek przedzialu calkowania %xmm0 #
# Trzeci to koniec przedzialu calkowania %xmm1  #
#################################################

#################################################
# Pierwszym krokiem algorytmu jest wyznaczenie  #
# szerokosci prostokata dx:                     #
# dx = (xk - xp)/n                              #
#################################################

        movq $0, %rsi
        movq %rdi, prec(,%rsi,4)#pobranie precyzji
        movss %xmm0, begin      #pobranie dolnej granicy
        movss %xmm1, end        #pobranie gornej granicy

        flds end        #xk
        fsub begin      #(xk - xp)
        fidiv prec      #((xk - xp)/n

        fstps _dx       #pobranie wyliczonego przedzialu

#################################################
# kolejnym krokiem algorytmu jest wyliczenie    #
# sumy wysokosci wszystkich prostokatow         #
# dla i = 1, 2,...,prec                         #
# suma += f(make_x(xp, i, dx))                  #
#################################################

        fldz    #zero do st(0) tutaj przechowuje sume wszystkich wysokosci

        PETLA:
                movss begin, %xmm0      #pierwszy argument dla make_x
                        #drugi argument jest w %rdi
                movss _dx, %xmm1        #trzeci argument

                call make_x

                # w %xmm0 jest wynik make_x i jest od razu pierwszym
                # argumentem f(x)

                call f

                # w %xmm0 jest teraz wysokosc jednego z prostokatow
                # teraz wystarczy dodac %xmm0 do sumy wszystkiego co jest w st(0)

                movss %xmm0, result

                fadd result     #dodanie na szczyt stosu wysokosci prostokata

                dec %rdi        #dekrementuje licznik
                cmp $0, %rdi    #jesli 0 to konczymy prace
                je END
                jmp PETLA

        END:    #w st(0) jest wysokosc wszystkich prostokatow
                #pomnoze teraz to wszystko przez szerokosc
                fmul _dx
                fstps result    #wynik calkowania
                movss result, %xmm0

                movq %rbp, %rsp
                popq %rbp
                ret




#########################################
# wylicza wysokosc danego prostokata    #
# potrzebne argumenty pobiera z         #
# rejestrow %xmm(0-1) oraz %rdi         #
# %xmm0 - dolna granica calkowania      #
# %rdi  - numer prostokata              #
# %xmm1 - szerokosc prostokata          #
# wynik zwraca w %xmm0                  #
#########################################
make_x:
        pushq %rbp      #ramka stosu
        movq %rsp, %rbp

        # pobranie argumentow
        movq %rdi, prec(,%rsi,4)
        movss %xmm0, xp
        movss %xmm1, dx

        fild prec       # i
        fmul dx # i*dx
        fadd xp # xp + i*dx

        fstps result
        movss result, %xmm0     #pobranie wyniku

        movq %rbp, %rsp         #porzadkowanie stosu
        popq %rbp
        ret



#################################################
# wylicza wartosc funkcji w danym punkcie       #
# wynik zwraca w %xmm0                          #
# argument przyjmuje z %xmm0                    #
#################################################
f:
        pushq %rbp
        movq %rsp, %rbp

        movss %xmm0, x  # pobranie argumentu

        flds x
        fmul x  #x^2
        fmul x  #x^3
        flds x
        fimul seven

        #w st(1) mam x^3 a w st(0) mam 7*x
        #od st(0) odejmuje st(1)

        fxch    #zamieniam st(0) z st(1)
        fsub %st(1)     #odejmuje od st(0) st(1)

        fiadd two       #dodaje dwojke
        fstps result    #pobranie wyniku
        fstps temp      #czyszcze stos ze smieci pozostawionych przez funkcje

        movss result, %xmm0     #wynik do %xmm0

        movq %rbp, %rsp
        popq %rbp
        ret