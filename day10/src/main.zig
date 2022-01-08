const std = @import("std");

fn swap(comptime T: type, arry: []T, i: usize, j: usize) void {
    const a = arry[i];
    arry[i] = arry[j];
    arry[j] = a;
}

fn partition(comptime T: type, arry: []T, lo: usize, hi: usize) usize {
    var pivot_val = arry[hi];
    var i = lo;
    var j = lo;
    while (j < hi) : (j += 1) {
        if (arry[j] <= pivot_val) {
            swap(T, arry, i, j);
            i += 1;
        } 
    }
    swap(T, arry, i, hi);
    return i;
}

fn quickSort(comptime T: type, arry: []T, lo: usize, hi: usize) void {
    if (lo >= hi or lo < 0 or hi <= 0) {
        return;
    }
    const p = partition(T, arry, lo, hi - 1);
    quickSort(T, arry, lo, p);
    quickSort(T, arry, p + 1, hi - 1);
}

fn checkSyntax(index: *usize, row: []const u8) ?usize {
    var open_char = row[index.*];
    index.* += 1;
    while (index.* < row.len) : (index.* += 1) {
        var char = row[index.*];
        if (char == '(' or char == '[' or char == '{' or char == '<') {
            if (checkSyntax(index, row)) |error_index| {
                return error_index;
            }
        } else if (open_char == '(' and char == ')') {
            return null;
        } else if (open_char == '[' and char == ']') {
            return null;
        } else if (open_char == '{' and char == '}') {
            return null;
        } else if (open_char == '<' and char == '>') {
            return null;
        } else {
            // std.debug.print("open: {c} close: {c}", .{open_char, char});
            return index.*;
        }
    }
    return null;
}

fn scoreMissingBrackets(row: []const u8) ?u64 {
    var buf = [_]u8{0} ** 1024;
    var index: usize = 0;
    for (row) |bracket| {
        if (bracket == '(' or bracket == '[' or bracket == '{' or bracket == '<') {
            buf[index] = bracket;
            index += 1;
        } else {
            index -= 1;
            buf[index] = 0;
        }
    }
    var score: u64 = 0;
    while (index > 0) : (index -= 1) {
        score *= 5;
        const bracket = buf[index - 1];
        if (bracket == '(') {
            score += 1;
        } else if (bracket == '[') {
            score += 2;
        } else if (bracket == '{') {
            score += 3;
        } else if (bracket == '<') {
            score += 4;
        }
        std.debug.print("{c}", .{buf[index - 1]});
    }
    std.debug.print(" score: {}\n", .{score});
    return score;
}

fn scoreErrors(path: []const u8) !void {
    var score: u32 = 0;
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var reader = file.reader();
    var buf: [1024]u8 = undefined;
    var scores: [1024]u64 = undefined;
    var num_scores: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |row| {
        var index: usize = 0;
        if (checkSyntax(&index, row)) |error_index| {
            var char = row[index];
            if (char == ')') {
                score += 3;
            } else if (char == ']') {
                score += 57;
            } else if (char == '}') {
                score += 1197;
            } else if (char == '>') {
                score += 25137;
            }
            std.debug.print("error_index: {}, row; {s}\n", .{ error_index, row[0 .. error_index + 1] });
        } else {
            std.debug.print("{s}: ", .{row});
            if (scoreMissingBrackets(row)) |missing_score| {
                scores[num_scores] = missing_score;
                num_scores += 1;
                std.debug.print("missing_score: {}\n", .{missing_score});
            }
            std.debug.print("\n", .{});
        }
        // std.debug.print("index: {}, row: {s}\n", .{index, row});
    }
    quickSort(u64, &scores, 0, num_scores);
    std.debug.print("sorted: ", .{});
    var i: u8 = 0;
    while(i < num_scores) : (i += 1) {
        std.debug.print("{}, ", .{scores[i]});
    }
    std.debug.print("\n", .{});
    std.debug.print("mid score: {}\n", .{scores[num_scores / 2]});
    std.debug.print("score: {}\n", .{score});
}

pub fn main() anyerror!void {
    try scoreErrors("assets/test");
    try scoreErrors("assets/data");
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
