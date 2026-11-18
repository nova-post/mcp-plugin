---
name: track
description: Track a Nova Post (Нова пошта) shipment by its tracking or waybill number (номер накладної, ТТН) — current status, location, expected delivery date, failure reason and movement history. Use when the user gives a shipment number or asks where a parcel is.
argument-hint: "<shipment-number...> [history]"
allowed-tools: [mcp__plugin_nova-post_nova-post__get_shipments_tracking, mcp__plugin_nova-post_nova-post__get_shipments_tracking_history]
---

# Track a Nova Post shipment

Arguments: $ARGUMENTS

1. Take the shipment number(s) from the arguments or the conversation; ask for one if none is known.
2. Call `get_shipments_tracking` with `numbers`.
3. Reply in the user's language with the shipment number, current status, where the parcel is now and the expected
   delivery date. If delivery failed or is delayed, give the reason from the response.
4. If the user wants the history (`history`, "історія", "де вона була"), also call
   `get_shipments_tracking_history` and add a short chronological timeline, newest event last.
5. If nothing is found, say so and ask the user to check the number.
