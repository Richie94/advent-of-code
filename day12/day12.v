import os
import math
import arrays

struct Edge {
	start_enc string
	end_enc   string
	start     string
	end       string
	cost      int
}

fn main() {
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	mut edges := []Edge{}
	lines := f.split('\n')
	x_len := lines.len
	y_len := lines[0].len

	mut start_point := ''
	mut end_point := ''

	for x, line in lines {
		// test always to right and down
		for y, r in line {
			mut elevation := get_elevation([r].bytestr())
			if r == 83 {
				start_point = '${x}-${y}'
			} else if r == 69 {
				end_point = '${x}-${y}'
			}

			if y < y_len - 1 {
				other_elevation := get_elevation([line[y + 1]].bytestr())
				if math.abs(elevation - other_elevation) < 2 {
					edges << Edge{'${x}-${y}', '${x}-${y + 1}', [line[y]].bytestr(), [
						line[y + 1],
					].bytestr(), 1}
				}
			}
			if x < x_len - 1 {
				other_elevation := get_elevation([lines[x + 1][y]].bytestr())
				if math.abs(elevation - other_elevation) < 2 {
					edges << Edge{'${x}-${y}', '${x + 1}-${y}', [line[y]].bytestr(), [
						lines[x + 1][y],
					].bytestr(), 1}
				}
			}
		}
	}

	// make BFS
	mut queue := [start_point]
	mut explored := []string{}

	mut distance := 0
	for queue.len > 0 {
		println("${queue} ${explored.len} $distance $end_point")
		if end_point in queue {
			println("$end_point is in $queue")
			break
		}
		distance += 1

		mut next_queue := []string{}
		for current in queue {
			neighbours := get_neighbours(current, edges)
			for n in neighbours {
				if n in explored {
				} else {
					next_queue << n
				}
			}
			explored << current
		}
		queue = arrays.group_by(next_queue, fn(s string) string {return s}).keys()
	}

	println(distance)
}

fn get_elevation(s string) int {
	if s == 'S' {
		return 97
	} else if s == 'E' {
		return 122
	} else {
		return int(s[0])
	}
}

fn get_neighbours(x string, edges []Edge) []string {
	connector := fn [x] (e Edge) []string {
		if e.start_enc == x {
			return [e.end_enc]
		} else if e.end_enc == x {
			return [e.start_enc]
		} else {
			return []string{}
		}
	}

	mut rslt := []string{}
	for e in edges {
		for n in connector(e) {
			rslt << n
		}
	}
	return rslt
}
