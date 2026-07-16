# First working version

## Purpose

The first working version exists to answer one question: is it pleasant to
share a space and fish together?

Placeholder art and sound are acceptable. Systems that do not help answer this
question should wait.

## Player experience

A player can:

1. Launch Pond and choose a name and simple appearance.
2. Host a session or join one using an address.
3. Walk around a lounge and its connected pond.
4. See other players move smoothly.
5. Send text messages and use a few emotes.
6. Equip a rod, cast, receive a bite, and catch a fish.
7. See nearby players fish and reveal their catches.
8. View caught species in a basic journal.
9. Leave and reconnect without losing local settings or journal progress.

## Minimum content

- One compact lounge
- One connected pond
- One player character base with a few colors or modular options
- A small set of emotes
- Five fish during development
- Basic ambience and interaction sounds
- A journal screen
- Host, join, settings, and disconnect screens

The fish catalog can expand to roughly 20 species after the loop is enjoyable.

## Definition of done

- At least two separate computers can play together over a real network.
- A session remains stable through normal joining and leaving.
- Movement looks smooth under ordinary latency.
- The server validates fishing results and inventory changes.
- Chat has message limits and basic host moderation.
- Save data survives a normal restart.
- Development builds run on Windows, macOS, and Linux.
- A small group can spend 20 minutes together without exhausting the available
  experience or encountering a blocking defect.

## Deliberately deferred

- Central accounts and friend lists
- Public server discovery
- Relay infrastructure and invite codes
- Dedicated community servers
- Housing construction
- Trading or currency
- Day, night, and weather simulation beyond a simple visual test
- Blackjack or other secondary activities
- Advanced character creation
- Voice chat

## Implementation order

1. Create and export an empty Godot project on all target platforms.
2. Add one placeholder room and one movable character.
3. Run the project as a host and connect a second client.
4. Synchronize movement, names, joining, and leaving.
5. Add text chat and basic emotes.
6. Connect the lounge to a placeholder pond.
7. Implement the complete fishing loop using one fish.
8. Make catch data authoritative and persistent.
9. Add the journal and remaining development fish.
10. Replace only the placeholders needed for an external playtest.
