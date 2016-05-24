#include <stdio.h>

long long unsigned int takeclock(int param);
float calka(int n, float xp, float xk);
float calka_simd(int n, float xp, float xk);

int main() {
        long long unsigned int time_calka_s = takeclock(1);
        float result_calka = calka(20480, 2, 5);
        long long unsigned int time_calka_e = takeclock(1);

        long long unsigned int time_calka_simd_s = takeclock(1);
        float result_calka_simd = calka_simd(20480, 2, 5);
        long long unsigned int time_calka_simd_e = takeclock(1);


        long long unsigned int time_calka = time_calka_e - time_calka_s;
        long long unsigned int time_calka_simd = time_calka_simd_e - time_calka_simd_s;


        printf("WYNIK CALKA FPU:\t%f\tCZAS:\t%llu\n", result_calka, time_calka);
        printf("WYNIK CALKA SSE:\t%f\tCZAS:\t%llu\n", result_calka_simd, time_calka_simd);

        return 0;
}
