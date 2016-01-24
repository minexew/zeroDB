## zeroDB for WoW 1.12

Current release: [zeroDB r2](https://github.com/minexew/zeroDB/releases/download/r2/zeroDB-r2.7z)

What works:
- looking up items, viewing item details
- item details: dropped by (creatures), reward from (quests)

What doesn't (yet):
- other relationships (sold by, reagent for, ...)
- other object types (spells, professions, locations, ...)

NOTE: For WoW standards, the AddOn is very memory hungry, as the entire database has to be held in RAM all the time. However, this shouldn't cause issues on any semi-recent computer.

Memory usage optimization isn't high on the priority list, however performance (responsiveness) certainly is! If you run into any kind of lag when using zeroDB, please let me know.

## Installation

- download the [current release](https://github.com/minexew/zeroDB/releases/download/r2/zeroDB-r2.7z)
- extract into ```World of Warcraft\Interface``` so that the resulting path is ```Interface\AddOns\zeroDB```
- that's it! no further configuration is required (or possible, for that matter)
- look for the zeroDB icon near your mini-map
