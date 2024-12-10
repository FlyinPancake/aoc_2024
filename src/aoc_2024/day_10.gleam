import aoc_2024/day_3
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub type Coords =
  #(Int, Int)

pub type Map =
  Dict(Coords, Int)

pub fn parse(input: String) -> Dict(#(Int, Int), Int) {
  input
  |> string.split("\n")
  |> list.filter(fn(r) { r |> string.length > 0 })
  |> list.index_map(fn(el, row_idx) {
    let assert Ok(el) =
      el
      |> string.to_graphemes
      |> list.map(fn(el) {
        case el {
          "." -> "99"
          o -> o
        }
      })
      |> list.map(int.parse)
      |> result.all
    el |> list.index_map(fn(v, col_idx) { #(#(row_idx, col_idx), v) })
  })
  |> list.flatten
  |> dict.from_list
  |> dict.filter(fn(_, v) { v != 99 })
}

pub fn pt_1(input: Map) {
  let starts = input |> dict.filter(fn(_, v) { v == 0 }) |> dict.keys
  let dests = input |> dict.filter(fn(_, v) { v == 9 }) |> dict.keys
  starts
  |> list.map(fn(start) {
    dests
    |> list.filter(fn(dest) { can_reach(input, start, dest) })
    |> list.length
  })
  |> int.sum
}

fn can_reach(map: Map, from: Coords, to: Coords) -> Bool {
  let assert Ok(from_val) = map |> dict.get(from)
  let #(from_row, from_col) = from
  [
    #(from_row - 1, from_col),
    #(from_row + 1, from_col),
    #(from_row, from_col - 1),
    #(from_row, from_col + 1),
  ]
  |> list.filter_map(fn(el) {
    let coords = dict.get(map, el)
    case coords {
      Ok(v) -> Ok(#(el, v))
      Error(_) -> Error(Nil)
    }
  })
  |> list.filter(fn(el) {
    let #(_, v) = el
    v == from_val + 1
  })
  |> list.any(fn(el) {
    let #(coords, _) = el
    case coords == to {
      True -> True
      False -> {
        can_reach(map, coords, to)
      }
    }
  })
}

pub fn pt_2(input: Map) {
  let starts = input |> dict.filter(fn(_, v) { v == 0 }) |> dict.keys
  let dests = input |> dict.filter(fn(_, v) { v == 9 }) |> dict.keys
  starts
  |> list.map(fn(start) {
    dests
    |> list.map(fn(dest) { routes(input, start, dest) })
    |> int.sum
  })
  |> int.sum
}

fn routes(map: Map, from: Coords, to: Coords) -> Int {
  let assert Ok(from_val) = map |> dict.get(from)
  let #(from_row, from_col) = from
  [
    #(from_row - 1, from_col),
    #(from_row + 1, from_col),
    #(from_row, from_col - 1),
    #(from_row, from_col + 1),
  ]
  |> list.filter_map(fn(el) {
    let coords = dict.get(map, el)
    case coords {
      Ok(v) -> Ok(#(el, v))
      Error(_) -> Error(Nil)
    }
  })
  |> list.filter(fn(el) {
    let #(_, v) = el
    v == from_val + 1
  })
  |> list.map(fn(el) {
    let #(coords, _) = el
    case coords == to {
      True -> 1
      False -> {
        routes(map, coords, to)
      }
    }
  })
  |> int.sum
}
