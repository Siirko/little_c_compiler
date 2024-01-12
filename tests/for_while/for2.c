int main()
{
    int zzz;
    for (int i = 0; i < 10; i++)
    {
        for (int j = 0; j < 10; j++)
        {
            zzz = zzz + 1;
        }
        for (int k = 0; k < 10; k++)
        {
            zzz = zzz + 1;
        }
        for (int l = 0; l < 10; l++)
        {
            zzz = zzz + 1;
        }
    }
    printf("%d\n", zzz);
    return zzz;
}