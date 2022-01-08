use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}

fn distance(p: u32, points: &Vec<u32>) -> u32 {
    let mut d = 0;
    for point in points {
        if *point < p {
            d += p - *point;
        } else {
            d += *point - p;
        }
    }
    d
}

fn fuel_cost(a: u32, b: u32) -> u32 {
    if a < b {
        (b - a) * (b - a + 1) / 2
    } else {
        (a - b) * (a - b + 1) / 2
    }
}

fn total_fuel_cost(p: u32, points: &Vec<u32>) -> u32 {
    let mut d = 0;
    for point in points {
        d += fuel_cost(p, *point);
    }
    d
}

fn main() {
    let mut positions = vec![];
    if let Ok(lines) = read_lines("./assets/data") {
        for line in lines {
            if let Ok(line) = line {
                let line = line.split(",");
                for tok in line {
                    positions.push(tok.parse::<u32>().unwrap());
                }
            }
        }
    }
    positions.sort();
    
    let mut max_pos = positions[positions.len() - 1];
    let mut min_pos = positions[0];
    let mut pos = max_pos / 2;
    let mut c = total_fuel_cost(pos, &positions);
    let mut search_window = (max_pos - min_pos) / 4;
    while search_window > 0 {
        println!("{} {}", pos, c);
        let down_pos = pos - search_window;
        let up_pos = pos + search_window;
        let c_1 = total_fuel_cost(down_pos, &positions);
        let c_2 = total_fuel_cost(up_pos, &positions);

        if c_1 < c {
            pos = down_pos;
            max_pos = pos;
            c = c_1;
        } else if c_2 < c {
            pos = up_pos;
            min_pos = pos;
            c = c_2;
        }
        println!("{} {}", down_pos, c_1);
        println!("{} {}", up_pos, c_2);
        println!("~~~~~~~~");

        search_window = search_window / 2;
        if min_pos == max_pos {
            break;
        }
    }

    // println!("{}", positions.len());
    // println!("{}", total_fuel_cost(485, &positions));
    println!("{} {}", pos, c);
}
