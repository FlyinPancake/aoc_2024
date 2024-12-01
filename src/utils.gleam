import gleam/string
import simplifile

pub fn read_task_input(day: String) {
  let assert Ok(contents) =
    simplifile.read(from: string.concat(["test/inputs/day_", day, ".txt"]))
  contents
}

pub fn read_example_1_input(day: String) -> String {
  let assert Ok(contents) =
    simplifile.read(
      from: string.concat(["test/inputs/day_", day, "_example_1.txt"]),
    )
  contents
}

pub fn read_example_2_input(day: String) -> String {
  let assert Ok(contents) =
    simplifile.read(
      from: string.concat(["test/inputs/day_", day, "_example_2.txt"]),
    )
  contents
}
