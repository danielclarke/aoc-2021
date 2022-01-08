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

fn horizontal(segment: ((i32, i32), (i32, i32))) -> bool {
    segment.0.1 == segment.1.1
}

fn vertical(segment: ((i32, i32), (i32, i32))) -> bool {
    segment.0.0 == segment.1.0
}

fn main() {
    if let Ok(lines) = read_lines("./res/data") {
        let mut segments = vec![];
        let mut max_x = 0;
        let mut max_y = 0;
        for line in lines {
            if let Ok(l) = line {
                let mut points = l.split(" -> ");
                let p0 = points.next();
                let p1 = points.next();
                let coords = match (p0, p1) {
                    (Some(p0), Some(p1)) => {
                        let mut p0 = p0.split(",");
                        let mut p1 = p1.split(",");

                        let x = p0.next();
                        let y = p0.next();
                        let p0 = match (x, y) {
                            (Some(x), Some(y)) => {
                                let x = x.parse::<i32>().unwrap();
                                let y = y.parse::<i32>().unwrap();
                                max_x = if max_x > x {max_x} else {x};
                                max_y = if max_y > y {max_y} else {y};
                                Some((x, y))
                            }
                            _ => {None}
                        };

                        let x = p1.next();
                        let y = p1.next();
                        let p1 = match (x, y) {
                            (Some(x), Some(y)) => {
                                let x = x.parse::<i32>().unwrap();
                                let y = y.parse::<i32>().unwrap();
                                max_x = if max_x > x {max_x} else {x};
                                max_y = if max_y > y {max_y} else {y};
                                Some((x, y))
                            }
                            _ => {None}
                        };

                        let coords = match (p0, p1) {
                            (Some(p0), Some(p1)) => {
                                Some((p0, p1))
                            },
                            _ => None
                        };
                        coords
                    }
                    _ => {None}
                };
                if let Some(coords) = coords {
                    segments.push(coords);
                }
            }
        }
        println!("{}, {}", max_x, max_y);
        let mut map = vec![];
        for x in 0..max_x + 1 {
            map.push(vec![]);
            for _ in 0..max_y + 1 {
                map[x as usize].push(0i32);
            }
        }
        for segment in segments {
            if horizontal(segment) {
                let ((x0, y0), (x1, _)) = segment;
                for x in std::cmp::min(x0, x1)..std::cmp::max(x0, x1) + 1 {
                    map[x as usize][y0 as usize] += 1;
                }
            } else if vertical(segment) {
                let ((x0, y0), (_, y1)) = segment;
                for y in std::cmp::min(y0, y1)..std::cmp::max(y0, y1) + 1 {
                    map[x0 as usize][y as usize] += 1;
                }
            } else {
                let ((x0, y0), (x1, y1)) = segment;
                let d = std::cmp::max(x0, x1) - std::cmp::min(x0, x1);
                let dx = (x1 - x0) / d;
                let dy = (y1 - y0) / d;
                // println!("d {} x0 {} x1 {} y0 {} y1 {} dx {} dy {}", d, x0, x1, y0, y1, dx, dy);
                for i in 0..d + 1 {
                    map[(x0 + i * dx) as usize][(y0 + i * dy) as usize] += 1;
                }
            }
        }
        let mut count = 0;
        for row in map {
            for val in row {
                print!("{}", val);
                if val > 1 {
                    count += 1;
                }
            }
            println!();
        }
        println!("{}", count);
    }

}
