int doubleit(int a)
{
    int res;
    for (int i = 0; i < a; i++)
    {
        res = a + i;
    }
    return res;
}

int main()
{
    int res;
    res = doubleit(10);
    print(res);
    return 0;
}