import os
import arrays

struct Point {
	x int
	y int
}

fn get_falling_position(p Point, blocks []string) []Point {
	// try falling down directly
	if !("${p.x},${p.y+1}" in blocks) {
		return [Point{p.x, p.y+1}]
	}
	// try falling down left diagonally
	if !("${p.x-1},${p.y+1}" in blocks) {
		return [Point{p.x-1, p.y+1}]
	}
	// try falling down left diagonally
	if !("${p.x+1},${p.y+1}" in blocks) {
		return [Point{p.x+1, p.y+1}]
	}

	// settled
	return []
}

fn str_to_point(s string) Point {
	return Point{s.split(",")[0].int(), s.split(",")[1].int()}
}

fn get_points_between(a Point, b Point) []Point{
	mut result := []Point{}
	if a.x == b.x {
		max_y := arrays.max([a.y, b.y]) or {panic("")}
		min_y := arrays.min([a.y, b.y]) or {panic("")}

		for y in min_y .. max_y + 1 {
			result << Point{a.x, y}
		}
	}

	if a.y == b.y {
		max_x := arrays.max([a.x, b.x]) or {panic("")}
		min_x := arrays.min([a.x, b.x]) or {panic("")}

		for x in min_x .. max_x + 1 {
			result << Point{x, a.y}
		}
	}

	return result

}

fn main() {
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	mut blocks := []Point{}

	for line in f.split("\n") {
		points := line.split(" -> ").map(str_to_point)
		for idx in 0 .. points.len - 1 {
			for p in get_points_between(points[idx], points[idx+1]) {
				if !(p in blocks){
					blocks << p
				}
			}
		} 
	}
	
	p1(blocks)
	p2(blocks)

}

fn p1(blocks_param []Point) {
	mut blocks := blocks_param.map("${it.x},${it.y}")
	mut bottom_y := arrays.max(blocks_param.map(it.y)) or { 0 }

	mut settled_corns := 0
	mut keep_falling := true

	for keep_falling == true {
		mut corn := Point{500, 0}
		mut next_pos := get_falling_position(corn, blocks)

		for next_pos.len > 0 && corn.y < bottom_y {
			corn = next_pos[0]
			next_pos = get_falling_position(corn, blocks)
		}

		if next_pos.len == 0 {
			// settled, add to blocks
			settled_corns += 1
			blocks << "${corn.x},${corn.y}"
		} else {
			keep_falling = false
		}
	}

	println(settled_corns)
}

fn p2(blocks_param []Point){
	mut blocks := blocks_param.map("${it.x},${it.y}")
	mut bottom_y := arrays.max(blocks_param.map(it.y)) or { 0 }

	mut settled_corns := 0
	mut keep_falling := true

	for keep_falling {
        mut corn := Point{500, 0}
		mut next_pos := get_falling_position(corn, blocks)

		for next_pos.len > 0 && corn.y < bottom_y + 1 {
			corn = next_pos[0]
			next_pos = get_falling_position(corn, blocks)
		}

		// settled, add to blocks
		settled_corns += 1
		corn_str := "${corn.x},${corn.y}"
		blocks << corn_str

        if corn_str == "500,0" {
            keep_falling = false
        }
    }	

	println(settled_corns)

}