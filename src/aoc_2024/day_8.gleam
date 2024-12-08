import gleam/dict
import gleam/list
import gleam/set
import gleam/string

pub type Input =
  List(String)

pub fn parse(input: String) -> Input {
  input
  |> string.split("\n")
  |> list.filter(fn(el) { el |> string.length != 0 })
}

pub fn pt_1(input: Input) {
  let height = input |> list.length
  let assert [first_row, ..] = input
  let width = first_row |> string.length
  let grid =
    input
    |> list.index_map(fn(row, row_idx) {
      row
      |> string.to_graphemes
      |> list.index_map(fn(ch, col_idx) { #(#(row_idx, col_idx), ch) })
    })
    |> list.flatten
    |> dict.from_list

  let different_freqs =
    input
    |> string.join("")
    |> string.to_graphemes
    |> list.filter(fn(x) { x != "." })
    |> set.from_list

  different_freqs
  |> set.to_list
  |> list.flat_map(fn(f) {
    let antennas = grid |> dict.filter(fn(_, v) { v == f }) |> dict.keys
    antennas
    |> list.flat_map(fn(coord) {
      possible_antinodes(from: coord, with: antennas)
    })
  })
  |> set.from_list
  |> set.to_list
  |> list.filter(fn(coords) {
    let #(y, x) = coords
    y >= 0 && y < height && x >= 0 && x < width
  })
  |> list.length
}

type Coord =
  #(Int, Int)

fn possible_antinodes(
  from node: Coord,
  with all_same_freq: List(Coord),
) -> List(Coord) {
  all_same_freq
  |> list.filter_map(fn(other) {
    case node == other {
      True -> Error(Nil)
      False -> {
        let #(node_y, node_x) = node
        let #(other_y, other_x) = other
        let anti_y = 2 * other_y - node_y
        let anti_x = 2 * other_x - node_x
        Ok(#(anti_y, anti_x))
      }
    }
  })
}

pub fn pt_2(input: Input) {
  let height = input |> list.length
  let assert [first_row, ..] = input
  let width = first_row |> string.length
  let grid =
    input
    |> list.index_map(fn(row, row_idx) {
      row
      |> string.to_graphemes
      |> list.index_map(fn(ch, col_idx) { #(#(row_idx, col_idx), ch) })
    })
    |> list.flatten
    |> dict.from_list

  let different_freqs =
    input
    |> string.join("")
    |> string.to_graphemes
    |> list.filter(fn(x) { x != "." })
    |> set.from_list

  different_freqs
  |> set.to_list
  |> list.flat_map(fn(f) {
    let antennas = grid |> dict.filter(fn(_, v) { v == f }) |> dict.keys
    antennas
    |> list.flat_map(fn(coord) {
      possible_antinodes_2(from: coord, with: antennas, size: #(width, height))
    })
  })
  |> set.from_list
  |> set.to_list
  |> list.filter(fn(coords) {
    let #(y, x) = coords
    y >= 0 && y < height && x >= 0 && x < width
  })
  |> list.length
}

fn possible_antinodes_2(
  from node: Coord,
  with all_same_freq: List(Coord),
  size size: Coord,
) -> List(Coord) {
  // let #(width, height) = size
  all_same_freq
  |> list.filter_map(fn(other) {
    case node == other {
      True -> Error(Nil)
      False -> {
        // let #(node_y, node_x) = node
        // let #(other_y, other_x) = other
        let diff = diff_coords(other, node)
        Ok(all_in_line(from: node, step: diff, size: size))
      }
    }
  })
  |> list.flatten
}

fn all_in_line(
  from node: Coord,
  step dir: Coord,
  size size: Coord,
) -> List(Coord) {
  let #(width, height) = size
  let new_point = add_coords(node, dir)
  case
    new_point.0 < 0
    || new_point.0 >= height
    || new_point.1 < 0
    || new_point.1 >= width
  {
    True -> []
    False -> {
      [new_point, ..all_in_line(new_point, dir, size)]
    }
  }
}

fn add_coords(a: Coord, b: Coord) -> Coord {
  #(a.0 + b.0, a.1 + b.1)
}

fn diff_coords(a: Coord, b: Coord) -> Coord {
  #(a.0 - b.0, a.1 - b.1)
}
