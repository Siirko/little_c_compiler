
int add(int a, int b, int c) { return a + b + c * 2.02; }
float addf(float a, float b, float c) { return a * b + c * 1.01; }

int main()
{
    int a;
    int b = 2;
    float f = 23.3;
    a = add(2 + 2, 3, 2 * f + 1);
    f = addf(1.3, 1.2, 1.1);
    print(a);
    printf("\n\n");
    print(f);
    printf("\n\n");
    float f = 2.3;
    float ttt = f;
    int testFLOAT = f;
    int za = 4;
    testFLOAT = f * 3.2 + 54.2 + za;
    print(testFLOAT);
    printf("\n\n");
    int i = 2;
    int fd = 0;
    i = 10 + 5;
    f = f + 5.2 * 2 * 2.1 * f * 1.01;
    print(f);
    printf("\n\n");
    testFLOAT = testFLOAT + 5 * 2;
    print(testFLOAT);
    printf("\n\n");
    return 0;
}