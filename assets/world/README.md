# World assets

`pond_settlement_base.png` is the active production-bound master background for
the current prototype. It was generated with the built-in image tool using the
earlier commons maps and the town design documents as layout and style
references.

The source is 1672×941 and represents a 1920×1080 game world—nine native
640×360 camera viewports. Godot displays it in a 1920×1080 `TextureRect` using
nearest-neighbor filtering. Authoritative collision lives separately in
`scripts/world_geometry.gd`, so the headless server does not depend on rendered
assets. Earlier commons backgrounds are retained as source and progression
references.

This is intentionally a baked background while the core multiplayer and fishing
loop are being proven. Once the world needs transitions, housing plots, or
editable public decoration, it should be decomposed into an original tileset,
prop atlas, and foreground occlusion layers.
