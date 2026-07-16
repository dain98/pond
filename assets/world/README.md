# World assets

`pond_commons_expanded.png` is the active production-bound background for the
current prototype. It was generated with the built-in image tool using the
original running Godot scene and `pond_commons_background.png` as layout and
style references.

The source is 1672×941 and represents a 1280×720 game world—four native
640×360 camera viewports. Godot displays it in a 1280×720 `TextureRect` using
nearest-neighbor filtering. Collision, player movement, and camera limits remain
separate from the image. `pond_commons_background.png` is retained as the
original single-screen source asset.

This is intentionally a baked background while the core multiplayer and fishing
loop are being proven. Once the world needs transitions, housing plots, or
editable public decoration, it should be decomposed into an original tileset,
prop atlas, and foreground occlusion layers.
