# awtrix_clock

Version-controlled configuration for the Ulanzi TC001 pixel clock running
AWTRIX 3 firmware, integrated with Home Assistant over MQTT.

The clock runs custom apps for time, date, weather, and a multi-recipient
kitchen timer with phone notifications. The native AWTRIX apps for time,
date, temperature, humidity, and battery are disabled in favor of custom
apps published by Home Assistant, so the data source is HA (not the
clock's onboard sensors).

## Layout

```
awtrix_clock/
├── README.md                              this file
├── homeassistant/
│   ├── automations.awtrix.yaml            templated AWTRIX automations (reference)
│   ├── scripts.awtrix.yaml                kitchen_timer scripts
│   ├── configuration.snippet.yaml         timer: helper block for configuration.yaml
│   └── helpers.md                         UI helpers to recreate manually
├── device/
│   ├── awtrix_settings.json               /api/settings payload to restore device config
│   ├── apply_settings.sh                  POST settings + reboot the clock
│   └── icons.md                           LaMetric icon IDs to download via Icons tab
└── examples/
    └── automations.awtrix.example.yaml    fully-templated automations with header
```

## Prerequisites

- Home Assistant with the Mosquitto broker add-on running.
- MQTT integration configured in HA, with **Enable discovery** turned on.
- A `weather.forecast_home` entity (the HA default, e.g. Met.no integration).
- Mobile app notify services for each recipient (e.g. `notify.mobile_app_mf_iphone`).

## Placeholders

The committed `homeassistant/automations.awtrix.yaml` is a reference copy
with secrets templated. Substitute these when copying back into a live
`automations.yaml`:

| Placeholder              | Real value (kitchen unit) | Source                               |
|--------------------------|---------------------------|--------------------------------------|
| `<MQTT_PREFIX>`          | `awtrix/kitchen`          | Clock MQTT settings (web UI)         |
| `<MOBILE_NOTIFY_MICHAEL>`| `mobile_app_mf_iphone`    | HA mobile_app integration            |
| `<MOBILE_NOTIFY_PARTNER>`| `mobile_app_sf_f7`        | HA mobile_app integration            |

`<CLOCK_IP>` (default `10.0.30.168`) is not in any YAML file; it is passed
to `device/apply_settings.sh` as an argument or `CLOCK_IP` env var.

## From-scratch setup sequence

1. **Flash AWTRIX 3.** Use the [AWTRIX web flasher](https://blueforcer.github.io/awtrix3/)
   to install the firmware on a Ulanzi TC001. Join it to Wi-Fi via its
   captive portal.
2. **Set a static DHCP reservation** on the router for the clock's MAC.
   Record the IP (default `10.0.30.168`).
3. **Configure MQTT on the clock.** Web UI -> MQTT:
   - Broker: HA's Mosquitto broker IP and port
   - Username / password: your MQTT credentials
   - Prefix: `awtrix/kitchen` (or another unique two-level prefix per unit)
   - Enable Home Assistant Discovery.
4. **Apply device settings.** From a machine that can reach the clock:
   ```
   awtrix_clock/device/apply_settings.sh 10.0.30.168
   ```
   This POSTs `awtrix_settings.json` to `/api/settings` and reboots. Key
   settings: `TFORMAT=%l:%M` (12-hour), `DFORMAT=%m/%d`, `ATIME=15`
   (15s per app), and `TIM`/`DAT`/`TEMP`/`HUM`/`BAT` all `false` (native
   apps disabled, HA-published custom apps take over).
5. **Add HA config files:**
   - Merge `homeassistant/configuration.snippet.yaml` into HA's `configuration.yaml`.
   - Merge `homeassistant/scripts.awtrix.yaml` into HA's `scripts.yaml`.
   - Copy the three automations from `homeassistant/automations.awtrix.yaml`
     into HA's `automations.yaml`, substituting the placeholders above.
   - Restart Home Assistant.
6. **Recreate UI helpers** per `homeassistant/helpers.md`
   (`input_number.kitchen_timer_minutes`, `input_select.kitchen_timer_notify`).
7. **Download icons** listed in `device/icons.md` via the clock's web UI
   -> Icons tab.
8. **Verify:**
   - HA Developer Tools -> MQTT, publish `{"text":"hi"}` to
     `awtrix/kitchen/notify`; the clock should display it.
   - Watch the clock cycle through clock face, date, and weather custom apps.
   - Call `script.kitchen_timer` with `minutes: 1`; expect a 1-minute
     countdown tile on the clock, then "TIME!" + sound + phone push.

## MQTT prefix and adding a second clock

All MQTT topics in the automations use `<MQTT_PREFIX>` (default
`awtrix/kitchen`). The prefix appears in:

- The clock's MQTT settings (set once per device).
- Five topics in `homeassistant/automations.awtrix.yaml`:
  `<MQTT_PREFIX>/custom/weather`, `<MQTT_PREFIX>/notify`,
  `<MQTT_PREFIX>/custom/timer`, `<MQTT_PREFIX>/custom/clock`,
  `<MQTT_PREFIX>/custom/date`.

To add a second clock (e.g. an office unit):

1. Pick a **unique two-level prefix** for the new unit (e.g. `awtrix/office`).
   Each physical clock must have its own prefix or they'll fight over the
   same topics.
2. Set a static DHCP reservation for the new unit and configure its MQTT
   prefix in the web UI.
3. Apply the device settings: `device/apply_settings.sh <new_clock_ip>`.
4. Duplicate the three AWTRIX automations in HA's `automations.yaml`,
   give each a unique `id` and `alias` suffix (e.g. `awtrix_weather_office`),
   and replace `<MQTT_PREFIX>` with the new unit's prefix.
5. If the second unit needs its own timer or notify routing, duplicate
   `timer.kitchen_clock`, `input_select.kitchen_timer_notify`, and the
   `kitchen_timer*` scripts with unit-specific names.

## Files

- **`homeassistant/automations.awtrix.yaml`** - The three AWTRIX automations
  (`awtrix_weather`, `awtrix_timer_display`, `Awtrix Clock Faces`) with
  secrets replaced by placeholders. Reference copy; not a drop-in include.
- **`homeassistant/scripts.awtrix.yaml`** - `kitchen_timer` (takes
  `minutes`) and `kitchen_timer_from_slider` (reads `input_number`).
- **`homeassistant/configuration.snippet.yaml`** - `timer.kitchen_clock`
  entity definition.
- **`homeassistant/helpers.md`** - UI helpers that can't be expressed in
  YAML.
- **`device/awtrix_settings.json`** - `/api/settings` payload. Re-fetch
  with `curl http://<CLOCK_IP>/api/settings` after any web-UI change.
- **`device/apply_settings.sh`** - POSTs the JSON and reboots.
- **`device/icons.md`** - LaMetric icon IDs to download on each clock.
- **`examples/automations.awtrix.example.yaml`** - Same automations with
  a fuller header documenting each placeholder; copy this when bootstrapping
  a new unit.
