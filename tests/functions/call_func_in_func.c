int test(int a)
{
    int res;
    res = a + 1;
    return res;
}

int loop(int a)
{
    int res;
    for (int i = 0; i < a; ++i)
    {
        res = a + i;
        // print(res);
    }
    int t;
    t = test(res);
    print(t);
    printf("\n");
    return res;
}

int double_it_for(int a)
{
    int res;
    res = loop(a);
    return res;
}

int main()
{
    int res;
    res = double_it_for(10);
    // res = loop(10);
    print(res);
    printf("\n");
    return 0;
}