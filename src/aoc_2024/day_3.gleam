import gleam/int
import gleam/list
import gleam/option
import gleam/regexp.{Match}
import gleam/result
import gleam/string

pub fn parse(input: String) -> String {
  input
}

pub fn pt_1(input: String) {
  let assert Ok(mul_regex) = regexp.from_string("mul\\(([\\d]+,[\\d]+)\\)")
  // let regex_options = regex.Options(case_insensitive: False, multi_line: False)
  let matches = regexp.scan(mul_regex, input)
  matches
  |> list.map(fn(x) {
    let assert regexp.Match(_, [inner]) = x
    let assert option.Some(inner) = inner
    inner
    |> string.split(",")
    |> list.map(fn(l) { l |> int.parse() |> result.lazy_unwrap(fn() { panic }) })
    |> int.product()
  })
  |> int.sum()
}

pub type Pain {
  Pain(discarding: Bool, sum: Int)
}

pub fn pt_2(input: String) {
  let assert Ok(re) =
    regexp.from_string("mul\\(([\\d]+,[\\d]+)\\)|do\\(\\)|don't\\(\\)")
  let folded =
    input
    |> regexp.scan(with: re)
    |> list.fold(from: Pain(discarding: False, sum: 0), with: fn(acc, m) {
      let Match(op, _) = m
      case op {
        "do()" -> Pain(discarding: False, sum: acc.sum)
        "don't()" -> Pain(discarding: True, sum: acc.sum)
        _ -> {
          case acc.discarding {
            False -> {
              let assert regexp.Match(_, [inner]) = m
              let assert option.Some(inner) = inner

              let prod =
                inner
                |> string.split(",")
                |> list.map(fn(l) {
                  l |> int.parse() |> result.lazy_unwrap(fn() { panic })
                })
                |> int.product()
              Pain(discarding: False, sum: acc.sum + prod)
            }
            True -> acc
          }
        }
      }
    })
  folded.sum
}
