import aoc_2024/day_7
import gleam/io
import gleeunit
import gleeunit/should
import tempo/duration
import tempo/time
import utils

const day: String = "7"

pub fn main() {
  gleeunit.main()
}

pub fn task_1_test() {
  let example_input = utils.read_example_input(day) |> day_7.parse
  day_7.pt_1(example_input) |> should.equal(3749)
  let start = time.now_local()
  day_7.pt_1(utils.read_task_input(day) |> day_7.parse)
  |> should.equal(12_553_187_650_171)
  let end = time.now_local()
  {
    { "day " <> day <> ". task 1 took: " }
    <> {
      start
      |> time.difference_abs(end)
      |> duration.format_as(duration.Microsecond, 0)
    }
  }
  |> io.println_error
}

pub fn task_2_test() {
  let example_input = utils.read_example_input(day) |> day_7.parse
  day_7.pt_2(example_input) |> should.equal(11_387)
  let start = time.now_local()
  day_7.pt_2(utils.read_task_input(day) |> day_7.parse)
  |> should.equal(96_779_702_119_491)
  {
    { "day " <> day <> ". task 2 took: " }
    <> start
    |> time.difference_abs(time.now_local())
    |> duration.format_as(duration.Microsecond, 0)
  }
  |> io.println_error
}
