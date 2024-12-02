import gleam/function.{identity}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Input =
  List(List(Int))

pub fn parse(input: String) -> Input {
  input
  |> string.split("\n")
  |> list.filter(fn(x) { string.length(x) > 0 })
  |> list.map(with: fn(line: String) -> Result(List(Int), Nil) {
    line
    |> string.split(" ")
    |> list.map(fn(n: String) -> Result(Int, Nil) { n |> int.parse() })
    |> result.all()
  })
  |> result.all
  |> result.lazy_unwrap(fn() -> List(List(Int)) { panic as "malformed input" })
}

pub fn pt_1(input: Input) -> Int {
  input
  |> list.map(fn(row) {
    let #(steps, signs) =
      row
      |> list.window_by_2
      |> list.map(fn(win) {
        let #(left, right) = win
        let diff = left - right
        let step_ok =
          int.absolute_value(diff) <= 3 && int.absolute_value(diff) > 0
        let sign = int.clamp(diff, min: -1, max: 1)
        #(step_ok, sign)
      })
      |> list.unzip
    let all_steps =
      steps
      |> list.all(fn(x) { x })

    let signs_eq =
      signs
      |> list.window_by_2
      |> list.map(fn(x) {
        let #(l, r) = x
        l == r
      })
      |> list.all(fn(x) { x })
    all_steps && signs_eq
  })
  |> list.filter(fn(x) { x })
  |> list.length
}

pub fn pt_2(input: Input) {
  input
  |> list.map(fn(row) {
    row
    |> all_with_dropping_one
    |> list.any(fn(row) {
      let #(steps, signs) =
        row
        |> list.window_by_2
        |> list.map(fn(win) {
          let #(left, right) = win
          let diff = left - right
          let step_ok =
            int.absolute_value(diff) <= 3 && int.absolute_value(diff) > 0
          let sign = int.clamp(diff, min: -1, max: 1)
          #(step_ok, sign)
        })
        |> list.unzip
      let all_steps =
        steps
        |> list.all(identity)

      let signs_eq =
        signs
        |> list.window_by_2
        |> list.all(fn(x) {
          let #(l, r) = x
          l == r
        })
      all_steps && signs_eq
    })
  })
  |> list.filter(fn(x) { x })
  |> list.length
}

fn all_with_dropping_one(li: List(_)) -> List(List(_)) {
  li
  |> list.index_map(fn(_, i) {
    li
    |> list.index_fold([], fn(acc, item, idx) {
      case i == idx {
        True -> acc
        False -> list.append(acc, [item])
      }
    })
  })
}
