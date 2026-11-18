---
name: calculate
description: Calculate Nova Post (Нова пошта) delivery cost, delivery date and available service between two branches or addresses, in Ukraine or abroad. Use when the user asks how much a delivery costs or how long it takes, without creating a shipment.
argument-hint: "[from] [to] [weight] [dimensions] [declared value]"
allowed-tools: [mcp__plugin_nova-post_nova-post__get_settlements, mcp__plugin_nova-post_nova-post__get_divisions, mcp__plugin_nova-post_nova-post__get_dictionary_measurements, mcp__plugin_nova-post_nova-post__post_shipments_calculations]
---

# Calculate Nova Post delivery

Arguments: $ARGUMENTS

1. Resolve the sender and recipient points. For branch or locker delivery find them as in the `branches` skill and
   use the internal division `id` as `divisionId`, never the displayed branch number.
2. Collect what `post_shipments_calculations` requires and ask for anything missing in one message; never
   invent values:
   - `payerType` — who pays for delivery;
   - sender and recipient: `name` (at least two words), `phone` in international format such as `380501234567`,
     `countryCode`, `divisionId`;
   - `parcels`: `rowNumber`, `cargoCategory`, `actualWeight`, `width`, `length`, `height`, `insuranceCost`
     (declared value).
3. Check the expected units with `get_dictionary_measurements` instead of converting from memory.
4. Call `post_shipments_calculations` and report the price, payer, service and estimated delivery date.

The calculation is an estimate and creates nothing. Offer to create the shipment with the same data (`ship` skill).
