# Core game systems

## Player movement and interaction

Movement should feel responsive with keyboard, mouse, and controller. Players
can walk, face one another, sit, emote, and interact with nearby objects. The
world should clearly indicate valid interactions without filling the screen
with prompts.

Controller-first menu navigation is valuable for Steam Deck and leaves a path
open for Android handhelds later, without making Android a current target.

## Social presence

The first social toolset consists of:

- Player names and readable nameplates
- Text chat with history and rate limits
- Quick emotes
- Sitting and facing controls
- A player list
- Mute, kick, and ban controls
- Visible states for fishing, sitting, and participating in activities

Voice chat should wait until the project can support its privacy, moderation,
networking, and platform requirements.

## Fishing

Fishing must be calm enough to support conversation but active enough to feel
satisfying.

### Basic loop

1. Equip a rod.
2. Aim and cast into valid water.
3. Wait while remaining able to chat and observe the world.
4. Respond to a visible and audible bite.
5. Complete a short timing or reeling interaction.
6. Reveal the catch to nearby players.
7. Add it to the inventory and journal, or release it.

The server chooses and validates catches. A client reports player actions, not
the fish it claims to have received.

### Fish data

Fish definitions should be data-driven and include:

- Stable identifier and display name
- Visual appearance and possible variations
- Size range
- Rarity
- Valid locations
- Time and weather conditions
- Lure or bait preferences when those systems exist
- Catch difficulty
- Journal description

Individual catches can record species, size, appearance, place, time, and the
player who caught them. These details turn a catch into something worth showing
other people.

## Collection and progression

Early progression consists of a journal and a simple display or aquarium.
Longer-term rewards can include clothing, furniture, rods, emotes, titles, and
aquarium pieces.

Avoid stamina, mandatory daily tasks, punishing decay, and numerical power
curves. A reward should ideally create a new way to express oneself or a new
story to share.

## Character customization

A modular character can eventually combine:

- Base body
- Eyes and facial details
- Hair or head shape
- Top
- Bottom
- Shoes
- Hat
- Accessory
- Held item

The prototype only needs enough variation to distinguish connected players.
The full system should be driven by compatible layers and stable item IDs so
new cosmetics do not require code changes.
