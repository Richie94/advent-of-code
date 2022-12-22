import os { read_file }
import math { max }
import arrays
import regex

fn main() {
	file_name := 'input.txt'
	println('Part 1 ${solve(file_name, true) or { panic(err) }}')
	println('Part 2 ${solve(file_name, false) or { panic(err) }}')
}

fn change_dir(from string, move string) string {
	if move == 'L' {
		match from {
			'R' { return 'U' }
			'U' { return 'L' }
			'L' { return 'B' }
			'B' { return 'R' }
			else { panic('Unknown ${from}') }
		}
	} else {
		match from {
			'R' { return 'B' }
			'U' { return 'R' }
			'L' { return 'U' }
			'B' { return 'L' }
			else { panic('Unknown ${from}') }
		}
	}
}

fn apply_cmd(cmd string, grid map[string]rune, position string, facing string, x_len int, y_len int, flat_map bool, appearances map[string]Edge) (string, string) {
	if cmd in ['L', 'R'] {
		return position, change_dir(facing, cmd)
	} else {
		mut updated_facing := facing
		mut last_valid := position

		mut steps := 0

		mut new_x := position.split(',')[0].int()
		mut new_y := position.split(',')[1].int()

		for steps < cmd.int() {
			key := '${new_x},${new_y},${updated_facing}'
			// println(key)
			if !flat_map && key in appearances {
				// check where we land and if its blocked
				next := appearances[key]

				new_x = next.x
				new_y = next.y
				updated_facing = next.facing
			} else {
				mut x_move := 0
				mut y_move := 0
				match updated_facing {
					'R' { x_move = 1 }
					'L' { x_move = -1 }
					'U' { y_move = -1 }
					'B' { y_move = 1 }
					else { panic('Unknown ${updated_facing}') }
				}

				new_x += x_move
				new_y += y_move

				if flat_map {
					new_x = new_x % x_len
					new_y = new_y % y_len

					for new_x < 0 {
						new_x += x_len
					}

					for new_y < 0 {
						new_y += y_len
					}
				}
			}

			new_pos := '${new_x},${new_y}'
			g := grid[new_pos]
			match g {
				`.` {
					steps += 1
					last_valid = new_pos
				}
				`#` {
					return last_valid, updated_facing
				}
				else {
					// P1: we have to walk until the next matching . or #
					// so we skip here, will be done by logic above
				}
			}
		}

		return last_valid, updated_facing
	}
}

struct Edge {
	x      int
	y      int
	facing string
}

fn get_appearances() map[string]Edge {
	// solution here hardcoded for my puzzle
	//   1 2
	//   3
	// 5 4
	// 6
	mut appearances := map[string]Edge{}

	// 1 -> 3, 3 -> 1	
	for x in 50 .. 100 {
		appearances['${x},0,U'] = Edge{0, x + 100, 'R'}
		appearances['0,${x + 100},L'] = Edge{x, 0, 'B'}
	}
	// 2 -> 3, 3 -> 2
	for x in 100 .. 150 {
		appearances['${x},0,U'] = Edge{x - 100, 199, 'U'}
		appearances['${x - 100},199,B'] = Edge{x, 0, 'B'}
	}
	// 5 -> 4, 4 -> 5
	for x in 0 .. 50 {
		appearances['${x},100,U'] = Edge{50, 50 + x, 'R'}
		appearances['50,${x + 50},L'] = Edge{x, 100, 'B'}
	}
	// 2 -> 6, 6 -> 2
	for y in 0 .. 50 {
		appearances['149,${y},R'] = Edge{99, 149 - y, 'L'}
		appearances['99,${149 - y},R'] = Edge{149, y, 'L'}
	}

	// 6 -> 3, 3 -> 6
	for y in 150 .. 200 {
		appearances['49,${y},R'] = Edge{y - 100, 149, 'U'}
		appearances['${y - 100},149,B'] = Edge{49, y, 'L'}
	}
	// 5 -> 1, 1 -> 5
	for y in 100 .. 150 {
		appearances['0,${y},L'] = Edge{50, 149 - y, 'R'}
		appearances['50,${149 - y},L'] = Edge{0, y, 'R'}
	}

	// 2 -> 4, 4 -> 2
	for x in 100 .. 150 {
		appearances['${x},49,B'] = Edge{99, x - 50, 'L'}
		appearances['99,${x - 50},R'] = Edge{x, 49, 'U'}
	}

	return appearances
}

fn solve(file_name string, flatmap bool) !int {
	f := read_file(file_name)!.split('\n\n')
	cmds := parse_commands(f[1])
	grid, start_x, x_len, y_len := parse_grid(f[0])
	appearances := get_appearances()

	mut facing := 'R'
	mut position := '${start_x},0'

	for idx, cmd in cmds {
		position, facing = apply_cmd(cmd, grid, position, facing, x_len, y_len, flatmap,
			appearances)
		// println("$idx ${position.split(",")[1]} ${position.split(",")[0]}")
	}
	row := position.split(',')[1].int() + 1
	column := position.split(',')[0].int() + 1
	f_score := match facing {
		'R' { 0 }
		'D' { 1 }
		'L' { 2 }
		'U' { 3 }
		else { panic('Invalid facing') }
	}

	return 1000 * row + 4 * column + f_score
}

fn parse_grid(g string) (map[string]rune, int, int, int) {
	mut grid := map[string]rune{}
	mut start_x := -1
	x_len := arrays.max(g.split('\n').map(it.len)) or { panic(err) }
	y_len := g.split('\n').len

	for y, line in g.split('\n') {
		for x, r in line.runes() {
			grid['${x},${y}'] = r

			if y == 0 && start_x == -1 && r == `.` {
				start_x = x
			}
		}

		if line.runes().len < x_len {
			for x in line.runes().len .. x_len {
				grid['${x},${y}'] = ` `
			}
		}
	}

	return grid, start_x, x_len, y_len
}

fn parse_commands(g string) []string {
	mut re := regex.regex_opt('(\\d.*[A-Z])') or { panic(err) }
	re.match_string(g)
	mut result := []string{}
	for m in re.find_all_str(g) {
		if m#[-1..] in ['L', 'R'] {
			result << m#[..-1]
			result << m#[-1..]
		} else {
			result << m
		}
	}
	return result
}

fn print_grid(grid map[string]rune, position string, x_len int, y_len int) string {
	mut result := ''
	for y in 0 .. y_len {
		for x in 0 .. x_len {
			pos_str := '${x},${y}'
			if pos_str == position {
				result += '@'
			} else {
				result += grid[pos_str].str()
			}
		}
		result += '\n'
	}
	result += '\n'
	return result
}
