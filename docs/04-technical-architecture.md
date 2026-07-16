# Technical architecture

The choices in this document are the recommended baseline, not irreversible
decisions. Small technical spikes should validate them before production work.

## Client and engine

- Godot 4
- GDScript for initial development
- Compatibility renderer unless a visual requirement demands otherwise
- One project capable of running as a client, listen server, or headless server
- Keyboard and mouse plus complete controller navigation
- Native Windows, macOS, and Linux builds

The game should not depend on Steam for core networking or identity. Platform
integrations can remain optional so all desktop players can share servers.

## Server model

Pond should support two server forms using the same protocol and authoritative
rules:

- A listen server hosted from a player's game
- A headless dedicated server for persistent communities

The prototype starts with direct address joining. Public discovery, NAT
traversal, relays, and invite services are later infrastructure decisions.

Begin with an eight-player development target. The initial long-term target is
approximately 20 players per settlement, subject to playtests and performance
measurements.

## Authority

The server owns:

- Player position validation
- Shared world and activity state
- Fishing outcomes
- Inventory and collection changes
- Public decorations and housing state
- Roles, permissions, mutes, and bans

Clients own local input and presentation. They request actions and render the
accepted result.

Movement can use frequent disposable updates with interpolation. Chat, catches,
inventories, and saves require reliable delivery. A joining player receives a
consistent snapshot followed by incremental updates.

Every connection should negotiate a protocol version. Incompatible versions
must fail with a useful message rather than producing undefined state.

## Persistence and identity

### Prototype

- Locally generated player identifier
- Local appearance, controls, and settings
- Server-owned catches and permissions
- Simple versioned save files
- Atomic save replacement and rotating backups

### Community server stage

- Stable resident records
- Homes and shared town state
- Save migrations between game versions
- Administrative backup and restore commands

A central Pond account service should only be considered after the game proves
it needs portable identity, friends, or collections. Accounts add permanent
security, privacy, hosting, and support obligations.

## Suggested project boundaries

Keep these responsibilities separate even while they live in one Godot project:

- Application startup and mode selection
- Network transport and protocol messages
- Authoritative world simulation
- Player presentation and input
- Activity rules
- Data definitions for fish, items, furniture, and cosmetics
- Persistence and migrations
- User interface
- Audio
- Development diagnostics

Fishing should not be embedded directly into player movement or chat. At the
same time, a general plugin framework should not be invented before a second
activity demonstrates what actually needs to be shared.

## Performance targets

- Stable 60 FPS on modest integrated desktop graphics
- Fast startup and area transitions
- Smooth remote movement under ordinary network latency
- A modest installation and memory footprint
- Headless operation without rendering dependencies

Specific budgets should be set after the first representative map, characters,
and network session can be profiled.
