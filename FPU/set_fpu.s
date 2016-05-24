.bss
.comm control, 2

.data
p_single: .long 0xFCFF  #maska, wlacza pojedyncza precyzje
p_double_ex: .long 0x0300       #ustawia podwojna rozszerzona precyzje
r_nearest: .long 0xF3FF         #ustawia zaokraglanie do najblizszej
r_down_or: .long 0x0400         #ustawia zaokraglanie w dol
r_down_and: .long 0xF7FF
r_up_or: .long 0x0800           #ustawia zaokraglanie w gore
r_up_and: .long 0xFBFF
r_zero: .long 0x0C00            #ustawia zaokraglanie do zera


.text
.global set_fpu
.type set_fpu, @function

#########################################################
#       Funckja switch(int prec, int round)             #
#       przyjmuje dwa argumenty prec i round            #
#       argument prec ustawia zadana precyzje           #
#       natomiast argument round, typ zaokraglania      #
#                                                       #
#       prec = 0        ->      BRAK ZMIAN              #
#       prec = 1        ->      SINGLE PRECISION        #
#       prec = 2        ->      DOUBLE PRECISION        #
#                                                       #
#       round = 0       ->      BRAK ZMIAN              #
#       round = 1       ->      DO NAJBLIZSZEJ          #
#       rounf = 2       ->      W DOL                   #
#       round = 3       ->      W GORE                  #
#       round = 4       ->      DO ZERA                 #
#########################################################

set_fpu:
        pushq %rbp
        movq %rsp, %rbp         #ramka stosu

        fnstcw control          #wczytanie aktualnego stanu 'CONTROL WORLD'
                                #do pamieci

        #Parametry funckji znajduja sie kolejno w %rdi i %rsi
        cmp $1, %rdi    #sprawdzam jaka precyzje ustawic
        je SINGLE       #rdi == 1       ->      SINGLE
        jl CHECK_ROUND  #rdi == 0       ->      BRAK ZMIAN /sprawdz kolejny argument
        jg DOUBLE       #rdi == 2       ->      DOUBLE

        SINGLE:
                movl $0, %edx
                movw control(,%edx,2), %ax      #wczytanie 'CONTROL WORD' do ax
                movw p_single(,%edx,2), %cx     #wczytanie maski do cx
                andw %cx, %ax           #ustawienie pojedynczej precyzji
                movw %ax, control(,%edx,2)

                fldcw control   #zapisanie 'CW'
                jmp CHECK_ROUND

        DOUBLE:
                movl $0, %edx
                movw control(,%edx,2), %ax      #wczytanie 'CONTROL WORD' do ax
                movw p_double_ex(,%edx,2), %cx  #wczytanie maski do cx
                orw %cx, %ax            #ustawienie podwojnej precyzji
                movw %ax, control(,%edx,2)

                fldcw control   #zapisanie 'CW'
                jmp CHECK_ROUND

        CHECK_ROUND:
                cmp $1, %rsi    #sprawdzenie jaki tryp zaokraglania ustawic
                je NEAREST      #rsi == 1       ->      DO NAJBLIZSZEJ
                jl END          #rsi == 0       ->      BRAK ZMIAN /zakoncz
                jg CHECK_NEXT   #rsi >  1       ->      sprawdz pozostale przypadki

        CHECK_NEXT:
                cmp $3, %rsi
                je UP           #rsi == 3       ->      W GORE
                jl DOWN         #rsi == 2       ->      W DOL
                jg ZERO         #rsi == 4       ->      DO ZERA

        NEAREST:
                movl $0, %edx
                movw control(,%edx,2), %ax      #wczytanie 'CONTROL WORD' do ax
                movw r_nearest(,%edx,2), %cx    #wczytanie maski do cx
                andw %cx, %ax           #ustawienie zaokraglania w dol
                movw %ax, control(,%edx,2)

                fldcw control   #zapisanie 'CW'
                jmp END

        UP:
                movl $0, %edx
                movw control(,%edx,2), %ax      #wczytanie 'CONTROL WORD' do ax
                movw r_up_or(,%edx,2), %cx      #wczytanie maski do cx
                orw %cx, %ax            #ustawienie zaokraglania w gore
                movw r_up_and(,%edx,2), %cx
                andw %cx, %ax
                movw %ax, control(,%edx,2)

                fldcw control   #zapisanie 'CW'
                jmp END

        DOWN:
                movl $0, %edx
                movw control(,%edx,2), %ax      #wczytanie 'CONTROL WORD' do ax
                movw r_down_or(,%edx,2), %cx    #wczytanie maski do cx
                orw %cx, %ax            #ustawienie zaokraglania w dol
                movw r_down_and(,%edx,2), %cx
                andw %cx, %ax
                movw %ax, control(,%edx,2)

                fldcw control   #zapisanie 'CW'
                jmp END

        ZERO:
                movl $0, %edx
                movw control(,%edx,2), %ax      #wczytanie 'CONTROL WORD' do ax
                movw r_zero(,%edx,2), %cx       #wczytanie maski do cx
                orw %cx, %ax            #ustawienie zaokraglania do zera
                movw %ax, control(,%edx,2)

                fldcw control   #zapisanie 'CW'
                jmp END

        END:
                popq %rbp
                ret