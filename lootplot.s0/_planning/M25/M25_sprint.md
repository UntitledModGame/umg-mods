

## MID-2025 SPRINT:


- ~~Nerf boomerangs~~


- Make victory-shockwave cleaner, remove fade from it


- Muting SFX doesnt work (...?)


- Make wildcard shards cost $8 or $9


- Make shop smaller (at least, for one-ball)
==> 2 shop-slots, 1 food-slot


- Give shapes to treasure-bags
- Make food-treasure-bags have a vertical shape instead
- Make cloud-slots destroy other slots diagonally


- Lock starter items (except for tutorial-cat)
- Add unlocks for starter-items (win game)


- Make a starting-item that starts with rulebender-slot


- Rename steel-slots to "anti-bonus slots". Make them easier to get.
(They should do the exact same thing as before, except halve the current bonus)


- Make slots and items activate a bit separately:  
Michael didnt understand that the slots and items activated independently.  
Maybe we should buffer the activations of the items:  
Ie, activate slot, then activate item.  
(instead of both triggering at same time)   



- Get rid of start-game loading times
Everyone seems to get annoyed at the loading times.
Lets try remove the loading-times for worldgen as much as possible.
Also, when we trigger REROLL on items at start, lets just trigger it instantly. No need to use Bufferer.


- Create a more well-defined lose-condition:
- When a game is lost, dont allow player to "continue run"
- When a game is lost, dont allow player to recover the run through Rerolling. Lost is LOST!
- When a game is lost, tell the player: "Game over" text, similar to "You win" text?



- plan what items should be unlocked at the start of the game   
    --> rotate items should start locked  
    --> destructive-archetype should probably start locked too?  


- Add item unlock infrastructure
- Create "UNLOCKED" popup
- Make complex items locked at the start of the game



- Add credits screen (main menu?)
{
    Artist(s)
    Coders (Auahdark, skahd, myself)
    Playtesters
    Music
    SFX
}

