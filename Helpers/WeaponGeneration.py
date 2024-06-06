import random
random.seed()

mobLevel = 1
mobDifficutly = 1 #1 = reg enemy, 2 = elite, 3 = miniboss, 4 = boss
maxmobDifficutly = 4
# 1, 70% common, 20# uncommon, 8% epic, 2% legendary
# 2, 50% common, 35# uncommon, 10% epic, 5% legendary
# 3, 30% common, 40# uncommon, 20% epic, 10% legendary 
# 4, 20% common, 30# uncommon, 30% epic, 20% legendary





#Weapon base stats
"""
Damage
Attack speed
"""

#Weapon optional stats
"""
Health
Mana
health regen
mana regen
CDR
movespeed
attack damage
attack speed
ability power
projectile speed
projectile size
shield
lifesteal
crit chance
crit damage
"""
weapon_type_pool = ["Sword", "Bow", "Hammer", "Spear"]
weapon_mod_pool = ["Health", "Mana", "Health Regen", "Mana Regen", "CDR", "Movespeed", "bonus attack damage", "bonus attack speed", "ability power", "projectile speed", "projectile size", "shield", "lifesteal", "crit chance", "crit damage"]
current_weapon_mods = ["Attack Damage", "Attack Speed"]


avaiableStatPoints = (mobLevel + mobDifficutly) * 10
maxStatPoints = avaiableStatPoints

i = 0
while i < mobDifficutly+1:
    index = random.randint(0,len(weapon_mod_pool) - 1)
    if (weapon_mod_pool[index] not in current_weapon_mods):
        current_weapon_mods.append(weapon_mod_pool[index])
        i+=1

print(current_weapon_mods)


weapon = {}
weapon_type = weapon_type_pool[random.randint(0, len(weapon_type_pool) - 1)]
weapon['Type'] = weapon_type

i = 0
while i < 3 and avaiableStatPoints > 0:
    for stat in current_weapon_mods:
        if(stat == "Health"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            statPoints *= 10

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon.update({stat : statPoints})

        elif(stat == "Attack Damage"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "Attack Speed"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            #High attack speed variants of low level items?
            statPoints /= 10

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "Mana"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            statPoints *= 10

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints          
                      
        elif(stat == "Health Regen"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            statPoints /= 10

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "Mana Regen"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            statPoints /= 10

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "CDR"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            #Max cooldown reduction is 50, 
            maxCDR = 50
            percentageOfPoints = avaiableStatPoints / maxStatPoints

            #Because there is a max cooldown value we need to scale the value.
            #The value is scaled from the ratio of allocated points to max avaiable points and mob difficulty to max difficutly
            # So if we are only allocating 50% of the points the max cdr will be 25, it will then be scaled from item rarity
            statPoints = (maxCDR * percentageOfPoints) * (mobDifficutly / maxmobDifficutly)

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "Movespeed"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            maxMS = 100

            percentageOfPoints = avaiableStatPoints / maxStatPoints
            statPoints = (maxMS * percentageOfPoints) * (mobDifficutly / maxmobDifficutly)            

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "bonus attack damage"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "bonus attack speed"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            statPoints /= 10

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "ability power"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "projectile speed"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            maxProjectileSpeed = 100

            percentageOfPoints = avaiableStatPoints / maxStatPoints
            statPoints = (maxProjectileSpeed * percentageOfPoints) * (mobDifficutly / maxmobDifficutly)            


            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "projectile size"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            maxProjectileSize = 100

            percentageOfPoints = avaiableStatPoints / maxStatPoints
            statPoints = (maxProjectileSize * percentageOfPoints) * (mobDifficutly / maxmobDifficutly)      

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "shield"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            statPoints *= 10

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "lifesteal"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            maxLifeSteal = 100

            percentageOfPoints = avaiableStatPoints / maxStatPoints
            statPoints = (maxLifeSteal * percentageOfPoints) * (mobDifficutly / maxmobDifficutly)   

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "crit chance"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            maxCritChance = 100

            percentageOfPoints = avaiableStatPoints / maxStatPoints
            statPoints = (maxCritChance * percentageOfPoints) * (mobDifficutly / maxmobDifficutly)   

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints

        elif(stat == "crit damage"):
            statPoints = random.randint(int(avaiableStatPoints * 0.2), int(avaiableStatPoints * 0.8))
            avaiableStatPoints -= statPoints

            maxCritDamage = 500

            percentageOfPoints = avaiableStatPoints / maxStatPoints
            statPoints = (maxCritDamage * percentageOfPoints) * (mobDifficutly / maxmobDifficutly)   

            if(stat in weapon):
                weapon[stat] += statPoints
            else:
                weapon[stat] = statPoints




    i += 1



print(weapon)
# stat1 = random.randint(0,max)