// Create a sine table for Amiga demos
// The sine has 256 steps
// The min/max of the values is -128 to 127

internal class Program
{
    private static void Main(string[] args)
    {
        SineTable();
    }

    private static void SineTable()
    {
        Console.WriteLine("; Sine table for Amiga demo");
        Console.WriteLine("; Values are scaled to fit in -15 to 15 range");
        Console.WriteLine("; Table contains 256 entries, each entry is a signed word (dc.w)");
        Console.WriteLine();
        for (int i = 0; i < 256; i++)
        {
            // Calculate the sine value
            double angle = i / 256.0 * (Math.PI * 2); // Convert to radians
            double sineValue = Math.Sin(angle);

            // Scale to -128 to 127
            int scaledValue = (int)(sineValue * 15);

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
        Console.WriteLine();
        Console.WriteLine();
    }
}