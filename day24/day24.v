import os { read_file }
import time

fn main() {
	file_name := 'input.txt'
	sw := time.new_stopwatch()

	mut grid, x_len, y_len := parse_grid(file_name)!

	// we make some bfs, so we dont need to recalculate or save the blizzard positions
	mut queue := [State{1, 0, 0}]

	mut goals := [Point{x_len - 2, y_len - 1}, Point{1, 0}, Point{x_len - 2, y_len - 1}]

	for queue.len > 0 {
		// simulate blizzards
		mut new_grid := map[string][]rune{}
		for bliz, dirs in grid {
			x, y := get_xy(bliz)
			for dir in dirs {
				mut new_x := x
				mut new_y := y
				match dir {
					`<` {
						new_x -= 1
						if new_x == 0 {
							new_x = x_len - 2
						}
					}
					`>` {
						new_x += 1
						if new_x == x_len - 1 {
							new_x = 1
						}
					}
					`^` {
						new_y -= 1
						if new_y == 0 {
							new_y = y_len - 2
						}
					}
					`v` {
						new_y += 1
						if new_y == y_len - 1 {
							new_y = 1
						}
					}
					else {
						panic('Unknown ${dir}')
					}
				}
				new_grid['${new_x},${new_y}'] << dir
			}
		}

		grid = new_grid.clone()

		mut next_queue := []State{}
		mut reached_goal := false
		// println(queue)
		// check all my options
		for state in queue {
			for move in [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]] {
				mut new_x := state.x + move[0]
				mut new_y := state.y + move[1]

				if reached_goal {
					continue
				}

				if new_x == goals[0].x && new_y == goals[0].y {
					println("Goal ${goals[0].x},${goals[0].y}: ${state.time + 1} ('${sw.elapsed().milliseconds()}ms')")
					next_queue = [State{new_x, new_y, state.time + 1}]
					reached_goal = true
					if goals.len > 1 {
						goals.delete(0)
					} else {
						return
					}
				} else if (0 < new_x && new_x <= x_len - 2 && 0 < new_y && new_y <= y_len - 2)
					|| (new_x == 1 && new_y == 0)
					|| (new_x == x_len - 2 && new_y == y_len - 1) {
					new_state := State{new_x, new_y, state.time + 1}
					if grid['${new_x},${new_y}'].len == 0 {
						if new_state !in next_queue {
							next_queue << new_state
						}
					}
				}
			}
		}
		queue = next_queue.clone()
	}
}

struct Point {
	x int
	y int
}

struct State {
	x    int
	y    int
	time int
}

fn parse_grid(file_name string) !(map[string][]rune, int, int) {
	mut grid := map[string][]rune{}
	f := read_file(file_name)!.split('\n')
	y_len := f.len
	x_len := f[0].len

	for y, line in f {
		for x, r in line.runes() {
			if r in [`<`, `>`, `^`, `v`] {
				grid['${x},${y}'] << r
			}
		}
	}

	return grid, x_len, y_len
}

fn get_xy(bliz string) (int, int) {
	x := bliz.split(',')[0].int()
	y := bliz.split(',')[1].int()
	return x, y
}
