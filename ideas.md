# Blur 2x2
- Fyra bitplanes som alla pekar på samma minne, men:
- Bitplane 1: ingen förskjutning
- Bitplane 2: en pixel åt höger
- Bitplane 3: startar en vertikal rad senare
- Bitplane 4: en rad senare och en pixel åt höger
- Det borde gå att leka en del med färgerna, typ edge detection och liknande
- Ett femte bitplane kan också användas för att skapa färgeffekter, typ en overlay...

Undrar bara om det faktiskt blir en tillräckligt stor effekt. Edge detection skulle vara intressant, definitivt!

Färger som har 0 pixels, 0: Bakgrund
Färger som har en pixel, 1, 2, 4, 8: Antialias mellan kant och bakgrund
Färger som har två pixels, 3, 5, 6, 9, 10, 12: Kant (svart)
Färger som har tre pixels, 7, 11, 13, 14: Antialias mellan kant och fyllning
Färger som har fyra pixels, 15: Fyllning

