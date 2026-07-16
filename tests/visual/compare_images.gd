extends SceneTree

const CHANNEL_TOLERANCE := 8.0 / 255.0
const MAX_DIFFERENT_PIXEL_RATIO := 0.02
const MAX_MEAN_CHANNEL_DIFFERENCE := 0.005


func _init() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() != 3:
		printerr("Usage: compare_images.gd EXPECTED ACTUAL DIFFERENCE")
		quit(2)
		return

	var expected := _load_image(arguments[0])
	var actual := _load_image(arguments[1])
	if expected == null or actual == null:
		quit(2)
		return

	if expected.get_size() != actual.get_size():
		printerr(
			"Visual dimensions differ: expected %s, actual %s"
			% [expected.get_size(), actual.get_size()]
		)
		quit(1)
		return

	var difference := Image.create(
		expected.get_width(),
		expected.get_height(),
		false,
		Image.FORMAT_RGBA8
	)
	var different_pixels := 0
	var total_channel_difference := 0.0
	var total_pixels := expected.get_width() * expected.get_height()

	for y in expected.get_height():
		for x in expected.get_width():
			var expected_color := expected.get_pixel(x, y)
			var actual_color := actual.get_pixel(x, y)
			var red_difference := absf(expected_color.r - actual_color.r)
			var green_difference := absf(expected_color.g - actual_color.g)
			var blue_difference := absf(expected_color.b - actual_color.b)
			var largest_difference := maxf(
				red_difference,
				maxf(green_difference, blue_difference)
			)

			total_channel_difference += (
				red_difference + green_difference + blue_difference
			)
			if largest_difference > CHANNEL_TOLERANCE:
				different_pixels += 1
				difference.set_pixel(
					x,
					y,
					Color(minf(largest_difference * 4.0, 1.0), 0.0, 0.0, 1.0)
				)
			else:
				difference.set_pixel(x, y, Color(0.0, 0.0, 0.0, 1.0))

	var different_ratio := float(different_pixels) / float(total_pixels)
	var mean_channel_difference := total_channel_difference / float(total_pixels * 3)
	var save_error := difference.save_png(arguments[2])
	if save_error != OK:
		printerr("Could not save difference image: %s" % arguments[2])

	print(
		"Visual comparison: %.3f%% pixels differ; mean channel difference %.5f"
		% [different_ratio * 100.0, mean_channel_difference]
	)

	if (
		different_ratio > MAX_DIFFERENT_PIXEL_RATIO
		or mean_channel_difference > MAX_MEAN_CHANNEL_DIFFERENCE
	):
		printerr("Visual regression exceeded the configured tolerance.")
		quit(1)
		return

	quit(0)


func _load_image(path: String) -> Image:
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		printerr("Could not load image: %s (error %d)" % [path, error])
		return null
	return image
