#include <stdio.h>

float f(float x);
float g(float x);

void set_fpu(int prec, int round);
int get_fpu();

int main() {
        set_fpu(0, 1);  //double prec, to nearest
        printf("DOUBLE PRECISION\n\n%X\nTo nearest:\n%f\n%f\n\n", get_fpu(), f(0.0078125), g(0.0078125));


        set_fpu(0, 2);  //double prec, down
        printf("Down:\n%X\n%f\n%f\n\n", get_fpu(), f(0.0078125), g(0.0078125));


        set_fpu(0, 3);  //double prec, up
        printf("Up:\n%X\n%f\n%f\n\n", get_fpu(), f(0.0078125), g(0.0078125));


        set_fpu(0, 4);  //double prec, to zero
        printf("To zero:\n%X\n%f\n%f\n\n", get_fpu(), f(0.0078125), g(0.0078125));


        set_fpu(1, 1);  //double prec, to nearest
        printf("SINGLE PRECISION\n\n%X\nTo nearest:\n%f\n%f\n\n", get_fpu(), f(0.0078125), g(0.0078125));


        set_fpu(0, 2);  //double prec, down
        printf("Down:\n%X\n%f\n%f\n\n", get_fpu(), f(0.0078125), g(0.0078125));


        set_fpu(0, 3);  //double prec, up
        printf("Up:\n%X\n%f\n%f\n\n", get_fpu(), f(0.0078125), g(0.0078125));


        set_fpu(0, 4);  //double prec, to zero
        printf("To zero:\n%X\n%f\n%f\n\n", get_fpu(), f(0.0078125), g(0.0078125));
        return 0;
}