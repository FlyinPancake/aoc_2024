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
  |> checksum
}

fn defrag(disk: List(BlockContents)) -> List(BlockContents) {
  case disk {
    [] -> []
    [EmptySpace] -> []
    [EmptySpace, ..rest] -> {
      let assert [last, ..rest] = list.reverse(rest)
      defrag([last, ..list.reverse(rest)])
    }
    [first, ..rest] -> {
      [first, ..defrag(rest)]
    }
  }
}

fn checksum(disk: List(BlockContents)) -> Int {
  disk
  |> list.index_fold(from: 0, with: fn(acc, el, idx) {
    case el {
      FileContents(el) -> acc + { el * idx }
      EmptySpace -> acc
    }
  })
}

pub fn pt_2(input: String) {
  let assert Ok(input) =
    input |> string.to_graphemes |> list.map(int.parse) |> result.all

  let disk =
    input
    |> list.sized_chunk(2)
    |> list.index_map(fn(el, idx) {
      case el |> list.length {
        1 -> {
          let assert [n] = el
          [FileChunkContents(id: idx, size: n)]
        }
        2 -> {
          let assert [file_len, free_len] = el
          [
            FileChunkContents(id: idx, size: file_len),
            EmptyChunks(size: free_len),
          ]
        }
        _ -> panic
      }
    })
    |> list.flatten
  print_chunked_disk(disk)
  let defragged =
    disk
    |> list.reverse
    |> defrag_chunked
    |> list.reverse
  print_chunked_disk(defragged)

  checksum_chunked(defragged)
}

fn defrag_chunked(disk_rev: ChunkedDisk) -> ChunkedDisk {
  case disk_rev {
    [] -> []
    [el] -> [el]
    [FileChunkContents(id: id, size: file_size), ..rest] -> {
      let rest_correct_ord = rest |> list.reverse
      let #(front, tail) =
        list.split_while(rest_correct_ord, fn(el) {
          case el {
            FileChunkContents(_, _) -> True
            EmptyChunks(space) -> space < file_size
          }
        })

      case tail |> list.length {
        0 -> [
          FileChunkContents(id: id, size: file_size),
          ..defrag_chunked(rest)
        ]
        _ -> {
          let assert [EmptyChunks(empty_chunk_size), ..tail_wo_empty] = tail
          let rem_space_pad = case empty_chunk_size - file_size {
            0 -> []
            rem -> [EmptyChunks(rem)]
          }
          let result =
            [
              front,
              [FileChunkContents(id: id, size: file_size)],
              rem_space_pad,
              tail_wo_empty,
              [EmptyChunks(file_size)],
            ]
            |> list.flatten
            |> list.reverse

          let assert [new_last, ..new_rest] = result
          [new_last, ..defrag_chunked(new_rest)]
        }
      }
    }
    [EmptyChunks(size: size), ..rest] -> [
      EmptyChunks(size),
      ..defrag_chunked(rest)
    ]
  }
}

fn checksum_chunked(disk: ChunkedDisk) -> Int {
  disk
  |> list.flat_map(fn(el) {
    case el {
      EmptyChunks(size) -> list.repeat(EmptySpace, size)
      FileChunkContents(id: id, size: size) ->
        list.repeat(FileContents(id: id), size)
    }
  })
  |> checksum
}

fn print_chunked_disk(l: ChunkedDisk) {
  case l {
    [EmptyChunks(size), ..r] -> {
      io.print_error("." |> string.repeat(size))
      print_chunked_disk(r)
    }
    [FileChunkContents(id: id, size: size), ..r] -> {
      io.print_error(int.to_string(id) |> string.repeat(size))
      print_chunked_disk(r)
    }
    [] -> io.println_error("")
  }
}

type ChunkedDisk =
  List(ChunkContents)

type ChunkContents {
  FileChunkContents(id: Int, size: Int)
  EmptyChunks(size: Int)
}
