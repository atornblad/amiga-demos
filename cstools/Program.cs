// See https://aka.ms/new-console-template for more information

// Create a sine table for Amiga demos
// The sine has 256 steps
// The min/max of the values is -128 to 127

for (int i = 0; i < 256; i++)
{
    // Calculate the sine value
    double angle = (i / 256.0) * (Math.PI * 2); // Convert to radians
    double sineValue = Math.Sin(angle);

    // Scale to -128 to 127
    int scaledValue = (int)(sineValue * 127);

    if ((i & 15) == 0)
    {
        Console.Write("            dc.w    ");
    }
    else
    {
        Console.Write(", ");
    }
    Console.Write($"{scaledValue}");
    if ((i & 15) == 15)
    {
        Console.WriteLine();
    }
}
