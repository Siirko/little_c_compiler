int add(int a, int b) { return a + b; }

float addf(float a, float b) { return a + b; }

int main()
{
    int a = 1;
    int b = 2;
    int c;
    float d;
    c = add(a, b);
    d = addf(1.2, 3.4);
    print(c);
    printf("\n");
    print(d);
    return c;
}