#!/usr/bin/env python3

import json, math, sys

import mysql.connector
from mysql.connector import errorcode

from game_tables import *

print('zeroDB process_db.py')
print()

if len(sys.argv) < 4:
    print('usage: process_db.py <username> <password> <output directory>')
    sys.exit()

USER = sys.argv[1]
PASS = sys.argv[2]
OUTPUT_PREFIX = sys.argv[3] + '/'

MANGOS_DB = 'mangos'
AOWOW_DB = 'aowow'

MANGOS_PREFIX = MANGOS_DB + '.'
AOWOW_PREFIX = AOWOW_DB + '.aowow_'

ITEMS_BASE = 0
CREATURES_BASE = 1000000
QUESTS_BASE = 2000000

class Keywords:
    def __init__(self):
        self.keywords = {}

    def add(self, keywords, ref):
        for k in keywords:
            if not k: continue

            if not k in self.keywords:
                self.keywords[k] = []

            if not ref in self.keywords[k]:
                self.keywords[k].append(ref)

    def write(self):
        with open('keywords.lua.in', 'rt') as header_file:
            header = header_file.read()

        with open(OUTPUT_PREFIX + 'keywords.lua', 'wt') as output_file:
            output_file.write(header)
            print("zeroDB.db.keywords = {", file=output_file)

            print('writing keywords...')

            for c in range(0, 26):
                print('    {', file=output_file)

                for k, v in self.keywords.items():
                    if k[0] == chr(ord('a') + c):
                        print('        [%s] = {%s},' % (json.dumps(k), ', '.join(map(lambda s: json.dumps(s), v))), file=output_file)

                print('    },', file=output_file)

            print("}", file=output_file)

#class SmartObject:
#    def __init__(self, name, fields):
#        self.name = name
#        self.fields = sort(fields)

class Processor:
    def __init__(self, cnx):
        self.cnx = cnx
        self.keywords = Keywords()
        self.reward_from = {}

    def add_quest_rewards(self, quest_id, *items):
        for item_id in items:
            if not item_id: continue
            if not item_id in self.reward_from: self.reward_from[item_id] = []

            self.reward_from[item_id].append(quest_id)

    def open_with_header(self, path):
        with open(path + '.in', 'rt') as header_file:
            header = header_file.read()

        output_file = open(OUTPUT_PREFIX + path, 'wt')
        output_file.write(header)
        return output_file

    def process_items(self):
        print('processing items...', end='', flush=True)

        with self.open_with_header('items.lua') as out:
            dump_table('zeroDB.db.item_classes', item_classes, out)
            dump_table('zeroDB.db.item_subclasses', item_subclasses, out)
            dump_table('zeroDB.db.item_slots', item_slots, out)

            cursor = self.cnx.cursor()
            query = ("SELECT entry, class, subclass, name, quality, inventorytype, allowableclass, itemlevel, requiredlevel, " +
                "requiredskillrank, iconname FROM %sitem_template AS it " +
                "LEFT JOIN %sicons AS icn ON it.displayid = icn.id ORDER by it.entry ASC") % (MANGOS_PREFIX, AOWOW_PREFIX)
            cursor.execute(query)

            print("zeroDB.db.items = {", file=out)

            count = 0

            for (entry, class_, subclass, name, quality, slot, allowableclass, itemlevel, requiredlevel,
                    required_skill_level, iconname) in cursor:
                keywords = [''] + name.split(' ')

                if allowableclass == -1 or (allowableclass & ALL_CLASSES) == ALL_CLASSES:
                    classes = 'nil'
                else:
                    classes = '{' + ', '.join(['true' if allowableclass & (1 << i) else 'false' for i, _ in character_classes.items()]) + '}'

                    for i, n in character_classes.items():
                        if allowableclass & (1 << i):
                            keywords.append(n)

                if quality in item_qualities:
                    keywords += item_qualities[quality]

                if class_ in item_classes:
                    keywords.append(item_classes[class_])

                    if class_ in item_subclasses and subclass in item_subclasses[class_]:
                        keywords.append(item_subclasses[class_][subclass])

                if slot in item_slots:
                    keywords.append(item_slots[slot])

                keywords = list(set(map(lambda s: s.lower(), keywords)))
                keywords_str = '|'.join(keywords)

                print(("    [%5d] = {type = 'item', id = %5d, name = %s, keywords = %s, quality = %d, slot = %d, classes = %s, " +
                        "itemlevel = %d, requiredlevel = %d, required_skill_level = %d, class = %d, subclass = %d, icon = %s},") % (
                        entry, entry, json.dumps(name), json.dumps(keywords_str), quality, slot, classes, itemlevel, requiredlevel,
                        required_skill_level, class_, subclass, json.dumps(iconname.strip())), file=out)
                self.keywords.add(keywords, ITEMS_BASE + entry)
                count += 1

            cursor.close()
            print("}", file=out)

            print(count, 'entries')

            # DROPPED BY
            items_dropped_by = {}

            print('processing creature loot (dropped-by)...', end='', flush=True)

            cursor = self.cnx.cursor()
            query = ("SELECT item, entry, chanceorquestchance FROM %screature_loot_template WHERE mincountorref > 0") % (MANGOS_PREFIX)
            cursor.execute(query)

            for item, entry, chance in cursor:
                if not item or not entry:
                    print('Warning: spurious creature loot', item, entry, chance, '?')
                    continue

                if not item in items_dropped_by: items_dropped_by[item] = []
                items_dropped_by[item].append((entry, abs(chance)))

            cursor.close()

            cursor = self.cnx.cursor()
            query = ("SELECT rlt.item, clt.entry, clt.chanceorquestchance FROM %sreference_loot_template AS rlt " +
                    "LEFT JOIN %screature_loot_template AS clt ON clt.mincountorref = -rlt.entry") % (MANGOS_PREFIX, MANGOS_PREFIX)
            cursor.execute(query)

            for item, entry, chance in cursor:
                if not item or not entry:
                    print('Warning: spurious reference loot', item, entry, chance, '?')
                    continue

                if not item in items_dropped_by: items_dropped_by[item] = []
                items_dropped_by[item].append((entry, -1))

            cursor.close()

            print(file=out)
            print("zeroDB.db.items_dropped_by = {", file=out)

            count = 0

            for item, drops in items_dropped_by.items():
                drops.sort(key=lambda tup: abs(tup[1]), reverse=True)

                print("    [%5d] = {%s}," % (item,
                    ', '.join(["%d, %.2f" % (drop[0], drop[1]) for drop in drops])),
                    file=out)
                count += 1

            print("}", file=out)

            print(count, 'entries')

            # REWARD FROM

            print('processing quest rewards (reward-from)...', end='', flush=True)

            print(file=out)
            print("zeroDB.db.items_reward_from = {", file=out)

            count = 0

            for item, quests in self.reward_from.items():
                print("    [%5d] = {%s}," % (item, ', '.join(["%d" % quest_id for quest_id in quests])), file=out)
                count += 1

            cursor.close()
            print("}", file=out)

            print(count, 'entries')

    def process_quests(self):
        print('processing quests...', end='', flush=True)

        with self.open_with_header('quests.lua') as out:
            cursor = self.cnx.cursor()
            query = ("SELECT entry, title, minlevel, rewchoiceitemid1, rewchoiceitemid2, rewchoiceitemid3, rewchoiceitemid4," +
                    "rewchoiceitemid5, rewchoiceitemid6, rewitemid1, rewitemid2, rewitemid3, rewitemid4 FROM %squest_template") % (MANGOS_PREFIX)
            cursor.execute(query)

            print("zeroDB.db.quests = {", file=out)

            count = 0

            for (entry, name, minlevel, rewchoiceitemid1, rewchoiceitemid2, rewchoiceitemid3, rewchoiceitemid4,
                    rewchoiceitemid5, rewchoiceitemid6, rewitemid1, rewitemid2, rewitemid3, rewitemid4) in cursor:

                keywords = [''] + name.split(' ')
                keywords = list(set(map(lambda s: s.lower(), keywords)))
                keywords_str = '' #'|'.join(keywords)

                print("    [%5d] = {type = 'quest', id = %5d, name = %s, minlevel = %s, keywords = %s}," % (
                    entry, entry, json.dumps(name), minlevel, json.dumps(keywords_str)), file=out)
                #self.keywords.add(keywords, QUESTS_BASE + entry)
                count += 1

                self.add_quest_rewards(entry, rewchoiceitemid1, rewchoiceitemid2, rewchoiceitemid3, rewchoiceitemid4,
                    rewchoiceitemid5, rewchoiceitemid6, rewitemid1, rewitemid2, rewitemid3, rewitemid4)

            cursor.close()
            print("}", file=out)

            print(count, 'entries')

def print_db_version(cnx):
    cursor = cnx.cursor()
    cursor.execute("SHOW VARIABLES LIKE 'version%'")

    for row in cursor:
        print(row)

    cursor.close()

def process_creatures(cnx, keyword_map):
    print('processing creatures...', end='', flush=True)

    with open('creatures.lua.in', 'rt') as header_file:
        header = header_file.read()

    with open(OUTPUT_PREFIX + 'creatures.lua', 'wt') as output_file:
        output_file.write(header)

        cursor = cnx.cursor()
        query = ("SELECT entry, name, minlevel, maxlevel, creaturetype, rank FROM %screature_template") % (MANGOS_PREFIX)
        cursor.execute(query)

        print("zeroDB.db.creatures = {", file=output_file)

        count = 0

        for entry, name, minlevel, maxlevel, creaturetype, rank in cursor:
            keywords = [''] + name.split(' ')

            if creaturetype in creature_types:
                keywords.append(creature_types[creaturetype])

            if rank in creature_ranks:
                keywords.append(creature_ranks[rank])

            keywords = list(set(map(lambda s: s.lower(), keywords)))
            keywords_str = '|'.join(keywords)

            print("    [%5d] = {type = 'creature', id = %5d, name = %s, keywords = %s, minlevel = %d, maxlevel = %d, creature_type = %d, rank = %d}," % (
                entry, entry, json.dumps(name), json.dumps(keywords_str), minlevel, maxlevel, creaturetype, rank), file=output_file)
            #keyword_map.add(keywords, CREATURES_BASE + entry)
            count += 1

        cursor.close()
        print("}", file=output_file)

        print(count, 'entries')

def dump_table(name, table, output_file):
    print(name, " = {", file=output_file)
    for k, v in table.items():
        if type(v) == str:
            print("    [%2d] = %s," % (k, json.dumps(v)), file=output_file)
        else:
            print("    [%2d] = {" % k, file=output_file)

            for l, w in v.items():
                print("        [%2d] = %s," % (l, json.dumps(w)), file=output_file)

            print("    },", file=output_file)
    print("}", file=output_file)
    print(file=output_file)

try:
    cnx = mysql.connector.connect(user=USER, password=PASS, database=MANGOS_DB)
except mysql.connector.Error as err:
    if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("Wrong username or password")
    elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("Database does not exist")
    else:
        print(err)
else:
    p = Processor(cnx)
    p.process_quests()
    p.process_items()

    process_creatures(cnx, p.keywords)
    cnx.close()

    p.keywords.write()
