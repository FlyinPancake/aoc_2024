import gleam/string
import simplifile

pub fn read_task_input(day: String) {
  let assert Ok(contents) =
    simplifile.read(from: string.concat(["input/2024/", day, ".txt"]))
  contents
}

pub fn read_example_input(day: String) -> String {
  read_task_input(day <> ".example")
}
