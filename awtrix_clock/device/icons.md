# Icons

LaMetric icon IDs used by the AWTRIX custom apps. Download each via the
clock's web UI -> Icons tab -> "Browse LaMetric Icons" -> enter the ID.

Icons must be present on the device before the corresponding custom-app
payload renders; missing icons render as a blank tile.

## Weather (used by `awtrix_weather` automation)

| ID    | Used for                                  |
|-------|-------------------------------------------|
| 11201 | sunny                                     |
| 12181 | clear-night                               |
| 53802 | partlycloudy / cloudy                     |
| 2284  | rainy / pouring                           |
| 2289  | snowy                                     |
| 17055 | fog                                       |
| 2282  | fallback for any state not mapped above   |

## Timer (kitchen, used by `awtrix_timer_display` automation)

| ID   | Used for                                          |
|------|---------------------------------------------------|
| 2421 | running countdown tile and "TIME!" finish notify  |

## Pi-hole (office, used by `Awtrix Office Pihole Blocked` automation)

| ID   | Used for                                  |
|------|-------------------------------------------|
| 7820 | ads-blocked tile on the office clock      |

## Per-clock requirement

Icons are stored on the device, so download them on **every** clock that
renders the matching app:

- Kitchen: weather IDs + `2421` (timer).
- Living room: none (the combined time/weather app is text only).
- Office: `7820` (Pi-hole). Stocks and the combined app are text only.

The weather icon-to-state mapping lives in the `icon:` variable of the
`awtrix_weather` automation in `../homeassistant/automations.awtrix.yaml`.
Change icon IDs there if you swap them out on the device.
