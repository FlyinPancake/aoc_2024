import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> String {
  input
}

type BlockContents {
  FileContents(id: Int)
  EmptySpace
}

fn print_disk(l: List(BlockContents)) {
  case l {
    [EmptySpace, ..r] -> {
      io.print_error(".")
      print_disk(r)
    }
    [FileContents(i), ..r] -> {
      io.print_error(int.to_string(i))
      print_disk(r)
    }
    [] -> io.println_error("")
  }
}

pub fn pt_1(input: String) {
  let assert Ok(input) =
    input
    |> string.trim
    |> string.to_graphemes
    |> list.map(int.parse)
    |> result.all

  input
  |> list.sized_chunk(2)
  |> list.index_map(fn(el, idx) {
    case el |> list.length {
      1 -> {
        let assert [n] = el
        list.repeat(FileContents(id: idx), n)
      }
      2 -> {
        let assert [file_len, free_len] = el
        list.flatten([
          list.repeat(FileContents(idx), file_len),
          list.repeat(EmptySpace, free_len),
        ])
      }
      _ -> panic
    }
  })
  |> list.flatten
  |> defrag
  |> print_disk
}

fn defrag(disk: List(BlockContents)) -> List(BlockContents) {
  case disk {
    [] -> []
    [EmptySpace, ..rest] -> {
      let assert [last, ..rest] = list.reverse(rest)
      defrag([last, ..list.reverse(rest)])
    }
    [first, ..rest] -> {
      [first, ..defrag(rest)]
    }
  }
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
