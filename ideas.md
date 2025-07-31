# Blur 2x2
- Fyra bitplanes som alla pekar på samma minne, men:
- Bitplane 1: ingen förskjutning
- Bitplane 2: en pixel åt höger
- Bitplane 3: startar en vertikal rad senare
- Bitplane 4: en rad senare och en pixel åt höger
- Det borde gå att leka en del med färgerna, typ edge detection och liknande
- Om minnet som används är en tredjedel av vyns bredd, borde man kunna använda ett femte bitplane simulera en "tik tok"-effekt med ett fält i mitten som är skarpt (pga bara ettor i mitten-tredjedelen i bitplane 5)
- Ett femte bitplane kan också användas för att skapa färgeffekter, typ en overlay...

Undrar bara om det faktiskt blir en tillräckligt stor effekt. Edge detection skulle vara intressant, definitivt!

