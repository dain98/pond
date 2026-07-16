# Art and audio direction

## Visual goals

- Top-down pixel art
- Expressive character silhouettes and animation
- Warm, readable lighting
- Detailed environments that do not obscure players
- Strong differences between indoor and outdoor atmosphere
- Clean integer-friendly scaling at common desktop resolutions
- Modular customization without visual seams

CrossCode can inform visual density, movement readability, and environmental
craft, while Pond must develop its own characters, assets, world, and visual
language. WEBFISHING can inform the relaxed social rhythm without defining
Pond's mechanics or presentation.

## Art production strategy

Before committing to a full asset pipeline, create a small art test containing:

- One section of lounge
- One outdoor shoreline
- Two customizable characters
- Walking, sitting, casting, and catch-reveal animations
- Representative furniture and water
- Day and evening lighting

Use placeholders elsewhere until this test establishes tile scale, character
proportions, palette behavior, animation scope, and target resolution.

Content should be data-driven. Adding a fish, cosmetic, or furniture item
should normally involve an asset and a definition rather than new gameplay
code.

## Animation priorities

Social readability matters more than animation quantity. Prioritize:

1. Movement and facing
2. Sitting and idle variation
3. Casting and reeling
4. Catch reveals
5. Emotes
6. Object interactions

Small reactions between players can make the space feel more alive than highly
elaborate solo animation.

## Audio goals

Audio should create warmth while leaving room for conversation.

Early priorities:

- Water and shoreline ambience
- Rain and indoor weather attenuation
- Footsteps by surface
- Casting, bites, reeling, and catches
- Doors, chairs, and small interactions
- Restrained interface feedback
- Distinct cafe, bar, and nighttime ambience

Music should be gentle, optional, and independently adjustable. Location-based
music or radios may later become part of server and home customization.
