int add(int a, int b) { return a + b; }
int add2() { return 2; }

int main()
{
    int a = 1;
    int b = 2;
    int c;
    c = add(1, 2, 3);
    c = add2(1);
    return c;
}