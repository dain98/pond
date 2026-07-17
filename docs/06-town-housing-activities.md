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

### Prototype settlement base map

The current 1920×1080 master map turns this diagram into nine connected camera
regions:

- The central crossroads joins the lounge, bulletin board, main pond dock, and
  southern social row.
- The western loop contains resident plots while still routing foot traffic
  back through the commons.
- The northern woods contain two bridged creek branches and a quieter fishing
  approach.
- The eastern shoreline adds two docks, bank-fishing space, picnic clearings,
  and a woodland loop.
- The southern row gives the cafe, bar, and game room distinct physical spaces
  beside a flexible public event lawn.

The illustrated map remains a prototype master texture, but gameplay geometry
is already separate in `scripts/world_geometry.gd`. Water, bridges, docks,
building walls, world limits, and major wooded obstacles can therefore evolve
without coupling server rules to the rendered image. The next art-production
step is to decompose the approved layout into ground tiles, structures, props,
and foreground occlusion layers.

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
