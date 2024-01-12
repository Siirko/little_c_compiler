int main()
{
    // generate code with multiple if else imbricated
    if (1 < 2)
    {
        int c = 3;
        int d = 4;
        if (c == d)
        {
            printf("No");
        }
        else
        {
            printf("Hello ");
            int a = 1;
            int b = 2;
            if (a != b)
            {
                printf("World!\n");
            }
            else
            {
                printf("No");
            }
        }
    }
    else
    {
        printf("no");
    }
    printf("The end!\n");
    return 0;
}