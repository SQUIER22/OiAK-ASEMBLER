.bss
.comm control, 2

.text
.global get_fpu
.type get_fpu, @function
get_fpu:
        fstcw control

        movl $0 ,%edx
        movw control(,%edx,2), %ax

        ret
