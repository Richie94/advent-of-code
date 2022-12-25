import os { read_file }
import math { pow }
import arrays { sum }

fn main() {
	file_name := 'input.txt'
	s := sum(read_file(file_name)!.split('\n').map(snafu_to_dec))!
	println(s)
	d := dec_to_snafu(s)
	println(d)
}

fn dec_to_snafu(s i64) string {
	mut dec := s
	mut result := ''
	for dec != 0 {
		remainder := dec % 5
		match remainder {
			0 {
				result += '0'
			}
			1 {
				result += '1'
				dec--
			}
			2 {
				result += '2'
				dec -= 2
			}
			3 {
				result += '='
				dec += 2
			}
			4 {
				result += '-'
				dec++
			}
			else {
				panic('')
			}
		}
		dec = dec / 5
	}

	return result.runes().reverse().string()
}

fn snafu_to_dec(s string) i64 {
	mut result := f64(0)
	l := s.len
	for idx, r in s.runes() {
		v := match r {
			`2` { 2 }
			`1` { 1 }
			`0` { 0 }
			`-` { -1 }
			`=` { -2 }
			else { panic('Illegal number') }
		}
		result += v * pow(5, l - idx - 1)
	}
	return i64(result)
}
