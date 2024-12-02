default:
  just --choose

download_day DAY:
  aoc download -d {{DAY}} -y 2024 -i input/{{DAY}}.txt -p docs/tasks/puzzle_{{DAY}}.md -o

new_day DAY:
  gleam run new {{DAY}} --parse=true --example=true --year=2024
  just download_day {{DAY}}

test:
  gleam test

run DAY:
  gleam run run {{DAY}}

rune DAY:
  gleam run run {{DAY}} --example