## zeroDB for WoW 1.12

Current release: [zeroDB r1](https://github.com/minexew/zeroDB/archive/r1.zip)

What works:
- looking up items, monsters and NPCs
- viewing item details
- viewing dropped-by relationship between items and creatures

What doesn't (yet):
- other relationships (drops, sold-by, reagent-for, ...)
- other object types (spells, professions, locations, ...)

NOTE: For WoW standards, the AddOn is very memory hungry, as the entire database has to be held in memory all the time. However, this shouldn't cause issues on any semi-recent computer.

Memory usage optimization isn't high on the priority list, however performance (responsiveness) certainly is! If you run into any kind of lag when using zeroDB, please let me know.

## Installation

- download the [current release](https://github.com/minexew/zeroDB/archive/r1.zip)
- extract into ```World of Warcraft\Interface``` so that the resulting path is ```Interface\AddOns\zeroDB```
- that's it! no further configuration is required (or possible, for that matter)
- look for the zeroDB icon near your mini-map
