class_name FisherSpriteFrames
extends RefCounted

const SOURCE_SHEET := preload("res://assets/characters/fisher_sheet.png")
const FRAME_SIZE := Vector2i(112, 112)
const FRAME_X := [196, 332, 468, 604]
const ANIMATION_ROWS := {
	&"down": 448,
	&"side": 560,
	&"up": 664,
}
const BACKGROUND_MINIMUM := 0.88
const BACKGROUND_NEUTRAL_RANGE := 0.035

static var _cached_frames: SpriteFrames


static func get_frames() -> SpriteFrames:
	if _cached_frames:
		return _cached_frames

	var source_image := SOURCE_SHEET.get_image()
	_cached_frames = SpriteFrames.new()
	_cached_frames.remove_animation(&"default")

	for animation_name: StringName in ANIMATION_ROWS:
		_cached_frames.add_animation(animation_name)
		_cached_frames.set_animation_loop(animation_name, true)
		_cached_frames.set_animation_speed(animation_name, 9.0)

		for frame_x: int in FRAME_X:
			var region := Rect2i(
				Vector2i(frame_x, ANIMATION_ROWS[animation_name]),
				FRAME_SIZE
			)
			var frame_image := source_image.get_region(region)
			_remove_checkerboard(frame_image)
			var frame_texture := ImageTexture.create_from_image(frame_image)
			_cached_frames.add_frame(animation_name, frame_texture)

	return _cached_frames


static func _remove_checkerboard(image: Image) -> void:
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			var lowest := minf(color.r, minf(color.g, color.b))
			var highest := maxf(color.r, maxf(color.g, color.b))
			if (
				color.a < 0.5
				or (
					lowest >= BACKGROUND_MINIMUM
					and highest - lowest <= BACKGROUND_NEUTRAL_RANGE
				)
			):
				color.a = 0.0
			else:
				color.a = 1.0
			image.set_pixel(x, y, color)
