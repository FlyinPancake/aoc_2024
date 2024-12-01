import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn main() {
  io.println("Hello Day 1")
}

pub fn task_1(input: String) -> Int {
  let numbers =
    input
    |> string.split("\n")
    |> list.map(with: fn(line: String) -> Result(List(Int), Nil) {
      line
      |> string.split("   ")
      |> list.map(fn(n: String) -> Result(Int, Nil) { n |> int.parse() })
      |> result.all()
    })
    |> result.all
    |> result.lazy_unwrap(fn() -> List(List(Int)) { panic as "malformed input" })

  let assert [first_col, second_col] =
    numbers
    |> list.transpose
    |> list.map(fn(x) { x |> list.sort(by: int.compare) })
  list.map2(first_col, second_col, fn(first, second) {
    first - second
    |> int.absolute_value
  })
  |> int.sum
}

pub fn task_2(input: String) -> Int {
  let numbers =
    input
    |> string.split("\n")
    |> list.map(with: fn(line: String) -> Result(List(Int), Nil) {
      line
      |> string.split("   ")
      |> list.map(fn(n: String) -> Result(Int, Nil) { n |> int.parse() })
      |> result.all()
    })
    |> result.all
    |> result.lazy_unwrap(fn() -> List(List(Int)) { panic as "malformed input" })

  let first_col =
    numbers
    |> list.map(fn(x) {
      let assert [first, _] = x
      first
    })
    |> list.sort(by: int.compare)
    |> list.chunk(fn(x) { x })
    |> list.map(fn(li) {
      let assert Ok(num) = list.first(li)
      let len = list.length(li)
      #(num, len)
    })
    |> dict.from_list
  let second_col =
    numbers
    |> list.map(fn(x) {
      let assert [_, second] = x
      second
    })
    |> list.sort(by: int.compare)
    |> list.chunk(fn(x) { x })
    |> list.map(fn(li) {
      let assert Ok(num) = list.first(li)
      let len = list.length(li)
      #(num, len)
    })
    |> dict.from_list

  first_col
  |> dict.fold(from: 0, with: fn(acc, key, value) {
    let times_in_other = second_col |> dict.get(key) |> result.unwrap(0)

    acc + times_in_other * value * key
  })
}
