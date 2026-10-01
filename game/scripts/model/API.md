# Foxtopia authoritative model API

`game_model.gd` is autoloaded as `Game`. The host calls `Game.tick(delta)` and
`Game.issue_command(peer_id, command)`. Clients render `Game.get_snapshot()` or
load a server snapshot through `Game.load_snapshot(snapshot)`. All state is
made of JSON-friendly dictionaries, arrays, strings, numbers, and booleans.

## Setup and world preview

```gdscript
var preview = Game.preview_world("my seed")
# {seed, width:96, height:60, tiles:[5760 biome strings], sites:[...]}
# site: {id:"site_1", x, y, biome, kind:"vacant"|"friendly"|"hostile", name}

Game.start_new_game({
    "seed": "my seed",
    "mode": "competitive", # "solo", "coop", or "competitive"
    "colonists_per_faction": 2, # 1..8
    "faction_specs": [
        {"id":"faction_1", "name":"Tilki", "settlement_name":"Yuva",
         "site_id":"site_1", "players":[1],
         "colonists":[{"name":"Ada", "age":34,
           "childhood":"rural_child", "adulthood":"builder",
           "appearance":{"hair":"short", "hair_color":"#493629",
             "skin":"#d59e74", "outfit":"#517da7"},
           "traits":["hardworking","calm"], "health_conditions":[],
           "skills":{"build":6}, "starting_gear":{"weapon":"spear",
             "apparel":"jacket"}, "starting_relationships":{"1":"friend"}}]},
        {"id":"faction_2", "name":"Kuzey", "settlement_name":"Kale",
         "site_id":"site_2", "players":[2], "colonists":[]}
    ]
})
```

Missing `faction_specs` creates a solo/co-op faction or one faction per
competitive player from `player_count`. `colonists` can also be supplied at the
top level for the default first faction. Invalid or occupied start sites are
replaced by the next vacant site. `players` contains ENet peer IDs; the model
maps each ID to its faction. The host should provide the actual connected IDs.
`starting_relationships` keys are zero-based indices into the same faction's
starting roster; values are `friend`, `rival`, or `partner`. Character preparation
may enforce a configurable point limit.

## Snapshots

`Game.state_changed(snapshot)` fires after setup, each valid command, and each
simulated second with the local model state. `Game.event_emitted(event)` reports raids, caravans,
research, trade, deaths, and construction. `Game.get_snapshot(0)` returns the
full authoritative state. `Game.get_snapshot(peer_id)` hides other players'
private maps, people, inventory, research, and orders in competitive mode.
Clients should not call `tick` or `issue_command` locally.

The state has `world`, `factions`, `players`, `maps` (dictionary keyed by site
ID), `colonists`, `orders`, `raiders`, `caravans`, `trade_offers`, `events`,
`research_projects`, `time`, and `mode`. IDs are **strings** throughout.

Each 50×50 map has `terrain` (flat row-major array of `grass`, `dirt`,
`water`, `rock_ground`), `resources` (`tree`, `stone`, `berry`), `drops`, and
`structures`. A tile index is `y * 50 + x`. Colonists expose `x`, `y`,
`faction_id`, `site_id`, `needs`, `health`, `traits`, `skills`,
`work_priorities`, `equipment`, `drafted`, `manual`, and `current_order`.
Faction `inventory` is a dictionary of item counts; `research` has `project`,
`progress`, `unlocked`.

## Commands

All commands return `{ok: true, ...}` or `{ok: false, error: "..."}`. The
server validates that `peer_id` owns the faction/colonist/order. Work priority
uses `0` for Off, `1` highest, `9` lowest; order priority uses `1..9`, default
`5`. Manual commands interrupt automatic work. Drafted people stop regular
work and defend nearby.

```gdscript
Game.issue_command(1, {"type":"designate", "site_id":"site_1",
    "x":21, "y":20, "kind":"chop", "priority":1})
Game.issue_command(1, {"type":"set_work_priority",
    "colonist_id":"colonist_1_1", "work":"build", "priority":2})
Game.issue_command(1, {"type":"set_order_priority", "order_id":"order_1",
    "priority":9})
Game.issue_command(1, {"type":"cancel_order", "order_id":"order_1"})
Game.issue_command(1, {"type":"direct", "colonist_id":"colonist_1_1",
    "action":"move", "x":25, "y":25})
Game.issue_command(1, {"type":"direct", "colonist_id":"colonist_1_1",
    "action":"work", "target_id":"order_1"})
Game.issue_command(1, {"type":"direct", "colonist_id":"colonist_1_1",
    "action":"haul", "target_id":"drop_2"})
Game.issue_command(1, {"type":"direct", "colonist_id":"colonist_1_1",
    "action":"equip", "item":"spear"})
Game.issue_command(1, {"type":"direct", "colonist_id":"colonist_1_1",
    "action":"attack", "target_id":"raider_10"})
Game.issue_command(1, {"type":"direct", "colonist_id":"colonist_1_1",
    "action":"trade", "target_id":"caravan_7"})
Game.issue_command(1, {"type":"set_draft", "colonist_id":"colonist_1_1",
    "drafted":true})
Game.issue_command(1, {"type":"set_research", "project":"farming"})
Game.issue_command(1, {"type":"customize_colonist",
    "colonist_id":"colonist_1_1", "appearance":{"hair":"long",
    "hair_color":"#5e4632", "outfit":"#637c9d"}})
Game.issue_command(1, {"type":"rename", "target":"settlement", "name":"Yuva"})
```

Designation kinds: `chop`, `mine`, `harvest`, `haul`, `build_wall`,
`build_bed`, `build_research_bench`, `build_stone_wall`, `build_barrier`,
`build_farm`. The latter three require matching research. Research projects:
`farming`, `first_aid`, `stonework`, `barriers`. Structures and resource
designations require valid map locations. Food, wood, and stone from gathering
appear as ground drops, then need hauling into faction inventory.
For `work`, `attack`, and `trade`, `x`/`y` can replace `target_id` when the
target is at the clicked tile.

Trade commands:

```gdscript
Game.issue_command(1, {"type":"trade_offer", "to_faction":"faction_2",
    "give":{"wood":4}, "receive":{"stone":2}})
Game.issue_command(2, {"type":"trade_accept", "offer_id":"trade_3"})
Game.issue_command(2, {"type":"trade_decline", "offer_id":"trade_3"})
Game.issue_command(1, {"type":"npc_trade", "caravan_id":"caravan_4",
    "buy":{"food":2}, "sell":{"wood":4}})
```

Player trade locks both inventories on acceptance; delivery occurs after a
world-distance travel time. Friendly NPC caravans arrive periodically and stay
for 70 simulated seconds. `npc_trade` uses fixed item prices and caravan
stock. Hostile NPC sites generate periodic raids on each active settlement.

## Persistence

`Game.serialize_game()` returns the full server state. `Game.save_game()` writes
a timestamped slot under `user://saves/`; pass a slot ID to overwrite a named
slot. `Game.list_saved_games()` returns available slots and `Game.load_game()`
loads the newest one. Pass a slot ID to load a specific slot, or a saved
dictionary for custom storage. `load_game()` also reads the legacy
`user://foxtopia_save.json` when there are no slots. `load_snapshot` is for
rendering a server view and accepts snapshots filtered for one client.
