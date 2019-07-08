# tnt
Fork of [tnt](https://github.com/minetest/minetest_game/tree/master/mods/tnt)

water flow code copied from TenPlus1's builtin_item mod [builtin_item](https://notabug.org/TenPlus1/builtin_item)

# Features 

1. TNT is always entity on ignite.

2. TNT entitys flow in water.

3. TNT jumps on ignite.

4. It is possible to make minecraft style TNT cannons with this mod.

5. TNT does not damage nodes if in water.

# Config

The size of the default tnt blast.

``` lua
tnt_radius = 3
```

The number to multiply the TNT's entity knockback velocity on blast.

``` lua
tnt_revamped.entity_velocity_mul = 2
```

**In Water**

If true TNT blast will be able to damage nodes even if its in water.

``` lua
tnt_revamped.damage_nodes = false
```

If true TNT blast will be able to damage entities even if its in water.

``` lua
tnt_revamped.damage_entities = false
```

Authors of source code
----------------------
PilzAdam (MIT)

ShadowNinja (MIT)

sofar (sofar@foo-projects.org) (MIT)

Various Minetest developers and contributors (MIT)
