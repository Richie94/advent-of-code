import os
import arrays
import math
import time

struct Point {
mut:
	x int
	y int
}

fn (a Point) to_string() string {
	return '${a.x}-${a.y}'
}

fn main() {
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	sw1 := time.new_stopwatch()
	part1(f)
	println("took ${sw1.elapsed().milliseconds()}ms")
	sw2 := time.new_stopwatch()
	part2(f)
	println("took ${sw2.elapsed().milliseconds()}ms")
}

fn part1(f string) {
	mut point_list := []string{}
	mut head := Point{
		x: 0
		y: 0
	}
	mut tail := Point{
		x: 0
		y: 0
	}
	for cmd in f.split('\n') {
		direction := cmd.split(' ')[0]
		amount := cmd.split(' ')[1].int()

		for _ in 0 .. amount {
			if direction == 'R' {
				head.x += 1
			} else if direction == 'L' {
				head.x -= 1
			} else if direction == 'U' {
				head.y += 1
			} else if direction == 'D' {
				head.y -= 1
			}

			point_list << '${tail.x}-${tail.y}'
			tail = get_next_tail(head, tail)
			// println("$direction ${head.x}-${head.y} ${tail.x}-${tail.y}")
		}
	}

	println('p1 ${arrays.group_by(point_list, fn (p string) string {
		return p
	}).keys().len}')
}

fn part2(f string) {
	mut point_list := []string{}
	mut knots := []Point{}
	for _ in 0 .. 10 {
		knots << Point{
			x: 0
			y: 0
		}
	}


	for cmd in f.split('\n') {
		direction := cmd.split(' ')[0]
		amount := cmd.split(' ')[1].int()


		for _ in 0 .. amount {
			mut new_knots := []Point{}
			mut new_head := Point{knots[0].x, knots[0].y}
			if direction == 'R' {
				new_head.x += 1
			} else if direction == 'L' {
				new_head.x -= 1
			} else if direction == 'U' {
				new_head.y += 1
			} else if direction == 'D' {
				new_head.y -= 1
			}

			new_knots << new_head

			for idx in 0 .. 10 {
				if idx > 0 {
					tail := get_next_tail(new_knots[idx -1], knots[idx])
					new_knots << Point { tail.x, tail.y }
					if idx == 9 {
						point_list << tail.to_string()
					}
				}
			}

			knots = new_knots.clone()
		}

	}

	println('p2 ${arrays.group_by(point_list, fn (p string) string {
    		return p
    	}).keys().len}')
}

fn get_next_tail(head Point, tail Point) Point {
	if math.abs(head.x - tail.x) < 2 && math.abs(head.y - tail.y) < 2 {
		return Point{tail.x, tail.y}
	}

	if head.x == tail.x {
		if head.y - 2 == tail.y {
			return Point{tail.x, tail.y + 1}
		} else if head.y + 2 == tail.y {
			return Point{tail.x, tail.y - 1}
		} else {
			return Point{tail.x, tail.y}
		}
	}

	if head.y == tail.y {
		if head.x - 2 == tail.x {
			return Point{tail.x + 1, tail.y}
		} else if head.x + 2 == tail.x {
			return Point{tail.x - 1, tail.y}
		} else {
			return Point{tail.x, tail.y}
		}
	}

	// move diagonally
	mut x_move := -1
	mut y_move := -1
	if head.x > tail.x {
		x_move = 1
	}
	if head.y > tail.y {
		y_move = 1
	}
	return Point{tail.x + x_move, tail.y + y_move}
}
