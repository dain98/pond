# Development roadmap

Progress is organized by proof, not by a speculative calendar. Each milestone
must be playable and testable before the next one expands the scope.

| Milestone | Goal | Completion test |
| --- | --- | --- |
| 0. Foundation | Establish the project and platform boundaries | All three desktop platforms launch the same empty build |
| 1. Shared room | Prove multiplayer immediately | Two players connect, move smoothly, and disconnect safely |
| 2. Social prototype | Make the room feel inhabited | Players chat, emote, customize themselves, and move between lounge and pond |
| 3. Fishing prototype | Prove the central activity | Players cast, catch fish, and see one another fishing |
| 4. First playable | Form a coherent small game | A group can join, socialize, fish, collect catches, and reconnect |
| 5. Community servers | Support recurring groups | Headless servers save state and provide moderation tools |
| 6. Homes | Add personal spaces | Residents claim, decorate, save, archive, and visit homes |
| 7. Town expansion | Deepen the commons | Cafe, bar, game room, events, and public decoration work |
| 8. Second activity | Prove extensibility beyond fishing | A shared table game works for participants and observers |
| 9. Release preparation | Make Pond safely distributable | Builds, accessibility, moderation, recovery, and performance meet release targets |

## Milestone 0: Foundation

- Establish repository and documentation conventions.
- Create the Godot project.
- Verify local exports on Windows, macOS, and Linux.
- Add automated builds when the project structure stabilizes.
- Establish debug builds, logging, and data validation.

## Milestone 1: Shared room

- One placeholder map and character
- Player spawning and authoritative movement
- Remote interpolation
- Player names
- Direct address joining
- Graceful joining and disconnection
- Protocol version checking
- Basic connection diagnostics

## Milestone 2: Social prototype

- Text chat and message limits
- Emotes, sitting, and facing
- Simple character variation
- Lounge and pond areas
- Player list
- Host moderation controls

## Milestone 3: Fishing prototype

- Valid fishing locations
- Casting, waiting, bites, reeling, and catches
- Server-selected fish
- Catch reveal visible to nearby players
- Inventory and journal entries
- Five development species

## Milestone 4: First playable

- One presentable lounge and pond
- Approximately 20 fish
- Basic ambience and sound
- Character customization
- Catch journal and a simple display
- Settings and onboarding
- Versioned local and server persistence
- Reconnection handling
- Regular external playtests

## Milestones 5 through 9

Later milestones add dedicated community operation, resident housing, a richer
town, a second activity, and release hardening in that order. Their scope should
be revised using evidence from first-playable sessions rather than treated as a
fixed feature contract today.
