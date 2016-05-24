#W rdi przekazana jest liczba
#jesli ta liczba jest mniejsza od 0 to pobieram czas za pomoca samego rdtsc
#jesli ta liczba jest rowna 0 to czas pobieram za pomoca rdtscp
#jesli ta liczba jest wieksza od 0 dodatkowo wywoluje CPUID


.global takeclock
.type takeclock, @function
takeclock:
        movq $0, %rax
        cmpq %rdi, %rax #bede sprawdzal przekazany parametr z 0
        je WITH_RDTSCP  # = 0 -> rdtscp
        jg WITH_RDTSC   # < 0 -> rdtsc
        jmp WITH_CPUID  # > 0 -> cpuid + rdtsc

        WITH_RDTSCP:
        rdtscp
        jmp END

        WITH_CPUID:
        cpuid
        rdtsc
        jmp END

        WITH_RDTSC:
        rdtsc
        jmp END

        END:
        shlq $32, %rdx
        addq %rdx, %rax #rax = rax + rdx
        ret
