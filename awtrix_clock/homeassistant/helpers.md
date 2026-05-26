# Home Assistant UI Helpers

These helpers cannot be expressed in YAML cleanly (they live in HA's
storage backend), so they must be recreated manually via
Settings -> Devices & services -> Helpers -> Create helper.

## input_number.kitchen_timer_minutes

Dashboard slider that feeds `script.kitchen_timer_from_slider`.

| Field        | Value  |
|--------------|--------|
| Type         | Number |
| Name         | Kitchen Timer Minutes |
| Minimum      | 1      |
| Maximum      | 120    |
| Step size    | 1      |
| Display mode | Slider |
| Unit of measurement | min |

## input_select.kitchen_timer_notify

Dropdown that selects which phone(s) get the "timer done" push
notification when `timer.kitchen_clock` finishes.

| Field   | Value |
|---------|-------|
| Type    | Dropdown |
| Name    | Kitchen Timer Notify |
| Options | `Michael`, `Partner`, `Both` |

The `awtrix_timer_display` automation reads this entity and routes to
the matching mobile_app notify service. `Both` is the default branch
and notifies both phones.
