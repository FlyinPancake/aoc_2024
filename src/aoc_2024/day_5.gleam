import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Input {
  Input(rules: List(#(Int, Int)), pages: List(List(Int)))
}

pub fn parse(input: String) -> Input {
  let lines = input |> string.split("\n")

  let rules =
    lines
    |> list.take_while(fn(l) { string.length(l) != 0 })
    |> list.map(fn(l) {
      let assert [a, b] = l |> string.split("|") |> list.filter_map(int.parse)
      #(a, b)
    })

  let pages =
    lines
    |> list.drop_while(fn(l) { string.length(l) != 0 })
    |> list.rest()
    |> result.lazy_unwrap(fn() { panic })
    |> list.take_while(fn(l) { string.length(l) != 0 })
    |> list.map(fn(l) { l |> string.split(",") |> list.filter_map(int.parse) })

  Input(rules, pages)
}

pub fn pt_1(input: Input) -> Int {
  let Input(rules, pages) = input

  pages
  |> list.filter(fn(pages) {
    pages
    |> list.all(fn(page) {
      let prev = pages |> list.take_while(fn(p) { p != page })
      let req_before =
        rules
        |> list.filter_map(fn(r) {
          case r {
            #(p, a) if a == page -> Ok(p)
            _ -> Error(Nil)
          }
        })
        |> list.filter(fn(p) { list.contains(pages, p) })

      req_before |> list.all(fn(p) { list.contains(prev, p) })
    })
  })
  |> list.map(fn(li) {
    let len = li |> list.length
    let assert [hd, ..] = li |> list.drop({ len - 1 } / 2)
    hd
  })
  |> int.sum
}

pub fn pt_2(input: Input) {
  let Input(rules, pages) = input
  pages
  |> list.filter(fn(pages) {
    pages
    |> list.all(fn(page) {
      let prev = pages |> list.take_while(fn(p) { p != page })
      let req_before =
        rules
        |> list.filter_map(fn(r) {
          case r {
            #(p, a) if a == page -> Ok(p)
            _ -> Error(Nil)
          }
        })
        |> list.filter(fn(p) { list.contains(pages, p) })

      req_before |> list.all(fn(p) { list.contains(prev, p) })
    })
    |> bool.negate
  })
  |> list.map(fn(pages) {
    pages
    |> list.map(fn(page) {
      let req_before =
        rules
        |> list.filter_map(fn(r) {
          case r {
            #(p, a) if a == page -> Ok(p)
            _ -> Error(Nil)
          }
        })
        |> list.filter(fn(p) { list.contains(pages, p) })
      #(page, req_before)
    })
    |> list.sort(fn(a, b) {
      let #(_, a_req) = a
      let #(_, b_req) = b
      int.compare(list.length(a_req), list.length(b_req))
    })
    |> list.map(fn(el) {
      let #(e, _) = el
      e
    })
  })
  |> list.map(fn(li) {
    let len = li |> list.length
    let assert [hd, ..] = li |> list.drop({ len - 1 } / 2)
    hd
  })
  |> int.sum
}
