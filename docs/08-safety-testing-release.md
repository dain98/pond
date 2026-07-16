# Safety, testing, and release

## Moderation and safety

Even a small alpha needs basic social safeguards:

- Mute and block
- Kick and ban
- Host and moderator roles
- Message length and rate limits
- Player name validation
- Server rules visible before or immediately after joining
- Permission checks for every shared edit
- No trust in client-reported catches, inventory, or ownership

Public discovery, voice chat, user-authored signs, and unrestricted uploads
should wait until the corresponding reporting and moderation tools exist.

## Testing levels

Every milestone should be exercised in three environments:

- Solo, including running a local host with no guests
- Multiple local clients against one server
- Separate computers over a real network

Cross-platform testing should begin during the shared-room milestone. Waiting
until release makes networking, filesystem, input, and rendering differences
far more expensive to correct.

## Failure cases

Test these deliberately:

- A player disconnects while fishing or in an activity.
- The host closes unexpectedly.
- The server restarts during a save.
- A client uses an incompatible protocol version.
- Two players interact with the same object simultaneously.
- A player joins while an activity is already underway.
- Save data comes from an older game version.
- A home references removed or renamed furniture.
- A client spams movement, chat, or interaction requests.
- A player reconnects after a temporary network interruption.

Automate data validation, save migrations, and deterministic rule tests where
practical. Human playtests remain essential for conversation flow, movement,
fishing feel, and social density.

## Distribution readiness

Before a public release, Pond needs:

- Repeatable Windows, macOS, and Linux builds
- Code signing and notarization where applicable
- Versioned client and server compatibility rules
- Configurable controls and controller navigation
- Separate volume controls and readable text options
- Crash reporting that respects player privacy
- Backup and recovery documentation for server operators
- Clear logs without secrets or unnecessary personal information
- Performance measurements on representative low-end hardware
- A process for security and moderation reports

Storefront integration should remain separate from core identity and
networking, preserving direct cross-platform play.
