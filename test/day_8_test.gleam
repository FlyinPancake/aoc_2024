import aoc_2024/day_8
import gleam/io
import gleeunit
import gleeunit/should
import tempo/duration
import tempo/time
import utils

const day: String = "8"

pub fn main() {
  gleeunit.main()
}

pub fn task_1_test() {
  let example_input = utils.read_example_input(day) |> day_8.parse
  day_8.pt_1(example_input) |> should.equal(14)
  let start = time.now_local()
  day_8.pt_1(utils.read_task_input(day) |> day_8.parse)
  |> should.equal(369)
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
  let example_input = utils.read_example_input(day) |> day_8.parse
  day_8.pt_2(example_input) |> should.equal(34)
  let start = time.now_local()
  day_8.pt_2(utils.read_task_input(day) |> day_8.parse)
  |> should.equal(1169)
  {
    { "day " <> day <> ". task 2 took: " }
    <> start
    |> time.difference_abs(time.now_local())
    |> duration.format_as(duration.Microsecond, 0)
  }
  |> io.println_error
}
