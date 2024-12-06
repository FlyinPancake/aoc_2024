import gleam/dict
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import parallel_map

pub fn parse(input: String) -> List(String) {
  input |> string.split("\n")
}

pub type GuardFacing {
  Up
  Down
  Left
  Right
}

pub type Coords =
  #(Int, Int)

pub type GuardPosition {
  GuardPosition(coords: #(Int, Int), facing: GuardFacing)
}

fn turn_90(f: GuardFacing) -> GuardFacing {
  case f {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn guard_mov(g: GuardPosition) {
  let #(x, y) = g.coords
  case g.facing {
    Down -> GuardPosition(#(x + 1, y), g.facing)
    Left -> GuardPosition(#(x, y - 1), g.facing)
    Right -> GuardPosition(#(x, y + 1), g.facing)
    Up -> GuardPosition(#(x - 1, y), g.facing)
  }
}

pub fn pt_1(input: List(String)) {
  let h = list.length(input)
  let assert [first_row, ..] = input
  let w = string.length(first_row)
  let grid =
    input
    |> list.index_map(fn(row, row_idx) {
      row
      |> string.to_graphemes
      |> list.index_map(fn(el, col_idx) { #(#(row_idx, col_idx), el) })
    })
    |> list.flatten
    |> dict.from_list
  let assert Ok(guard_pos) =
    grid
    |> dict.filter(fn(_coords, ch) { ch == "^" })
    |> dict.to_list
    |> list.first
  let #(guard_coords, _) = guard_pos
  let visited =
    guard_step(grid, GuardPosition(guard_coords, Up), #(w, h))
    |> list.map(fn(x) { x.coords })
    |> set.from_list
  // print_grid(grid, #(w, h), visited)
  visited
  |> set.to_list
  |> list.length
}

fn guard_step(
  grid: dict.Dict(#(Int, Int), String),
  guard_pos: GuardPosition,
  grid_size: #(Int, Int),
) -> List(GuardPosition) {
  let next_pos = guard_mov(guard_pos)
  case dict.get(grid, next_pos.coords) {
    Error(_) -> [guard_pos]
    Ok(next_tile) -> {
      case next_tile {
        "." | "^" -> [guard_pos, ..guard_step(grid, next_pos, grid_size)]
        "#" -> {
          guard_step(grid, guard_turn(guard_pos), grid_size)
        }
        _ -> panic
      }
    }
  }
}

// fn print_grid(
//   grid: dict.Dict(#(Int, Int), String),
//   grid_size: #(Int, Int),
//   visited: set.Set(#(Int, Int)),
// ) -> Set(#(Int, Int)) {
//   let #(w, h) = grid_size

//   list.range(0, h - 1)
//   |> list.map(fn(row_idx) {
//     list.range(0, w - 1)
//     |> list.map(fn(col_idx) {
//       case grid |> dict.get(#(row_idx, col_idx)) {
//         Error(_) -> panic
//         Ok("#") -> "#"
//         Ok(_) ->
//           case visited |> set.contains(#(row_idx, col_idx)) {
//             False -> "."
//             True -> "X"
//           }
//       }
//     })
//     |> string.concat
//     |> io.debug
//   })

//   visited
// }

fn guard_turn(g: GuardPosition) {
  GuardPosition(coords: g.coords, facing: turn_90(g.facing))
}

fn guard_step_loop(
  grid: dict.Dict(#(Int, Int), String),
  guard_pos: GuardPosition,
  grid_size: #(Int, Int),
  visited: Set(GuardPosition),
) -> Bool {
  case visited |> set.contains(guard_pos) {
    True -> True
    False -> {
      let visited = visited |> set.insert(guard_pos)
      let next_pos = guard_mov(guard_pos)
      case dict.get(grid, next_pos.coords) {
        Error(_) -> False
        Ok(next_tile) -> {
          case next_tile {
            "." | "^" -> {
              guard_step_loop(grid, next_pos, grid_size, visited)
            }
            "#" -> {
              guard_step_loop(grid, guard_turn(guard_pos), grid_size, visited)
            }
            _ -> panic
          }
        }
      }
    }
  }
}

fn find_incercepts(
  coords: Coords,
  route: List(GuardPosition),
) -> Result(GuardPosition, Nil) {
  case list.find(route, fn(x) { x.coords == coords }) {
    Error(_) -> Error(Nil)
    Ok(gp) -> Ok(gp)
  }
}

pub fn pt_2(input: List(String)) -> Int {
  let h = list.length(input)
  let assert [first_row, ..] = input
  let w = string.length(first_row)
  let grid =
    input
    |> list.index_map(fn(row, row_idx) {
      row
      |> string.to_graphemes
      |> list.index_map(fn(el, col_idx) { #(#(row_idx, col_idx), el) })
    })
    |> list.flatten
    |> dict.from_list
  let assert Ok(guard_pos) =
    grid
    |> dict.filter(fn(_coords, ch) { ch == "^" })
    |> dict.to_list
    |> list.first
  let #(guard_coords, _) = guard_pos

  let dots = grid |> dict.filter(fn(_, v) { v == "." })

  let default_route = guard_step(grid, GuardPosition(guard_coords, Up), #(w, h))

  dots
  |> dict.keys
  |> parallel_map.list_pmap(
    fn(new_o) {
      case find_incercepts(new_o, default_route) {
        Ok(gp) -> {
          let new_grid = grid |> dict.insert(new_o, "#")
          let already_visited =
            default_route
            |> list.take_while(fn(el) { el != gp })

          let assert Ok(gp) = already_visited |> list.last
          let already_visited =
            already_visited |> set.from_list |> set.delete(gp)
          guard_step_loop(
            new_grid,
            // GuardPosition(guard_coords, Up),
            gp,
            #(w, h),
            // set.new(),
            already_visited,
          )
        }
        Error(_) -> False
      }
    },
    parallel_map.MatchSchedulersOnline,
    1_000_000,
  )
  |> list.filter(fn(x) {
    case x {
      Error(_) -> panic as "timeout"
      Ok(b) -> b
    }
  })
  // |> list.filter(fn(x) { x })
  |> list.length
}
