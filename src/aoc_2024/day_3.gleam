import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/result
import gleam/string

pub fn parse(input: String) -> String {
  input
}

pub fn pt_1(input: String) -> Int {
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

pub type Collector {
  Collector(discarding: Bool, sum: Int)
}

pub type Operator {
  Mul(a: Int, b: Int)
  Do
  DoNot
}

pub type OperatorParseError {
  NotFound
}

fn op_from_match(match: regexp.Match) -> Result(Operator, OperatorParseError) {
  case match {
    Match("do()", _) -> Ok(Do)
    Match("don't()", _) -> Ok(DoNot)
    Match(_, [Some(mul_inner)]) -> {
      let assert [a, b] =
        mul_inner
        |> string.split(",")
        |> list.map(int.parse)
        |> list.map(fn(n) { n |> result.lazy_unwrap(fn() { panic }) })
      Ok(Mul(a, b))
    }
    Match(_, _) -> Error(NotFound)
  }
}

pub fn pt_2(input: String) -> Int {
  let assert Ok(re) =
    regexp.from_string("mul\\(([\\d]+,[\\d]+)\\)|do\\(\\)|don't\\(\\)")
  let folded =
    input
    |> regexp.scan(with: re)
    |> list.map(op_from_match)
    |> list.fold(from: Collector(discarding: False, sum: 0), with: fn(acc, m) {
      case m, acc.discarding {
        Ok(Do), _ -> Collector(discarding: False, sum: acc.sum)
        Ok(DoNot), _ -> Collector(discarding: True, sum: acc.sum)
        Ok(Mul(a, b)), False -> {
          Collector(discarding: False, sum: acc.sum + a * b)
        }
        _, True -> acc
        _, False -> {
          let _ = m |> io.debug
          acc
        }
      }
    })
  folded.sum
}
