int func123(int a, int b)
{
    int tmp = a + b;
    return 2 + tmp;
}

int main()
{
    int a = 0;
    while (a < 54)
    {
        for (int i = 0; i < 10; i++)
        {
            a = a + 1;
        }
    }
    print(a);
    return a;
}
