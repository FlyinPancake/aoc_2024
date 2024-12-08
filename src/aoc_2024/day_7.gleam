import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Input =
  List(Equation)

type Equation =
  #(Int, List(Int))

pub fn parse(input: String) -> Input {
  input
  |> string.split("\n")
  |> list.filter(fn(el) { !string.is_empty(el) })
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
  |> list.map(fn(el) {
    let #(sum, nums) = el
    #(sum, list.reverse(nums))
  })
  |> list.map(fn(el) { #(el, check_row(el)) })
  |> list.filter_map(fn(el) {
    case el.1 {
      False -> Error(Nil)
      True -> Ok(el.0.0)
    }
  })
  |> int.sum
}

fn check_row(eq: Equation) -> Bool {
  let #(sum, nums) = eq

  case nums |> list.is_empty {
    True -> sum == 0
    False -> {
      let assert [num, ..rest] = nums
      let sub = check_row(#(sum - num, rest))
      let div = case sum % num == 0 {
        True -> check_row(#(sum / num, rest))
        False -> False
      }
      sub || div
    }
  }
}

pub fn pt_2(input: Input) {
  // [#(7290, [6, 8, 6, 15])]
  input
  |> list.map(fn(el) {
    let #(res, nums) = el
    #(el, check_row_concat(#(res, nums |> list.reverse)))
  })
  |> list.filter_map(fn(el) {
    case el.1 {
      False -> Error(Nil)
      True -> Ok(el.0.0)
    }
  })
  |> int.sum
}

fn check_row_concat(eq: Equation) -> Bool {
  let #(res, nums) = eq

  case list.is_empty(nums) {
    True -> res == 0
    False -> {
      let assert [num, ..rest] = nums
      let sub = check_row_concat(#(res - num, rest))
      let div = case res % num {
        0 -> check_row_concat(#(res / num, rest))
        _ -> False
      }
      let res_str = int.to_string(res)
      let num_str = int.to_string(num)
      let concat = case res_str |> string.ends_with(num_str) && res > 0 {
        True -> {
          let new_res_str = string.drop_end(res_str, num_str |> string.length)
          case new_res_str |> string.is_empty {
            True -> rest == []
            False -> {
              let assert Ok(new_res) = new_res_str |> int.parse
              check_row_concat(#(new_res, rest))
            }
          }
        }
        False -> False
      }
      sub || div || concat
    }
  }
}
