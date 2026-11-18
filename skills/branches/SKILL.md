---
name: branches
description: Find Nova Post (Нова пошта) branches, points or parcel lockers (відділення, поштомати) in a city or near an address or landmark. Use when the user asks where to send or pick up a parcel, or needs a branch for a delivery calculation or a new shipment.
argument-hint: "<city> [address or landmark] [locker]"
allowed-tools: [mcp__plugin_nova-post_nova-post__get_settlements, mcp__plugin_nova-post_nova-post__get_divisions, mcp__plugin_nova-post_nova-post__get_streets]
---

# Find Nova Post branches

Arguments: $ARGUMENTS

1. Resolve the city with `get_settlements` (`textSearch` = city name). If several settlements match, ask
   which one, showing region and district.
2. Call `get_divisions` with the chosen `settlementIds` or coordinates. Never call it without a location
   filter; search each settlement separately.
3. Keep only working divisions that fit the request: allow sending or receiving as asked, parcel lockers only if the
   user wants them. If an address or landmark was given, prefer the divisions closest to it.
4. Show at most three options with branch number, type, address and today's schedule, in the user's language.

Remember each option's internal `id`: it is the `divisionId` for calculation and shipment creation. A displayed
branch number ("Відділення №25") is never a `divisionId`, and a `settlementId` is not one either.
