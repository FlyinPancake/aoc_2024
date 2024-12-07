import gleam/int
import gleam/list
import gleam/result
import gleam/string
import parallel_map

type Input =
  List(Equation)

type Equation =
  #(Int, List(Int))

type Operator {
  Add
  Mul
  Concat
}

pub fn parse(input: String) -> Input {
  input
  |> string.split("\n")
  |> list.map(fn(r) {
    let assert [sum, ..rest] = r |> string.split(":")
    let rest =
      rest
      |> list.map(fn(r) {
        let assert Ok(nums) =
          r
          |> string.trim
          |> string.split(" ")
          |> list.map(int.parse)
          |> result.all
        nums
      })
      |> list.flatten
    let assert Ok(sum) = int.parse(sum)
    #(sum, rest)
  })
}

pub fn pt_1(input: Input) -> Int {
  input
  |> list.map(fn(el) { #(el, can_be_true(el)) })
  |> list.filter_map(fn(el) {
    case el.1 {
      False -> Error(Nil)
      True -> Ok(el.0.0)
    }
  })
  |> int.sum
}

fn can_be_true(eq: Equation) -> Bool {
  let #(sum, nums) = eq
  let op_lists = operator_lists(list.length(nums) - 1)
  op_lists
  |> list.map(fn(el) {
    list.map2([Add, ..el], nums, fn(op, num) { #(op, num) })
    |> list.fold(from: 0, with: fn(acc, el) {
      let #(op, num) = el
      case op {
        Add -> acc + num
        Mul -> acc * num
        Concat -> panic as "no concat in pt 1"
      }
    })
  })
  |> list.contains(sum)
}

fn operator_lists(len: Int) -> List(List(Operator)) {
  case len {
    0 -> []
    1 -> [[Add], [Mul]]
    _ -> {
      let prev =
        operator_lists(len - 1)
        |> list.map(fn(el) { [[Add, ..el], [Mul, ..el]] })
        |> list.flatten
      prev
    }
  }
}

pub fn pt_2(input: Input) {
  // [#(7290, [6, 8, 6, 15])]
  input
  |> parallel_map.list_pmap(
    fn(el) { #(el, can_be_true2(el)) },
    parallel_map.MatchSchedulersOnline,
    1_000_000,
  )
  |> list.filter_map(fn(x) { x })
  |> list.filter_map(fn(el) {
    case el.1 {
      False -> Error(Nil)
      True -> Ok(el.0.0)
    }
  })
  |> int.sum
}

fn can_be_true2(eq: Equation) -> Bool {
  let #(sum, nums) = eq
  let op_lists = operator_lists2(list.length(nums) - 1)
  op_lists
  |> list.map(fn(el) {
    list.map2([Add, ..el], nums, fn(op, num) { #(op, num) })
    |> list.fold(from: 0, with: fn(acc, el) {
      let #(op, num) = el
      case op {
        Add -> acc + num
        Mul -> acc * num
        Concat ->
          int.parse(int.to_string(acc) <> int.to_string(num))
          |> result.lazy_unwrap(fn() { panic })
      }
    })
  })
  |> list.contains(sum)
}

fn operator_lists2(len: Int) -> List(List(Operator)) {
  case len {
    0 -> []
    1 -> [[Add], [Mul], [Concat]]
    _ -> {
      let prev =
        operator_lists2(len - 1)
        |> list.map(fn(el) { [[Add, ..el], [Mul, ..el], [Concat, ..el]] })
        |> list.flatten
      prev
    }
  }
}
