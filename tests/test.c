int main()
{
    int zzz;
    int x = 1;
    int y = 2;
    int z = 3 + x + y;
    int a = z;
    for (int i = 0; i < 10; i++)
    {
        a = a + 1;
    }
    if (x > y)
    {
        x = 1 + x;
    }
    else
    {
        y = 1 + y;
    }
    return 2;
}