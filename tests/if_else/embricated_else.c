int main()
{
    // generate code with multiple if else imbricated
    int a = 1;
    int b = 2;
    if (a > b)
    {
        printf("not here\n");
    }
    else
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
    printf("The end!\n");
    return 0;
}