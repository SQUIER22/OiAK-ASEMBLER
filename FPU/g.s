.bss
.comm result, 4
.comm input, 4

.data
one: .long 1

.text
.global g
.type g, @function
g:
        movss %xmm0, input

        flds input      #zaladowanie argumentu
        fmul input      #licznik = x^2

        flds input      #mianownik
        fmul input      #x^2
        fiadd one       #dodanie 1
        fsqrt           #pierwiastek
        fiadd one       #dodanie jedynki

        fdivr %st(1), %st(0)    #wykonanie dzielenia

        fstps result    #pobranie wyniku do pamieci
        movss result, %xmm0     #przeniesienie arg doo zwrocenia

        ret