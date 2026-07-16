# World assets

`pond_commons_background.png` is the production-bound background for the
current single-screen prototype. It was generated with the built-in image tool
using the running Godot scene as an exact layout reference.

The source is 1672×941 and is displayed by Godot in a 640×360 `TextureRect`
using nearest-neighbor filtering. Collision and player movement remain separate
from the image.

This is intentionally a baked background while the core multiplayer and
fishing loop are being proven. Once the world needs transitions, housing plots,
or editable public decoration, it should be decomposed into an original
tileset, prop atlas, and foreground occlusion layers.
