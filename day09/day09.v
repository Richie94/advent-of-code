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
	return '${a.x}:${a.y}'
}

fn main() {
	f := os.read_file('input_test.txt') or {
		println('Cannot open input')
		return
	}

	sw1 := time.new_stopwatch()
	part1(f)
	println('took ${sw1.elapsed().milliseconds()}ms')
	sw2 := time.new_stopwatch()
	part2(f)
	println('took ${sw2.elapsed().milliseconds()}ms')
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
			updated_head := move_head(head, direction)
			head.x = updated_head.x
			head.y = updated_head.y

			point_list << '${tail.x}-${tail.y}'
			tail = get_next_tail(head, tail)
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
		instruction_result := execute_command(cmd, knots)
		point_list << instruction_result.tail_visits
		knots = instruction_result.knots.clone()
	}

	println('p2 ${arrays.group_by(point_list, fn (p string) string {
		return p
	}).keys().len}')
}

fn execute_command(cmd string, knots []Point) InstructionResult {
	direction := cmd.split(' ')[0]
	amount := cmd.split(' ')[1].int()
	mut updated_knots := knots.clone()
	mut total_tail_visits := []string{}

	for _ in 0 .. amount {
		instruction_result := execute_instruction(Point{updated_knots[0].x, updated_knots[0].y},
			direction, updated_knots)
		total_tail_visits << instruction_result.tail_visits
		updated_knots = instruction_result.knots.clone()
	}
	return InstructionResult{knots, total_tail_visits}
}

struct InstructionResult {
	knots       []Point
	tail_visits []string
}

fn execute_instruction(head Point, direction string, knots []Point) InstructionResult {
	mut new_knots := []Point{}
	mut new_head := move_head(head, direction)
	mut tail_visits := []string{}

	new_knots << new_head

	for idx in 0 .. knots.len {
		if idx > 0 {
			tail := get_next_tail(new_knots[idx - 1], knots[idx])
			new_knots << Point{tail.x, tail.y}
			if idx == knots.len - 1 {
				tail_visits << tail.to_string()
			}
		}
	}

	return InstructionResult{new_knots, tail_visits}
}

fn move_head(head Point, direction string) Point {
	if direction == 'R' {
		return Point{head.x + 1, head.y}
	} else if direction == 'L' {
		return Point{head.x - 1, head.y}
	} else if direction == 'U' {
		return Point{head.x, head.y + 1}
	} else {
		return Point{head.x, head.y - 1}
	}
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
