# Foxtopia calendar and regional climate

Foxtopia's year has four named periods of 15 days, for 60 days total. The names
are global calendar labels based on familiar month names: January, April, July,
October. These are four game periods, not Gregorian months. Each
settlement also has a **local** season. North and south have opposite seasons;
some sites have a permanent summer or winter, and mild sites can have two
dominant seasons. This keeps the date meaningful when players maintain separate
colonies in different parts of a multiplayer world.

Each world tile already has an annual mean temperature and latitude. The
`ClimateCalendar` module uses those values to compute the normal outdoor
temperature for each of the 60 days, four period minimum/maximum/mean values,
the annual minimum and maximum, and the days when outdoor crops can grow.
Foxtopia's current outdoor growing range is **5–42 °C**. The world preview's
growing days and farm output both use that rule. A displayed 60/60 days means
the site is within that range on every day of a standard game year. The profile
is deterministic for a given seed, tile and day, so host, clients and saves
agree. Existing saves receive the missing climate fields when loaded.

The selected site displays each period's local season and temperature range.
"Coast" means direct contact with an ocean or large connected sea on the world
map. A small connected body of water is labeled "lake shore". An inland tile
does not acquire a coastline in its landing map solely from local noise. Existing
saves keep their already generated local maps.

These values are *climate normals*. They do not yet model weather events,
indoor heating, temperature-related injuries or plant species with different
temperature tolerances. The temperature range shown in the world preview is
therefore a seasonal planning range, not a guaranteed daily weather report.

## Research basis

- [Official RimWorld description](https://rimworldgame.com/) describes a planet
  spanning pole to equator and tiles with different temperatures, rainfall and
  growing periods, with tundra's period especially short.
- [RimWorld Wiki: Time](https://mail.rimworldwiki.com/wiki/Day) documents four
  15-day quadrums per year and opposite local seasons between hemispheres.
- [RimWorld Wiki: Growing zone](https://www.rimworldwiki.com/wiki/Growing_zone)
  explains that outdoor planting depends on local growing period and plant
  temperature limits. Foxtopia uses its own simplified temperature rule above.
- [RimWorld Wiki: World generation](https://rimworldwiki.com/wiki/World_generation)
  describes world terrain and coastlines as planet features.
- [RimWorld Wiki: Lake](https://rimworldwiki.com/wiki/Lake) distinguishes lakes
  from sea coasts; Foxtopia uses a simplified connected-water threshold.
