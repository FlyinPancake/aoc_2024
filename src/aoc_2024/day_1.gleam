import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> #(List(Int), List(Int)) {
  input
  |> string.split("\n")
  |> list.filter(fn(x) { string.length(x) > 0 })
  |> list.map(with: fn(line: String) -> Result(List(Int), Nil) {
    line
    |> string.split("   ")
    |> list.map(fn(n: String) -> Result(Int, Nil) { n |> int.parse() })
    |> result.all
  })
  |> result.all
  |> result.lazy_unwrap(fn() { panic as "malformed input" })
  |> list.map(fn(x) {
    let assert [l, r] = x
    #(l, r)
  })
  |> list.unzip
}

pub fn pt_1(input: #(List(Int), List(Int))) -> Int {
  let #(left_col, right_col) = input
  let left_col_sorted = list.sort(left_col, int.compare)
  let right_col_sorted = list.sort(right_col, int.compare)
  list.map2(left_col_sorted, right_col_sorted, fn(lhs, rhs) {
    lhs - rhs |> int.absolute_value
  })
  |> int.sum
}

pub fn pt_2(input: #(List(Int), List(Int))) -> Int {
  let #(left_col, right_col) = input

  let left_counts = with_counts(left_col)
  let right_counts = with_counts(right_col)

  left_counts
  |> dict.fold(from: 0, with: fn(acc, k, v) {
    let times_in_other = dict.get(right_counts, k) |> result.unwrap(0)

    acc + times_in_other * v * k
  })
}

fn with_counts(li: List(Int)) -> Dict(Int, Int) {
  li
  |> list.sort(int.compare)
  |> list.chunk(function.identity)
  |> list.map(fn(inner_list) {
    let len = list.length(inner_list)
    let assert Ok(num) = list.first(inner_list)
    #(num, len)
  })
  |> dict.from_list
}
