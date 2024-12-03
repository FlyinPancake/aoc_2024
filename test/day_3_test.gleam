import aoc_2024/day_3
import gleam/io
import gleeunit
import gleeunit/should
import tempo/duration
import tempo/time
import utils

const day: String = "3"

pub fn main() {
  gleeunit.main()
}

pub fn task_1_test() {
  let example_input = utils.read_example_input(day) |> day_3.parse
  day_3.pt_1(example_input) |> should.equal(161)
  let start = time.now_local()
  day_3.pt_1(utils.read_task_input(day) |> day_3.parse)
  |> should.equal(174_561_379)
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
  let example_input = utils.read_example_input(day) |> day_3.parse
  day_3.pt_2(example_input) |> should.equal(48)
  let start = time.now_local()
  day_3.pt_2(utils.read_task_input(day) |> day_3.parse)
  |> should.equal(106_921_067)
  {
    { "day " <> day <> ". task 2 took: " }
    <> start
    |> time.difference_abs(time.now_local())
    |> duration.format_as(duration.Microsecond, 0)
  }
  |> io.println_error
}
