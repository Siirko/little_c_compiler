int modbasic(int a, int b)
{
    int res;
    res = a;
    while (res >= b)
    {
        res = res - b;
    }
    return res;
}

float piconst()
{
    float res;
    // compute an approximation of pi
    for (int i = 0; i < 1000; i++)
    {
        int imod2 = 1;
        while (imod2 >= 2)
        {
            imod2 = imod2 - 2;
        }
        if (imod2 == 0)
        {
            res = res + 4.0 / (2.0 * i + 1.0);
        }
        else
        {
            res = res - 4.0 / (2.0 * i + 1.0);
        }
    }
    return res;
}
int main()
{
    float pi;
    pi = piconst();
    print(pi);
    return 0;
}
