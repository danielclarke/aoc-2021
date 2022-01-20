use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

use std::collections::HashMap;

#[derive(Debug, Clone)]
struct Cave {
    name: String,
    small: bool,
}

struct Graph {
    adjaceny: HashMap<String, Vec<Cave>>,
}

impl Graph {
    fn new() -> Graph {
        return Graph {
            adjaceny: HashMap::new(),
        };
    }

    fn insert(&mut self, origin: Cave, dest: Cave) {
        self.adjaceny
            .entry(origin.name.to_owned())
            .or_insert(vec![])
            .push(dest.clone());
        if dest.name != "end" && origin.name != "start" {
            self.adjaceny
            .entry(dest.name.to_owned())
            .or_insert(vec![])
            .push(origin);
        }
    }

    fn print(&self) {
        for (start, dests) in &self.adjaceny {
            for dest in dests {
                println!("start: {}, end: {}", start, dest.name);
            }
        }
    }

    fn print_path(path: &Vec<String>) {
        for cave_name in path {
            print!("{}", cave_name);
            if cave_name != "end" {
                print!(" -> ");
            }
        }
        println!();
    }

    fn print_paths(paths: &Vec<Vec<String>>) {
        for path in paths {
            Graph::print_path(path);
        }
    }

    fn traverse(&self) {
        let mut stack = vec![];
        let mut paths = vec![vec!["start".to_owned()]];
        let mut finished_paths = vec![];

        if let Some(dests) = self.adjaceny.get("start") {
            stack.push(dests.into_iter().to_owned());
        }

        let mut i = 0;
        while stack.len() > 0 {
            i += 1;
            
            // println!("{}", i);
            // println!("stack");
            // for i in &stack {
            //     for cave in i.to_owned() {
            //         print!("{}, ", cave.name);
            //     }
            //     println!();
            // }
            if let Some(mut top) = stack.pop() {
                if top.to_owned().count() > 1 {
                    paths.push(paths.last().unwrap().to_owned());
                }
                // println!("paths before");
                // Graph::print_paths(&paths);
                if let Some(cave) = top.next() {
                    if top.to_owned().count() > 0 {
                        stack.push(top);
                    }
                    let mut path = paths.pop().unwrap();
                    if !cave.small || !path.contains(&cave.name) {
                        path.push(cave.name.to_owned());
                        if let Some(dests) = self.adjaceny.get(&cave.name) {
                            stack.push(dests.into_iter().to_owned());
                            paths.push(path);
                        } else if cave.name == "end" {
                            finished_paths.push(path);
                        }
                    }
                }
                // println!("paths after");
                // Graph::print_paths(&paths);
                // println!("finished paths");
                // Graph::print_paths(&finished_paths);
                // println!();
            }
        }

        println!("finished paths:");
        Graph::print_paths(&finished_paths);
        println!("{}", finished_paths.len())
    }

    fn traverse_single_small_cave_double_visit(&self) {
        let mut stack = vec![];
        let mut paths = vec![(false, vec!["start".to_owned()])];
        let mut finished_paths = vec![];

        if let Some(dests) = self.adjaceny.get("start") {
            stack.push(dests.into_iter().to_owned());
        }

        let mut i = 0;
        while stack.len() > 0 {
            i += 1;
            
            // println!("{}", i);
            // println!("stack");
            // for i in &stack {
            //     for cave in i.to_owned() {
            //         print!("{}, ", cave.name);
            //     }
            //     println!();
            // }
            if let Some(mut top) = stack.pop() {
                if top.to_owned().count() > 1 {
                    paths.push(paths.last().unwrap().to_owned());
                }
                // println!("paths before");
                // Graph::print_paths(&paths);
                if let Some(cave) = top.next() {
                    if top.to_owned().count() > 0 {
                        stack.push(top);
                    }
                    let (mut double_visit, mut path) = paths.pop().unwrap();
                    if !double_visit || !cave.small || !path.contains(&cave.name) {
                        if cave.small && path.contains(&cave.name) {
                            double_visit = true;
                        };
                        path.push(cave.name.to_owned());
                        if let Some(dests) = self.adjaceny.get(&cave.name) {
                            stack.push(dests.into_iter().to_owned());
                            paths.push((double_visit, path));
                        } else if cave.name == "end" {
                            finished_paths.push(path);
                        }
                    }
                }
                // println!("paths after");
                // Graph::print_paths(&paths);
                // println!("finished paths");
                // Graph::print_paths(&finished_paths);
                // println!();
            }
        }

        println!("finished paths:");
        Graph::print_paths(&finished_paths);
        println!("{}", finished_paths.len())
    }
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}

fn run(path: &str) {
    let mut graph = Graph::new();

    if let Ok(lines) = read_lines(path) {
        for line in lines {
            if let Ok(line) = line {
                let mut line = line.split("-");
                let start = line.next();
                let end = line.next();
                match (start, end) {
                    (Some(start), Some(end)) => {
                        let origin_cave = Cave {
                            name: start.to_owned(),
                            small: start.to_lowercase() == start,
                        };
                        let dest_cave = Cave {
                            name: end.to_owned(),
                            small: end.to_lowercase() == end,
                        };
                        if origin_cave.name == "end" || dest_cave.name == "start" {
                            graph.insert(dest_cave, origin_cave);
                        } else {
                            graph.insert(origin_cave, dest_cave);
                        }
                    }
                    _ => {}
                }
            }
        }
    }

    graph.print();
    println!("");
    graph.traverse_single_small_cave_double_visit();
}

fn main() {
    run("./assets/data");
}
