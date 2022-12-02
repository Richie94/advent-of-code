import os

fn main() {
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	part1(f)
	part2(f)
}

fn part1(f string) {
	scores := {
	   "Y" : 2,
	   "X": 1,
	   "Z": 3
	}

	wins := {
	   "Y": "A",
	   "X": "C",
	   "Z": "B"
	}

	looses := {
		"Y": "C",
    	"X": "B",
    	"Z": "A"
	}

	mut score := 0

	for line in f.split("\n") {
		a := line.split(" ")[0]
		b := line.split(" ")[1]

		if wins[b] == a {
			score += scores[b] + 6
		} else if looses[b] == a {
			score += scores[b]
		} else {
			score += scores[b] + 3
		}
	}

	println(score)
}

fn part2(f string) {
	scores := {
	   "B" : 2,
	   "A": 1,
	   "C": 3
	}

	wins := {
	   "A": "C",
	   "B": "A",
	   "C": "B"
	}

	looses := {
		"A": "B",
    	"B": "C",
    	"C": "A"
	}

	mut score := 0

	for line in f.split("\n") {
		a := line.split(" ")[0]
		b := line.split(" ")[1]

		if b == "X" {
			my_choice := wins[a]
			score += scores[my_choice]
		} else if b == "Y" {
			my_choice := a
        	score += scores[my_choice] + 3
		} else {
			my_choice := looses[a]
            score += scores[my_choice] + 6
		}
	}

	println(score)
}


