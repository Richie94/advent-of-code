import os
import arrays
import time

struct Point {
	x int
	y int
}

struct Rock {
mut:
	parts   []Point
	y_range []int
}

fn create_rock(shape int, y int) Rock {
	if shape == 0 {
		// ----
		return Rock{[Point{2, y}, Point{3, y}, Point{4, y}, Point{5, y}], [y]}
	} else if shape == 1 {
		// +
		return Rock{[Point{3, y}, Point{2, y + 1}, Point{3, y + 1},
			Point{4, y + 1}, Point{3, y + 2}], [y, y + 1, y + 2]}
	} else if shape == 2 {
		// reverse L
		return Rock{[Point{2, y}, Point{3, y}, Point{4, y}, Point{4, y + 1},
			Point{4, y + 2}], [y, y + 1, y + 2]}
	} else if shape == 3 {
		// I
		return Rock{[Point{2, y}, Point{2, y + 1}, Point{2, y + 2},
			Point{2, y + 3}], [y, y + 1, y + 2, y + 3]}
	} else {
		// block
		return Rock{[Point{2, y}, Point{2, y + 1}, Point{3, y},
			Point{3, y + 1}], [y, y + 1]}
	}
}

fn move_part(cmd string, p Point) Point {
	if cmd == 'left' {
		return Point{p.x - 1, p.y}
	} else if cmd == 'right' {
		return Point{p.x + 1, p.y}
	} else {
		return Point{p.x, p.y - 1}
	}
}

fn (r Rock) move(cmd string, other_rocks []Rock) Rock {
	move := fn [cmd] (p Point) Point {
		return move_part(cmd, p)
	}
	new_points := r.parts.map(move)

	// check border collision
	if new_points.any(it.x < 0) || new_points.any(it.x > 6) {
		return r
	}

	if new_points.any(it.y <= 0) {
		return r
	}

	y_range := arrays.group_by(new_points.map(it.y), fn (i int) int {
		return i
	}).keys()

	in_range := fn [y_range] (i int) bool {
		return i in y_range
	}
	collides_with := fn [new_points] (p Point) bool {
		return p in new_points
	}

	// filter relevant rocks and check collision
	for other in other_rocks {
		if other.y_range.any(in_range) {
			if other.parts.any(collides_with) {
				return r
			}
		}
	}

	return Rock{new_points, y_range}
}

fn main() {
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	debug := false

	rocks := [0, 1, 2, 3, 4]

	mut round := 0
	mut rock_counter := 0
	mut other_rocks := []Rock{}
	mut current_rock := []Rock{}
	mut max_y := 0

	sw := time.new_stopwatch()
	
	for other_rocks.len < 2022 {
		push_rune := f.runes()[round % f.len]
		round += 1

		// spawn new rock if necessary
		if current_rock.len == 0 {
			new_shape := rocks[rock_counter]
			new_y := max_y + 4
			current_rock = [create_rock(new_shape, new_y)]
			rock_counter = (rock_counter + 1) % rocks.len
		}

		mut cmd := ''
		if push_rune == `<` {
			cmd = 'left'
		} else if push_rune == `>` {
			cmd = 'right'
		}

		pushed_rock := current_rock[0].move(cmd, other_rocks)
		if debug {
			println(cmd)
			pushed_max := arrays.max(pushed_rock.y_range) or { 0 }
			visualize(other_rocks, arrays.max([max_y, pushed_max]) or { max_y }, pushed_rock)
			println('down')
		}

		// move down
		down_rock := pushed_rock.move('down', other_rocks)

		// check settling
		if down_rock == pushed_rock {
			other_rocks << down_rock
			current_rock = []
			max_y_current := arrays.max(down_rock.y_range) or { 0 }

			if max_y_current > max_y {
				max_y = max_y_current
			}
			if debug {
				visualize(other_rocks, max_y, Rock{[], []})
			}
		} else {
			current_rock = [down_rock]
			if debug {
				current_max := arrays.max(down_rock.y_range) or { 0 }
				visualize(other_rocks, arrays.max([max_y, current_max]) or { max_y },
					down_rock)
			}
		}
	}
	println(max_y)
	println("took ${sw.elapsed().milliseconds()}ms")
}

fn visualize(rocks []Rock, max_y int, current_rock Rock) {
	mut all_points := []Point{}
	for rock in rocks {
		for p in rock.parts {
			all_points << p
		}
	}

	for y := max_y; y > 0; y -= 1 {
		for x in 0 .. 7 {
			p := Point{x, y}
			if p in all_points {
				print('#')
			} else if p in current_rock.parts {
				print('@')
			} else {
				print('.')
			}
		}
		print('\n')
	}
	println('-------\n')
}
