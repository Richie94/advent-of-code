import os { read_file }
import regex
import math { abs, min, max }
import arrays

fn main() {
	file := 'input.txt'
	println("Part1: ${part1(file, 2000000) or {0}}")
	println("Part2: ${part2(file, 4000000) or {0}}")
}

struct Sensor {
	x           int
	y           int
	beacon_x    int
	beacon_y    int
	beacon_dist int
}

fn (s Sensor) get_min_x() int {
	return min(s.x - s.beacon_dist, s.beacon_x - s.beacon_dist)
}

fn (s Sensor) get_max_x() int {
	return max(s.x + s.beacon_dist, s.beacon_x + s.beacon_dist)
}

fn (s Sensor) valid_beacon(x int, y int) bool {
	return (s.beacon_x == x && s.beacon_y == y) || !s.can_see(x, y)
}

fn (s Sensor) can_see(x int, y int) bool {
	return abs(s.x - x) + abs(s.y - y) <= s.beacon_dist
}

fn part1(file string, y int) !int {
	sensors := read_file(file)!.split("\n").map(parse_line)

	min_x := arrays.min(sensors.map(it.get_min_x())) or { 0 }
	max_x := arrays.max(sensors.map(it.get_max_x())) or { 0 }

	mut result := 0
	for x in min_x .. max_x {
		if !sensors.all(it.valid_beacon(x, y)) {
			result += 1
		}
	}

	return result
}

fn part2(file string, max_space int) !i64 {
	sensors := read_file(file)!.split("\n").map(parse_line)

	for y in 0 .. max_space {
		for x := 0; x <= max_space; x += 1 {
			mut found := true
			for sensor in sensors {
				if sensor.can_see(x, y) {
					found = false

					//jump to right end of sensor if we cant see it at this point
					end_diff := sensor.beacon_dist - abs(sensor.y - y)
					x += end_diff * 2 - (end_diff - sensor.x + x)
				}
			}

			if found {
				return i64(x) * max_space + y
			}
		}
	}

	return 0
}

fn parse_line(line string) Sensor {
	mut re := regex.regex_opt('Sensor at x=(.*), y=(.*): closest beacon is at x=(.*), y=(.*)') or {
		panic(err)
	}
	re.match_string(line)
	x := re.get_group_by_id(line, 0).int()
	y := re.get_group_by_id(line, 1).int()
	beacon_x := re.get_group_by_id(line, 2).int()
	beacon_y := re.get_group_by_id(line, 3).int()
	dist := abs(x - beacon_x) + abs(y - beacon_y)
	return Sensor{x, y, beacon_x, beacon_y, dist}
}
