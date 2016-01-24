
ALL_CLASSES = 0b10111011111

character_classes = {
    0: 'Warrior',
    1: 'Paladin',
    2: 'Hunter',
    3: 'Rogue',
    4: 'Priest',
    5: 'Death Knight',
    6: 'Shaman',
    7: 'Mage',
    8: 'Warlock',
    9: 'Monk',
    10: 'Druid',
}

creature_types = {
    1: 'Beast',
    2: 'Dragonkin',
    3: 'Demon',
    4: 'Elemental',
    5: 'Giant',
    6: 'Undead',
    7: 'Humanoid',
    8: 'Critter',
    9: 'Mechanical',
    10: 'Not specified',
    11: 'Totem',
}

creature_ranks = {
    1: 'Elite',
    2: 'Rare Elite',
    3: 'World Boss',
    4: 'Rare',
}

# http://docs.getmangos.com/en/latest/database/world/item-template.html

item_classes = {
    0: 'Consumable',
    1: 'Container',
    2: 'Weapon',
    4: 'Armor',
    5: 'Reagent',
    6: 'Projectile',
    7: 'Trade Goods',
    9: 'Recipe',
    11: 'Quiver',
    12: 'Quest Item',
    13: 'Key',
    15: 'Miscellaneous',
}

item_slots = {
    1: 'Head',
    2: 'Neck',
    3: 'Shoulder',
    4: 'Shirt',
    5: 'Chest',
    6: 'Waist',
    7: 'Legs',
    8: 'Feet',
    9: 'Wrist',
    10: 'Hands',
    11: 'Finger',
    12: 'Trinket',
    13: 'One-hand',
    14: 'Off-hand',
    15: 'Ranged',
    16: 'Back',
    17: 'Two-hand',
    19: 'Tabard',
    20: 'Chest',
    21: 'Main Hand',
    22: 'Off-hand',
    23: 'Held in Off-hand',
    24: 'Projectile',
    25: 'Thrown',
    26: 'Ranged',
    26: 'Relic',
}

item_subclasses = {
    1: {
        0: 'Bag',
        1: 'Soul bag',
        2: 'Herb bag',
        3: 'Enchanting bag',
        4: 'Engineering bag',
    },
    2: {
        0: 'Axe (1H)',
        1: 'Axe (2H)',
        2: 'Bow',
        3: 'Gun',
        4: 'Mace (1H)',
        5: 'Mace (2H)',
        6: 'Polearm',
        7: 'Sword (1H)',
        8: 'Sword (2H)',
        10: 'Staff',
        13: 'Fist weapon',
        14: 'Miscellaneous',
        15: 'Dagger',
        16: 'Thrown',
        17: 'Spear',
        18: 'Crossbow',
        19: 'Wand',
        20: 'Fishing pole',
    },
    4: {
        0: 'Miscellaneous',
        1: 'Cloth',
        2: 'Leather',
        3: 'Mail',
        4: 'Plate',
        5: 'Buckler',
        6: 'Shield',
        7: 'Libram',
        8: 'Idol',
        9: 'Totem',
    },
    6: {
        2: 'Arrow',
        3: 'Bullet',
    },
    7: {
        1: 'Parts',
        2: 'Explosives',
        3: 'Devices',
    },
    9: {
        0: 'Book',
        1: 'Leatherworking',
        2: 'Tailoring',
        3: 'Engineering',
        4: 'Blacksmithing',
        5: 'Cooking',
        6: 'Alchemy',
        7: 'First aid',
        8: 'Enchanting',
        9: 'Fishing',
    },
    11: {
        2: 'Quiver',
        3: 'Ammo pouch',
    },
    13: {
        1: 'Lockpick',
    },
}

item_qualities = {
    0: ['Poor', 'Grey'],
    1: ['Common', 'White'],
    2: ['Uncommon', 'Green'],
    3: ['Rare', 'Blue'],
    4: ['Epic', 'Purple'],
    5: ['Legendary', 'Orange'],
    6: ['Artiface', 'Red'],
}
