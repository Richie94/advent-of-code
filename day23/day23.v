import os { read_file }
import arrays { map_of_counts, max, min }

fn main() {
	file_name := 'input.txt'
	mut grid := parse_grid(file_name)!
	mut round := 0
	for true {
		rmoves := requested_moves(grid, round)

		if rmoves.len == 0 {
			println("Part2 $round")
			return
		}
		counts := map_of_counts(rmoves.values())

		for elve, target in rmoves {
			if counts[target] == 1 {
				grid[target] = `#`
				grid.delete(elve)
			}
		}

		if round == 9 {
			score_part1(grid)
		}

		round += 1
	}

}

fn score_part1(grid map[string]rune) {
	// get min and max x and y
	all_x := grid.keys().map(it.split(',')[0].int())
	all_y := grid.keys().map(it.split(',')[1].int())
	min_x := min(all_x) or { panic(err) }
	max_x := max(all_x) or { panic(err) }
	min_y := min(all_y) or { panic(err) }
	max_y := max(all_y) or { panic(err) }

	mut result := (max_x - min_x + 1) * (max_y - min_y + 1) - grid.len

	println("Part1: $result")
}

fn requested_moves(grid map[string]rune, round int) map[string]string {
	mut moves := map[string]string{}

	for elve, _ in grid {
		if !is_alone(elve, grid) {
			mut did_move := false
			for dir in 0 .. 4 {
				dir_idx := (dir + round) % 4
				if !did_move && can_go(dir_idx, elve, grid) {
					did_move = true
					moves[elve] = go_dir(dir_idx, elve)
				}
			}
		}
	}
	return moves
}

fn go_dir(direction int, elve string) string {
	x, y := get_xy(elve)

	match direction {
		0 { return '${x},${y - 1}' }
		1 { return '${x},${y + 1}' }
		3 { return '${x + 1},${y}' }
		2 { return '${x - 1},${y}' }
		else { panic('Invalid direction ${direction}') }
	}
}

fn can_go(direction int, elve string, grid map[string]rune) bool {
	x, y := get_xy(elve)

	match direction {
		0 {
			for xn in [-1, 0, 1] {
				if '${x + xn},${y - 1}' in grid {
					return false
				}
			}
		}
		1 {
			for xn in [-1, 0, 1] {
				if '${x + xn},${y + 1}' in grid {
					return false
				}
			}
		}
		3 {
			for yn in [-1, 0, 1] {
				if '${x + 1},${y + yn}' in grid {
					return false
				}
			}
		}
		2 {
			for yn in [-1, 0, 1] {
				if '${x - 1},${y + yn}' in grid {
					return false
				}
			}
		}
		else {
			panic('Invalid direction ${direction}')
		}
	}

	return true
}

fn is_alone(elve string, grid map[string]rune) bool {
	x, y := get_xy(elve)

	for xn in [-1, 0, 1] {
		for yn in [-1, 0, 1] {
			if '${x + xn},${y + yn}' in grid && !(xn == 0 && yn == 0){
				return false
			}
		}
	}
	return true
}

fn parse_grid(file_name string) !map[string]rune {
	f := read_file(file_name)!
	mut grid := map[string]rune{}
	for y, line in f.split('\n') {
		for x, r in line.runes() {
			if r == `#` {
				grid['${x},${y}'] = r
			}
		}
	}

	return grid
}

fn get_xy(elve string) (int, int) {
	x := elve.split(',')[0].int()
	y := elve.split(',')[1].int()
	return x, y
}
