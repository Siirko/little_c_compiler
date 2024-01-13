int main()
{
    int a = 2;
    int i = 0;
    while (i < 10)
    {
        int j = 0;
        while (j < 10)
        {
            for (int k = 0; k < 10; k++)
            {
                a = a + 1;
            }
            j++;
        }
        i++;
    }
    print(a);
    return a - 1000;
}