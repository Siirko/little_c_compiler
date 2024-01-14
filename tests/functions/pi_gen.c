int mod_func(int a, int b)
{
    int res = 0;
    while (a >= b)
    {
        a = a - b;
    }
    return a;
}

float gen_pi(int iterations)
{
    float pi;
    for (int i = 0; i < iterations; i++)
    {
        int tmp = (2 * i + 1);
        float term;
        term = 1.0 / tmp;
        int mod = 0;
        mod = mod_func(i, 2);
        if (mod == 0)
        {
            pi = pi + term;
        }
        else
        {
            pi = pi - term;
        }
    }
    pi = pi * 4.0;
    return pi;
}
int main()
{
    int n = 3500;
    float res;
    res = gen_pi(n);
    print(res);
    return 0;
}