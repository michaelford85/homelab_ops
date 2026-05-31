# awtrix_clock

<p align="center">
  <img src="./images/awtrix.gif" alt="Demo GIF">
</p>


Version-controlled configuration for three Ulanzi TC001 pixel clocks running
AWTRIX 3 firmware, integrated with Home Assistant over MQTT. One clock lives
in each of the kitchen, living room, and office, and each has its own MQTT
prefix and behaviour:

| Clock       | MQTT prefix         | What it shows                                              |
|-------------|---------------------|-----------------------------------------------------------|
| Kitchen     | `awtrix/kitchen`    | Clock face, date, weather, multi-recipient timer + push   |
| Living room | `awtrix/livingroom` | Combined time + temperature, AM/PM indicator pixel        |
| Office      | `awtrix/office`     | Combined time + temperature, Pi-hole counts, stock ticker, presence-based brightness |

The native AWTRIX apps for time, date, temperature, humidity, and battery are
disabled in favour of custom apps published by Home Assistant, so the data
source is HA (not the clock's onboard sensors).

## Layout

```
awtrix_clock/
├── README.md                              this file
├── homeassistant/
│   ├── automations.awtrix.yaml            templated AWTRIX automations (reference)
│   ├── scripts.awtrix.yaml                kitchen_timer scripts
│   ├── configuration.snippet.yaml         timer: + yahoofinance: for configuration.yaml
│   ├── dashboard.snippet.yaml             Lovelace kitchen-timer card
│   └── helpers.md                         UI helpers to recreate manually
├── device/
│   ├── awtrix_settings.json               /api/settings payload to restore device config
│   ├── apply_settings.sh                  POST settings + reboot a clock
│   └── icons.md                           LaMetric icon IDs to download via Icons tab
└── examples/
    └── automations.awtrix.example.yaml    fully-templated automations with header
```

## Prerequisites

- Home Assistant with the Mosquitto broker add-on running.
- MQTT integration configured in HA, with **Enable discovery** turned on.
- A weather entity with a daily forecast (the kitchen app uses
  `weather.forecast_home`; the living-room and office apps use
  `weather.openweathermap`). Rename to whatever you have.
- Mobile app notify services for each timer recipient (e.g.
  `notify.mobile_app_<user_a_device>`).
- Office-only extras: a presence `binary_sensor` (the office app uses
  `binary_sensor.office_mmwave`), Pi-hole sensors
  (`sensor.pi_hole_ads_blocked`, `sensor.pi_hole2_ads_blocked`), and the
  `yahoofinance` custom integration for the stock ticker.

## Placeholders

The committed `homeassistant/automations.awtrix.yaml` is a reference copy
with personal identifiers templated. MQTT topics use literal room-based
prefixes (`awtrix/kitchen`, `awtrix/livingroom`, `awtrix/office`); only the
two timer-recipient device names are placeholders. Substitute these when
copying back into a live `automations.yaml`:

| Placeholder        | Example value | Source                        |
|--------------------|---------------|-------------------------------|
| `<user_a_device>`  | `phone_a`     | HA mobile_app integration     |
| `<user_b_device>`  | `phone_b`     | HA mobile_app integration     |

`<CLOCK_IP>` is not in any YAML file; it is passed to
`device/apply_settings.sh` as an argument or `CLOCK_IP` env var, once per
clock.

## From-scratch setup sequence

Repeat steps 1-4 for each of the three clocks, then do the HA-side steps
(5-7) once.

1. **Flash AWTRIX 3.** Use the [AWTRIX web flasher](https://blueforcer.github.io/awtrix3/)
   to install the firmware on a Ulanzi TC001. Join it to Wi-Fi via its
   captive portal.
2. **Set a static DHCP reservation** on the router for the clock's MAC and
   record its IP.
3. **Configure MQTT on the clock.** Web UI -> MQTT:
   - Broker: HA's Mosquitto broker IP and port
   - Username / password: your MQTT credentials
   - Prefix: the room prefix for this unit (`awtrix/kitchen`,
     `awtrix/livingroom`, or `awtrix/office`). Each physical clock must have
     its own unique two-level prefix.
   - Enable Home Assistant Discovery.
4. **Apply device settings.** From a machine that can reach the clock:
   ```
   awtrix_clock/device/apply_settings.sh <clock_ip>
   ```
   This POSTs `awtrix_settings.json` to `/api/settings` and reboots. Key
   settings: `TFORMAT=%l:%M` (12-hour), `DFORMAT=%m/%d`, `ATIME=15`
   (15s per app), and `TIM`/`DAT`/`TEMP`/`HUM`/`BAT` all `false` (native
   apps disabled, HA-published custom apps take over).
5. **Add HA config files:**
   - Merge `homeassistant/configuration.snippet.yaml` into HA's
     `configuration.yaml` (`timer:` for the kitchen, `yahoofinance:` for the
     office ticker).
   - Merge `homeassistant/scripts.awtrix.yaml` into HA's `scripts.yaml`.
   - Copy the ten automations from `homeassistant/automations.awtrix.yaml`
     into HA's `automations.yaml`, substituting the placeholders above and
     renaming any integration-specific entities (weather, presence, Pi-hole,
     finance) to match yours.
   - Restart Home Assistant.
6. **Recreate UI helpers** per `homeassistant/helpers.md`
   (`input_number.kitchen_timer_minutes`, `input_select.kitchen_timer_notify`),
   then add the kitchen-timer card from `homeassistant/dashboard.snippet.yaml`
   to a Lovelace dashboard.
7. **Download icons** listed in `device/icons.md` via each clock's web UI
   -> Icons tab (weather + `2421` on the kitchen unit, `7820` on the office
   unit).
8. **Verify each clock:**
   - HA Developer Tools -> MQTT, publish `{"text":"hi"}` to
     `<room_prefix>/notify`; that clock should display it.
   - Kitchen: watch it cycle clock face, date, and weather; call
     `script.kitchen_timer` with `minutes: 1` and expect a countdown tile,
     then "TIME!" + sound + phone push.
   - Living room / office: confirm the combined time+weather app updates and
     (office) the Pi-hole, stock, and presence-brightness behaviour.

## MQTT prefix convention and adding a fourth clock

Every MQTT topic in the automations is prefixed with a literal room name.
Each physical clock owns one two-level prefix; two clocks must never share a
prefix or they'll fight over the same topics:

| Clock       | Prefix              | Topics used                                                        |
|-------------|---------------------|--------------------------------------------------------------------|
| Kitchen     | `awtrix/kitchen`    | `custom/weather`, `custom/clock`, `custom/date`, `custom/timer`, `notify` |
| Living room | `awtrix/livingroom` | `custom/clockweather`, `indicator1`, `indicator3`                  |
| Office      | `awtrix/office`     | `custom/clockweather`, `custom/pihole`, `custom/stocks`, `settings` |

To add a fourth clock (e.g. a bedroom unit):

1. Pick a **unique two-level prefix** (e.g. `awtrix/bedroom`).
2. Run device steps 1-4 above for the new unit, using that prefix.
3. Duplicate whichever automation blocks you want for the new clock in HA's
   `automations.yaml`, give each a unique `id` and `alias`, and replace the
   room prefix in their topics with the new one.
4. If the new unit needs its own timer or notify routing, duplicate
   `timer.kitchen_clock`, `input_select.kitchen_timer_notify`, and the
   `kitchen_timer*` scripts with unit-specific names.

## Files

- **`homeassistant/automations.awtrix.yaml`** - All ten AWTRIX automations
  (three kitchen, one global weather refresh, one living-room, five office)
  with personal device names templated. Reference copy; not a drop-in include.
- **`homeassistant/scripts.awtrix.yaml`** - `kitchen_timer` (takes
  `minutes`) and `kitchen_timer_from_slider` (reads `input_number`).
- **`homeassistant/configuration.snippet.yaml`** - `timer.kitchen_clock`
  entity and the `yahoofinance:` symbols for the office ticker.
- **`homeassistant/dashboard.snippet.yaml`** - Lovelace card for the kitchen
  timer (slider, notify dropdown, start/cancel buttons).
- **`homeassistant/helpers.md`** - UI helpers that can't be expressed in
  YAML.
- **`device/awtrix_settings.json`** - `/api/settings` payload. Re-fetch
  with `curl http://<CLOCK_IP>/api/settings` after any web-UI change.
- **`device/apply_settings.sh`** - POSTs the JSON to one clock and reboots.
- **`device/icons.md`** - LaMetric icon IDs to download per clock.
- **`examples/automations.awtrix.example.yaml`** - Same automations with
  a fuller header documenting each placeholder; copy this when bootstrapping
  a new unit.
