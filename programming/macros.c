#include<stdio.h>
#define CUBE(x) (x*x*x)

main() {
    int b = 3, a = 0;
    a = CUBE(b++);

    printf("%d %d\n", a, b);
}
