int main()
{
    int e = 0;
    for (int i = 0; i < 5; i++)
    {
        while (i < 10)
        {
            e = e + 1;
            i++;
        }
    }
    print(e);
    return e;
}