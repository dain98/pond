# Town, housing, and activities

## Settlement layout

Each server is a compact settlement organized around a shared commons.

```text
                    Player homes
                 /        |       \
              Neighborhood paths
                        |
     Pond -------- Town commons -------- Park
                        |
             Bar - Cafe - Game room
```

Players should naturally pass through the commons while moving between homes,
the pond, and other destinations. This preserves social density even on a small
server.

## Public spaces

- The cafe supports quiet conversation and ambient events.
- The bar supports evening gatherings, music, trivia, and table games.
- The game room contains multiplayer tables and arcade-style activities.
- The pond provides fishing spots, docks, weather, and shared discoveries.
- A park, bulletin board, or public aquarium can display community activity.

Public spaces retain the most communal activities. Homes can host smaller
groups but should not make the town unnecessary.

## Residency and homes

Visitors can join a server easily. With permission, regular players become
residents and claim one of the settlement's plots.

The first housing system should use modular construction:

- Exterior templates and a limited plot footprint
- Separately loaded interiors
- Grid-based furniture placement
- Flooring and wallpaper
- Fish, photographs, trophies, and aquariums
- Lighting and music preferences
- Visitor, friend, and editor permissions
- Reliable saving and recovery

Separate interiors keep rendering and replication light, allow interiors to be
larger than their exterior footprint, and isolate heavily decorated spaces.

Inactive homes should be archived into restorable blueprints rather than
deleted. This lets a server reclaim limited plots without destroying a
resident's work.

## Shared town ownership

Server owners and delegated moderators can eventually control:

- Settlement name, description, and rules
- Resident and guest permissions
- Plot availability
- Public furniture and decoration
- Music or radio settings
- Allowed activities
- Moderator roles

Collaborative public decoration needs explicit permissions and a history or
recovery mechanism before it is exposed broadly.

## Activity lifecycle

Activities should feel like physical parts of the town:

1. Approach an activity in the world.
2. Join as a participant or observer.
3. Temporarily change controls and interface.
4. Synchronize activity-specific state through the server.
5. Leave immediately and return to normal movement.

Fishing establishes the first activity boundary. A second activity should then
identify which interfaces genuinely deserve to be generalized.

Blackjack is a strong candidate because it supports participants, spectators,
conversation, and a recognizable physical table. It should use fictional,
non-purchasable chips with no cash-out or real-money value.
