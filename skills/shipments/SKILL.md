---
name: shipments
description: List the user's Nova Post (Нова пошта) shipments — parcels they have sent from their account and parcels coming to them — with current statuses. Use when the user asks "my parcels", "what did I send", "what is coming to me" or wants an overview of several shipments.
argument-hint: "[sent|incoming] [shipment numbers...]"
allowed-tools: [mcp__plugin_nova-post_nova-post__get_shipments, mcp__plugin_nova-post_nova-post__get_shipments_tracking]
---

# List Nova Post shipments

Arguments: $ARGUMENTS

## Sent shipments

1. Call `get_shipments` with `limit` and `page`; it returns the shipments created by the user's account.
   Filter by `senderDivisionId` when the user names a sending branch.
2. Request the next `page` only if the user wants more.
3. For the shown shipments call `get_shipments_tracking` with their `numbers` to get current statuses.
4. Show a compact list: shipment number, recipient city or branch, current status, expected delivery date. Personal
   data of the recipient may be hidden in responses; do not ask the user to reveal it.

## Incoming shipments

The service cannot list shipments addressed to the user. Say so plainly and ask for the shipment numbers of the
parcels they expect, then call `get_shipments_tracking` with those `numbers` and show the same compact
list. Do not present the sent list as incoming parcels.
