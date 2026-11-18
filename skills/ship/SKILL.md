---
name: ship
description: Create a Nova Post (Нова пошта) shipment (відправлення, посилка, накладна) in Ukraine or abroad, step by step, with a confirmation summary before anything is created. Use when the user wants to send a parcel.
argument-hint: "[from city] [to city] [parcel details]"
allowed-tools: [mcp__plugin_nova-post_nova-post__get_settlements, mcp__plugin_nova-post_nova-post__get_divisions, mcp__plugin_nova-post_nova-post__get_dictionary_measurements, mcp__plugin_nova-post_nova-post__get_dictionary_currencies, mcp__plugin_nova-post_nova-post__get_dictionary_classifier, mcp__plugin_nova-post_nova-post__get_dictionary_customs_fees_code, mcp__plugin_nova-post_nova-post__post_shipments_calculations]
---

# Create a Nova Post shipment

Arguments: $ARGUMENTS

Use what the arguments already give and ask only for what is missing, grouping questions so the user answers in one
message:

- route: sender and recipient city, then branch or address. Find branches as in the `branches` skill and use the
  internal division `id` as `divisionId`, never the displayed branch number;
- sender and recipient: full name (at least two words) and phone in international format;
- parcel: description, weight, dimensions, declared value;
- who pays for delivery;
- international only: customs data. Get country rules with `get_dictionary_customs_fees_code` (destination
  ISO country code, not an HS code), HS codes with `get_dictionary_classifier` (cargo `keyword` is
  required) and currencies with `get_dictionary_currencies`.

Then:

1. Calculate the cost with `post_shipments_calculations`, as in the `calculate` skill.
2. Show a summary: sender and recipient points, names and phones, description, weight, dimensions, declared value,
   delivery cost and payer. Ask whether to create the shipment, in the user's language.
3. Only after an explicit confirmation call `post_shipments`. It creates a real shipment.
4. Report the shipment number, status, cost and scheduled delivery date, and offer the printable label
   (`documents` skill).

If the user changes any data after the summary, recalculate and ask for confirmation again.
