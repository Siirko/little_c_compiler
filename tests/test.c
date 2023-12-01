int main()
{
    int x = 1;
    float f, g;
    int a = 3;
    int x;
    a = x * 3 + 5;
    if (x > a)
    {
        for (int i = 0; i < 10; i++)
        {
            printf("Hi!");
            a = x * 12;
        }
        printf("Hi!");
        a = x * 3 + 100;
        if (x > a)
        {
            printf("Hi!");
            a = x * 3 + 100;
        }
        else
        {
            x = a * 3 + 100;
        }
    }
    else
    {
        x = a * 3 + 98;
    }
}