int main()
{
    int x = 1;
    float f;
    int a = 3;
    a = x * 3 + 5;
    if (x < a)
    {
        printf("Hi!");
        a = x * 3 + 100;
        if (x < a)
        {
            printf("Hi!");
            a = x * 3 + 100;
        }
        else
        {
            if (x < a)
            {
                x = 234;
            }
            else
            {
                x = -12;
            }
        }
    }
    else
    {
        if (x > a)
        {
            x = 234;
        }
        else
        {
            x = -12;
        }
    }
    int zzzzzzzzzzzz = 0;
    if (zzzzzzzzzzzz > 3)
    {
        zzzzzzzzzzzz = 3;
    }
    else
    {
        zzzzzzzzzzzz = 4;
    }
}