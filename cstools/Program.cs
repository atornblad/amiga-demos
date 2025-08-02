// Create a sine table for Amiga demos
// The sine has 256 steps
// The min/max of the values is -128 to 127

internal class Program
{
    private static void Main(string[] args)
    {
        EdgeSprites();
    }

    private static void EdgeSprites()
    {
        Random random = new(12345); // Fixed seed for reproducibility

        Console.WriteLine("; Edge sprites for Amiga demo");
        Console.WriteLine("; Each sprite is 16 pixels wide and 84 pixels tall");
        Console.WriteLine("; Three sprites on the left edge and three on the right edge");
        Console.WriteLine("; I might do a set of alternating sprite sets later...");
        Console.WriteLine("; ...but that can be solved by just making the sprites taller");
        Console.WriteLine();

        // Left edge sprites
        for (int l = 0; l < 3; ++l)
        {
            Console.WriteLine($"; Left edge sprite {l + 1}");
            Console.WriteLine($"p2edgespritel{l}:");
            int sprpos = 0x2c00 + l * 8 + 0x40;
            Console.WriteLine($"            dc.w    ${sprpos:x4}, $8000 ; Position words");
            for (int i = 0; i < 84; ++i)
            {
                if ((i & 7) == 0)
                {
                    Console.Write("            dc.w    ");
                }
                else
                {
                    Console.Write(", ");
                }
                // Random gradient from 100 % black left to 67 % black right for sprite 0,
                // 67 % black left to 33 % black right for sprite 1,
                // and 33 % black left to 0 % black right for sprite 2
                int row = 0;
                for (int x = 0; x <= 15; ++x)
                {
                    int blackness = 47 - (l * 16 + x); // 47 is fully black, 0 is fully white
                    if (random.Next(0, 48) < blackness)
                    {
                        row |= (0x8000 >> x);
                    }
                }
                Console.Write($"${row:x4}, $0000");
                if ((i & 7) == 7 || i == 83)
                {
                    Console.WriteLine();
                }
            }
            Console.WriteLine("            dc.w    $0000, $0000 ; Control words");
        }

        Console.WriteLine();
        Console.WriteLine();

    }

    private static void SineTable()
    {
        Console.WriteLine("; Sine table for Amiga demo");
        Console.WriteLine("; Values are scaled to fit in -128 to 127 range");
        Console.WriteLine("; Table contains 256 entries, each entry is a signed word (dc.w)");
        Console.WriteLine();
        for (int i = 0; i < 256; i++)
        {
            // Calculate the sine value
            double angle = i / 256.0 * (Math.PI * 2); // Convert to radians
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
        Console.WriteLine();
        Console.WriteLine();
    }
}