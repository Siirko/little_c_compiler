int add(int a, int b) { return a + b; }

float addf(float a, float b) { return a + b; }

int main()
{
    int a = 1;
    int b = 2;
    int c;
    float d = 212.2;
    c = add(a, 23.1);
    d = addf(12, 3.4);
    print(c);
    printf("\n");
    print(d);
    return c;
}