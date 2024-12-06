import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
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
  let diagonals = get_diagonals(input)

  diagonals |> list.filter(fn(s) { string.length(s) > 3 }) |> find_horizontally
}

pub fn get_diagonals(grid: List(String)) -> List(String) {
  // Main diagonals (top-left to bottom-right)
  let main_diagonals =
    grid
    |> list.index_map(fn(row, i) {
      let width = string.length(row)
      { string.repeat(" ", width - i) <> row <> string.repeat(" ", i) }
      |> string.to_graphemes
    })
    |> list.transpose
    |> list.map(fn(x) { x |> string.join(with: "") |> string.trim })

  // Anti-diagonals (top-right to bottom-left)
  let anti_diagonals =
    grid
    |> list.index_map(fn(row, i) {
      let width = string.length(row)
      { string.repeat(" ", i) <> row <> string.repeat(" ", width - i) }
      |> string.to_graphemes
    })
    |> list.transpose
    |> list.map(fn(x) { x |> string.join(with: "") |> string.trim })

  list.flatten([main_diagonals, anti_diagonals])
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

// fn uw(result: Result(a, _)) -> a {
//   let assert Ok(res) = result
//   res
// }

pub fn pt_2(input: List(String)) {
  let width = input |> list.length
  let indexed =
    input
    |> list.index_map(fn(x, row) {
      x
      |> string.to_graphemes
      |> list.index_map(fn(c, col) { #(#(row, col), c) })
    })

  let indexed_dict = indexed |> list.flatten |> dict.from_list

  let possible_middles =
    indexed
    |> list.map(fn(r) {
      r
      |> list.filter(fn(x) {
        let #(#(row, col), c) = x
        let not_on_edge =
          row >= 1 && row <= width - 2 && col >= 1 && col <= width - 2
        c == "A" && not_on_edge
      })
    })
    |> list.flatten
  possible_middles
  |> list.filter(fn(mid) {
    let #(#(row, col), _) = mid

    let top_left = indexed_dict |> dict.get(#(row - 1, col - 1))
    let top_right = indexed_dict |> dict.get(#(row - 1, col + 1))
    let bot_left = indexed_dict |> dict.get(#(row + 1, col - 1))
    let bot_right = indexed_dict |> dict.get(#(row + 1, col + 1))

    let main_diag_ok = case top_left, bot_right {
      Ok("M"), Ok("S") -> True
      Ok("S"), Ok("M") -> True
      _, _ -> False
    }

    let anti_diag_ok = case top_right, bot_left {
      Ok("M"), Ok("S") -> True
      Ok("S"), Ok("M") -> True
      _, _ -> False
    }

    main_diag_ok && anti_diag_ok
  })
  |> list.length
}
