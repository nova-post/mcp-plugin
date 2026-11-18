---
name: documents
description: Download official Nova Post (Нова пошта) shipment documents — the marking label (етикетка, маркування), international documents or invoice — as PDF links. Use when the user wants to print a label or needs a shipment document.
argument-hint: "<shipment-number...> [marking|international|invoice] [A4|100x100]"
allowed-tools: [mcp__plugin_nova-post_nova-post__get_shipments_print]
---

# Download Nova Post shipment documents

Arguments: $ARGUMENTS

1. Take one or more shipment numbers from the arguments; ask if none were given.
2. Pick `document_type`: `marking` (default, the label), `international`, or `invoice`. Map `A4` to
   `print_size: size_A4` and `100x100` to `size_100_100`.
3. Call `get_shipments_print` (`shipment_number` for one, `numbers` for several).
4. Return each download link with its shipment number and say how long it stays valid (`expires_in_seconds`).

Never generate a QR code or barcode from the shipment number yourself.
