int double_it_for(int a)
{
    int res;
    for (int i = 0; i <= a; i++)
    {
        res = a + i;
    }
    return res;
}

int double_it_while(int a)
{
    int res;
    int i = 0;
    while (i <= a)
    {
        res = a + i;
        i++;
    }
    return res;
}

int decrease_it_for(int a)
{
    int res;
    for (int i = a; i >= 0; i--)
    {
        res = res - i;
    }
    return res;
}

int main()
{
    int res;
    res = double_it_for(10);
    print(res);
    printf("\n");
    res = double_it_while(10);
    print(res);
    printf("\n");
    res = decrease_it_for(10);
    print(res);
    printf("\n");
    return 0;
}