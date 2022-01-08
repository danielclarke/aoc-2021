const std = @import("std");
const tokenize = std.mem.tokenize;
const ArrayList = std.ArrayList;

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("assets/data.txt", .{});
    defer file.close();

    var reader = file.reader();
    var buf: [1024]u8 = undefined;

    var commands = ArrayList(u8).init(std.testing.allocator);
    defer commands.deinit();

    var opt_commands = try reader.readUntilDelimiterOrEof(&buf, '\n');
    if (opt_commands) |cmds| {
        var it = tokenize(u8, cmds, ",");
        while(it.next()) |cmd| {
            var command = try std.fmt.parseInt(u8, cmd, 10);
            try commands.append(command);
        }
    }

    var boards = ArrayList([5][5]u8).init(std.testing.allocator);
    defer boards.deinit();
    
    var marks = ArrayList([6][6]u8).init(std.testing.allocator);
    defer marks.deinit();

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |_| {
        var i: u8 = 0;
        var board: [5][5]u8 = undefined;
        while (i < 5) : (i += 1) {
            if (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
                var it = tokenize(u8, line, " ");
                var j: u8 = 0;
                while(it.next()) |num| {
                    board[i][j] = try std.fmt.parseInt(u8, num, 10);
                    // std.debug.print("{}\n", .{board[i][j]});
                    j += 1;
                }
            }
        }
        var mark = [6][6]u8{
            [_]u8{0, 0, 0, 0, 0, 0},
            [_]u8{0, 0, 0, 0, 0, 0},
            [_]u8{0, 0, 0, 0, 0, 0},
            [_]u8{0, 0, 0, 0, 0, 0},
            [_]u8{0, 0, 0, 0, 0, 0},
            [_]u8{0, 0, 0, 0, 0, 0},
        };
        try boards.append(board);
        try marks.append(mark);
    }

    // var final_command: u8 = 0;
    // var index = outer: for (commands.items) |command| {
    //     std.debug.print("{}\n", .{command});
    //     for (boards.items) |board, index| {
    //         for (board) |row, x| {
    //             for (row) |value, y| {
    //                 if (value == command) {
    //                     std.debug.print("x: {}, y: {}\n", .{x, y});
    //                     marks.items[index][x][y] += 1;
    //                     marks.items[index][x][5] += 1;
    //                     marks.items[index][5][y] += 1;
    //                     if (marks.items[index][x][5] == 5) {
    //                         std.debug.print("x: {}\n", .{x});
    //                         final_command = command;
    //                         break :outer index;
    //                     }
    //                     if (marks.items[index][5][y] == 5) {
    //                         std.debug.print("y: {}\n", .{y});
    //                         final_command = command;
    //                         break :outer index;
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // } else 0;

    var final_command: u8 = 0;
    var losing_board_index: usize = 0;
    var losing_board_turns: usize = 0;
    for (boards.items) |board, index| {
        outer: for (commands.items) |command, command_index| {
            std.debug.print("{}\n", .{command});
            for (board) |row, x| {
                for (row) |value, y| {
                    if (value == command) {
                        std.debug.print("x: {}, y: {}\n", .{x, y});
                        marks.items[index][x][y] += 1;
                        marks.items[index][x][5] += 1;
                        marks.items[index][5][y] += 1;
                        if (marks.items[index][x][5] == 5) {
                            std.debug.print("x: {}\n", .{x});
                            if (command_index > losing_board_turns) {
                                losing_board_index = index;
                                losing_board_turns = command_index;
                                final_command = command;
                            }
                            break :outer;
                        }
                        if (marks.items[index][5][y] == 5) {
                            std.debug.print("y: {}\n", .{y});
                            if (command_index > losing_board_turns) {
                                losing_board_index = index;
                                losing_board_turns = command_index;
                                final_command = command;
                            }
                            break :outer;
                        }
                    }
                }
            }
        }
    }

    std.debug.print("index: {}\n", .{losing_board_index});
    std.debug.print("turns: {}\n", .{losing_board_turns});

    var i: u8 = 0;
    var marked_sum: u32 = 0;
    var unmarked_sum: u32 = 0;
    while (i < 5) : (i += 1) {
        var j: u8 = 0;
        while (j < 5) : (j += 1) {
            // std.debug.print("i: {}, j: {}\n", .{i, j});
            if (marks.items[losing_board_index][i][j] == 1) {
                // std.debug.print("marked: {}\n", .{boards.items[losing_board_index][i][j]});
                marked_sum += boards.items[losing_board_index][i][j];
            } else {
                // std.debug.print("unmarked: {}\n", .{boards.items[losing_board_index][i][j]});
                unmarked_sum += boards.items[losing_board_index][i][j];
            }
        }
    }
    std.debug.print("marked_sum: {}\n", .{marked_sum});
    std.debug.print("unmarked_sum: {}\n", .{unmarked_sum});
    std.debug.print("final_command: {}\n", .{final_command});
    std.debug.print("answer: {}\n", .{unmarked_sum * final_command});
    // for (boards.items) |board| {
    //     std.debug.print("{}\n", .{board[0][0]});
    // }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
