// Create a sine table for Amiga demos
// The sine has 256 steps
// The min/max of the values is -128 to 127

using System.Buffers.Binary;

internal class Program
{
    private static void Main(string[] args)
    {
        //SineTable();
        TanhTable();
        //FfpToString();
        //IeeeToString();
    }

    private static void TanhTable()
    {
        Console.WriteLine("; Tanh table for audio mixing");
        Console.WriteLine("; Values are scaled to fit in -128 to 127 range");
        Console.WriteLine("; Table contains 1024 entries, to allow mixing of four 8-bit samples");
        Console.WriteLine();
        for (int i = 0, j = -512; i < 1024; i++, j++)
        {
            // Calculate the tanh value
            double tanhValue = Math.Tanh(j / 128.0);

            // Scale to -128 to 127
            int scaledValue = (int)(tanhValue * 127.5);

            if ((i & 15) == 0)
            {
                Console.Write("            dc.b    ");
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
    }

    private static void IeeeToString()
    {
        while (true)
        {
            Console.WriteLine("; IEEE float to string conversion table");
            string ieeeHex = Console.ReadLine() ?? string.Empty;
            ieeeHex = ieeeHex.Trim();
            if (ieeeHex.Length != 16)
            {
                return;
            }
            Console.WriteLine("; Input Amiga IEEE hex: " + ieeeHex);
            ulong ieeeValue = Convert.ToUInt64(ieeeHex, 16);
            byte[] bytes = BitConverter.GetBytes(ieeeValue);
            double floatValue = BitConverter.ToDouble(bytes, 0);
            Console.WriteLine("; Converted string value: " + floatValue.ToString("F6"));
        }
    }

    private static void FfpToString()
    {
        while (true)
        {
            Console.WriteLine("; Fixed-point format to string conversion table");
            string ffpHex = Console.ReadLine() ?? string.Empty;
            ffpHex = ffpHex.Trim();
            if (ffpHex.Length != 8)
            {
                return;
            }
            Console.WriteLine("; Input fixed-point hex: " + ffpHex);
            // Amiga FFP has 24 mantissa bits, 1 sign bit and 7 exponent bits
            uint ffpValue = Convert.ToUInt32(ffpHex, 16);
            if (ffpValue == 0L)
            {
                Console.WriteLine("; Converted string value: 0.000000");
                continue;
            }
            uint mantissa = (ffpValue & 0xffffff00) >> 8;
            Console.WriteLine("; Extracted mantissa: " + mantissa.ToString("X6"));
            double mantissaValue = mantissa / (double)(1 << 24);
            Console.WriteLine("; Mantissa as float: " + mantissaValue.ToString("F6"));
            bool signBit = (ffpValue & 0x00000080) != 0;
            Console.WriteLine("; Sign bit: " + (signBit ? "1 (negative)" : "0 (positive)"));
            int exponent = (int)(ffpValue & 0x7f) - 64;
            Console.WriteLine("; Exponent (after bias adjustment): " + exponent);
            double floatValue = mantissaValue * Math.Pow(2, exponent);

            if (signBit)
            {
                floatValue = -floatValue;
            }
            string result = floatValue.ToString("F6");
            Console.WriteLine("; Converted string value: " + result);
        }
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