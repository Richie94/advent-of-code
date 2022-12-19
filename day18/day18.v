import os { read_file }
import arrays { max }

const (
	margin            = 2
	neighbour_actions = [
		[1, 0, 0],
		[0, 1, 0],
		[0, 0, 1],
		[-1, 0, 0],
		[0, -1, 0],
		[0, 0, -1],
	]
)

fn main() {
	f := read_file('input.txt')!
	max_x := max(f.split('\n').map(it.split(',')[0].int()))!
	max_y := max(f.split('\n').map(it.split(',')[1].int()))!
	max_z := max(f.split('\n').map(it.split(',')[2].int()))!

	mut grid := [][][]int{len: max_x + 2 * margin, init: [][]int{len: max_y + 2 * margin, init: []int{len:
		max_z + 2 * margin}}}

	// fill grid
	for line in f.split('\n') {
		x, y, z := parse_line(line)
		grid[x][y][z] = 1
	}

	part1(f, grid)
	part2(f, grid)
}

fn part1(f string, grid [][][]int) {
	// iterate over positions and find empty neighbours
	mut surface := 0
	for line in f.split('\n') {
		x, y, z := parse_line(line)

		for n in neighbour_actions {
			if grid[x + n[0]][y + n[1]][z + n[2]] == 0 {
				surface += 1
			}
		}
	}

	println(surface)
}

fn part2(f string, grid [][][]int) {
	max_x := grid.len
	max_y := grid[0].len
	max_z := grid[0][0].len

	// explore all with dfs, mark reachable
	mut reachable := []string{}
	mut stack := ['0,0,0']
	for stack.len > 0 {
		line := stack.pop()
		reachable << line
		x, y, z := parse_line_unmodified(line)
		for n in neighbour_actions {
			if x + n[0] >= 0 && y + n[1] >= 0 && z + n[2] >= 0 && x + n[0] < max_x
				&& y + n[1] < max_y && z + n[2] < max_z {
				if grid[x + n[0]][y + n[1]][z + n[2]] == 0 {
					if '${x + n[0]},${y + n[1]},${z + n[2]}' !in reachable {
						stack << '${x + n[0]},${y + n[1]},${z + n[2]}'
					}
				}
			}
		}
	}

	mut surface := 0
	for line in f.split('\n') {
		x, y, z := parse_line(line)

		for n in neighbour_actions {
			if grid[x + n[0]][y + n[1]][z + n[2]] == 0 {
				if '${x + n[0]},${y + n[1]},${z + n[2]}' in reachable {
					surface += 1
				}
			}
		}
	}

	println(surface)
}

// handle index 0 by pushing all items + margin
fn parse_line(line string) (int, int, int) {
	nums := line.split(',').map(it.int())
	return nums[0] + margin, nums[1] + margin, nums[2] + margin
}

fn parse_line_unmodified(line string) (int, int, int) {
	nums := line.split(',').map(it.int())
	return nums[0], nums[1], nums[2]
}
