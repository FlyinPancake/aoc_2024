import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(String) {
  input |> string.split("\n") |> list.filter(fn(x) { !string.is_empty(x) })
}

pub fn pt_1(input: List(String)) {
  find_horizontally(input) + find_vertically(input) + find_diagonally(input)
}

fn find_horizontally(input: List(String)) -> Int {
  input
  |> list.map(fn(line) {
    let parts =
      line
      |> string.split("XMAS")
      |> list.length
    let parts_rev =
      line
      |> string.split("SAMX")
      |> list.length
    parts - 1 + parts_rev - 1
  })
  |> int.sum()
}

fn find_vertically(input: List(String)) -> Int {
  input
  |> list.map(fn(x) { string.to_graphemes(x) })
  |> list.transpose()
  |> list.map(fn(col) {
    col |> list.fold(from: "", with: fn(acc, char) { acc <> char })
  })
  |> find_horizontally()
}

fn find_diagonally(input: List(String)) -> Int {
  let #(diag, anti_diag) = get_diagonals(input)
  let diagonals = list.flatten([diag, anti_diag]) |> list.map(fn(x) { x.1 })

  diagonals |> list.filter(fn(s) { string.length(s) > 3 }) |> find_horizontally
}

pub fn get_diagonals(
  grid: List(String),
) -> #(List(#(Int, String)), List(#(Int, String))) {
  let grid_length = list.length(grid)

  // Main diagonals (top-left to bottom-right)
  let main_diagonals =
    list.range(0 - grid_length - 1, grid_length - 1)
    |> list.map(fn(offset) {
      let diag_content =
        list.range(0, grid_length - 1)
        |> list.filter_map(fn(i) {
          let row = i
          let col = i + offset

          case col >= 0 && col < grid_length {
            True -> {
              let line = list.drop(list.take(grid, row + 1), row)
              case line {
                [current_line, ..] -> {
                  let chars = string.to_graphemes(current_line)
                  case list.drop(list.take(chars, col + 1), col) {
                    [char, ..] -> Ok(char)
                    _ -> Error(Nil)
                  }
                }
                _ -> Error(Nil)
              }
            }
            False -> Error(Nil)
          }
        })
        |> string.join("")
      #(offset, diag_content)
    })
    |> list.filter(fn(diagonal) { string.length(diagonal.1) > 0 })

  // Anti-diagonals (top-right to bottom-left)
  let anti_diagonals =
    list.range(0 - grid_length - 1, grid_length - 1)
    |> list.map(fn(offset) {
      let diag_contents =
        list.range(0, grid_length - 1)
        |> list.filter_map(fn(i) {
          let row = i
          let col = grid_length - 1 - i - offset

          case col >= 0 && col < grid_length {
            True -> {
              let line = list.drop(list.take(grid, row + 1), row)
              case line {
                [current_line, ..] -> {
                  let chars = string.to_graphemes(current_line)
                  case list.drop(list.take(chars, col + 1), col) {
                    [char, ..] -> Ok(char)
                    _ -> Error(Nil)
                  }
                }
                _ -> Error(Nil)
              }
            }
            False -> Error(Nil)
          }
        })
        |> string.join("")
      #(offset, diag_contents)
    })
    |> list.filter(fn(diagonal) { string.length(diagonal.1) > 0 })

  #(main_diagonals, anti_diagonals)
}

fn find_mas(input: String, start: Int) -> Option(Int) {
  case string.drop_start(input, start) {
    "" -> None
    "MAS" <> _ -> Some(start)
    "SAM" <> _ -> Some(start)
    _ -> find_mas(input, start + 1)
  }
}

pub fn find_all_mas(input: String, start: Int) -> List(Int) {
  case find_mas(input, start) {
    None -> []
    Some(index) -> [index, ..find_all_mas(input, start + index + 1)]
  }
}

fn uw(result: Result(a, _)) -> a {
  let assert Ok(res) = result
  res
}

pub fn pt_2(input: List(String)) {
  let #(main_diagonals, anti_diagonals) = get_diagonals(input)
  let main_mases =
    main_diagonals
    |> list.filter_map(fn(s) {
      case find_all_mas(s.1, 0) {
        [] -> Error(Nil)
        all_mas -> Ok(#(all_mas, s.0))
      }
    })
    |> list.flat_map(fn(el) {
      let #(starts, col) = el
      starts
      |> list.map(fn(row) {
        // case col < 0 {
        //   True -> 
        // } 
        #(row, col)
      })
    })
    |> io.debug
  todo
}
