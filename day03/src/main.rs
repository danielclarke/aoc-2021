use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

fn main() {
    if let Ok(lines) = read_lines("./test_data") {
        let mut data = vec![];
        for line in lines {
            if let Ok(ip) = line {
                data.push(ip);
            }
        }
        part_one(&data);
        part_two(&data);
    }
}

fn part_one(data: &[String]) -> isize {
    let mut i = 0;
    let mut v = vec![];
    for line in data {
        if i == 0 {
            v = vec![0; line.len()];
        }
        for (j, c) in line.chars().enumerate() {
            if let Some(d) = c.to_digit(10) {
                v[j] += d;
            }
        }
        println!("{:?}", v);
        i += 1;
    }
    let mut gamma = String::from("");
    let mut epsilon = String::from("");
    for value in v {
        if (value as f32 / i as f32) < 0.5 {
            gamma.push('0');
            epsilon.push('1');
        } else {
            gamma.push('1');
            epsilon.push('0');
        }
    }
    let g = isize::from_str_radix(&gamma, 2).unwrap();
    let e = isize::from_str_radix(&epsilon, 2).unwrap();
    println!("{}", g);
    println!("{}", e);
    println!("{}", g * e);
    return g * e;
}

fn oxygen(data: &[String]) -> usize {
    let mut indices: Vec<_> = (0..data.len()).collect();
    for i in 0..data[0].len() {
        let mut ones = vec![];
        let mut zeros = vec![];
        for j in indices {
            if data[j].as_bytes()[i] as char == '1' {
                ones.push(j);
            } else if data[j].as_bytes()[i] as char == '0' {
                zeros.push(j)
            }
        }
        if ones.len() >= zeros.len() {
            indices = ones;
        } else {
            indices = zeros;
        }
        if indices.len() == 1 {
            break;
        }
    }
    for i in &indices {
        println!("{}", data[*i]);
    }
    return indices[0];
}

fn carbon(data: &[String]) -> usize {
    let mut indices: Vec<_> = (0..data.len()).collect();
    for i in 0..data[0].len() {
        let mut ones = vec![];
        let mut zeros = vec![];
        for j in indices {
            if data[j].as_bytes()[i] as char == '1' {
                ones.push(j);
            } else if data[j].as_bytes()[i] as char == '0' {
                zeros.push(j)
            }
        }
        if ones.len() >= zeros.len() {
            indices = zeros;
        } else {
            indices = ones;
        }
        for j in &indices {
            println!("{} {}", i, data[*j]);
        }
        if indices.len() == 1 {
            break;
        }
    }
    for i in &indices {
        println!("{}", data[*i]);
    }
    return indices[0];
}

fn part_two(data: &[String]) -> isize {
    oxygen(data);
    carbon(data);
    let o = isize::from_str_radix(&data[oxygen(data)], 2).unwrap();
    let c = isize::from_str_radix(&data[carbon(data)], 2).unwrap();
    println!("{}", o);
    println!("{}", c);
    println!("{}", o * c);
    return 0;
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}
