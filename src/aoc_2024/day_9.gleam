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
    let assert FileContents(el) = el
    acc + { el * idx }
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
    |> defrag_chunked
  print_chunked_disk(defragged)

  checksum_chunked(defragged)
}

fn defrag_chunked(disk: ChunkedDisk) -> ChunkedDisk {
  print_chunked_disk(disk)
  case disk {
    [] -> []
    [EmptyChunks(_)] -> []
    [EmptyChunks(size: empty_size), ..rest] -> {
      let rrest = rest |> list.reverse
      let #(no_change, maybe_found) =
        list.split_while(rrest, fn(el) {
          case el {
            EmptyChunks(_) -> True
            FileChunkContents(_, size: size) -> {
              size >= empty_size
            }
          }
        })
      let assert [first, ..rest] = case maybe_found |> list.length {
        0 -> rest
        _ -> {
          let assert [FileChunkContents(id: index, size: size), ..mf_rest] =
            maybe_found
          let ec_padding = case empty_size - size {
            0 -> []
            rem -> [EmptyChunks(rem)]
          }
          [
            no_change,
            [EmptyChunks(size)],
            mf_rest,
            ec_padding,
            [FileChunkContents(index, size)],
          ]
          |> list.flatten
          |> list.reverse
        }
      }

      [first, ..defrag_chunked(rest)]
    }
    [first, ..rest] -> [first, ..defrag_chunked(rest)]
  }
}

fn checksum_chunked(disk: ChunkedDisk) -> Int {
  disk
  |> list.index_fold(0, fn(acc, cc, idx) {
    case cc {
      FileChunkContents(id, _) -> acc + { id * idx }
      _ -> acc
    }
  })
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
