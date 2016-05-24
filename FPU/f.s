.bss
.comm result, 4
.comm arg, 4

.data
one: .long 1

.text
.global f
.type f, @function
f:
        movss %xmm0, arg

        flds arg
        flds arg
        fmul %st(0), %st(0)     #x^2    w st(1)
        fiadd one               #dodanie jedynki
        fsqrt
        fisub one

        fstps result
        movss result, %xmm0     #wynik do xmm0

        ret
