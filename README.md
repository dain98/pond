# Pond

Pond is a lightweight multiplayer social space where people gather, talk, and
fish together.

The project is currently at its first technical milestone: host or join a
session and move multiple placeholder players around the same room.

## Requirements

- [Godot 4.7](https://godotengine.org/download/archive/4.7-stable/) standard
  edition
- Windows, macOS, or Linux

## Run locally

Open `project.godot` in Godot and press **F6** or **F5**. To test multiplayer on
one computer:

1. Run one instance and select **Host**.
2. Run a second instance, leave the address as `127.0.0.1`, and select **Join**.
3. Move each player with WASD, the arrow keys, or the left controller stick.

Pond currently uses UDP port `43117`. A remote host must allow that port through
its firewall and network configuration.

## Command line

Start a headless host:

```sh
godot --headless --path . -- --server --name=Host
```

Join it with another process:

```sh
godot --headless --path . -- --join=127.0.0.1 --name=Guest
```

Set `GODOT_BIN` and run the automated two-process smoke test:

```sh
GODOT_BIN=/path/to/godot scripts/smoke_test.sh
```

Validate project loading and script parsing:

```sh
GODOT_BIN=/path/to/godot scripts/check_project.sh
```

On Linux, rendered regression tests run inside a virtual X display and leave
their screenshots in `artifacts/visual/`:

```sh
GODOT_BIN=/path/to/godot scripts/visual_test.sh
```

The visual test requires `xvfb-run`. Intentionally update its committed
baselines after reviewing the new screenshots with:

```sh
UPDATE_BASELINES=1 GODOT_BIN=/path/to/godot scripts/visual_test.sh
```

All three checks run automatically in GitHub Actions on pushes and pull
requests. Failed visual checks upload their actual and difference images as CI
artifacts.

Project planning lives in [docs/README.md](docs/README.md).
