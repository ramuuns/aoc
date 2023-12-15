defmodule Day14 do
  def run(mode) do
    data = read_input(mode)

    [{1, data}, {2, data}]
    |> Task.async_stream(
      fn
        {1, data} -> {1, data |> part1}
        {2, data} -> {2, data |> part2}
      end,
      timeout: :infinity
    )
    |> Enum.reduce({0, 0}, fn
      {_, {1, res}}, {_, p2} -> {res, p2}
      {_, {2, res}}, {p1, _} -> {p1, res}
    end)
  end

  def read_input(:test) do
    "O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#...."
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-14")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data |> make_columns([], 0)
  end

  def make_columns([], cols, row_count),
    do: {cols |> Enum.map(fn col -> col |> Enum.reverse() end), row_count}

  def make_columns([row | rest], [], 0),
    do: make_columns(rest, row |> String.split("", trim: true) |> Enum.map(fn c -> [c] end), 1)

  def make_columns([row | rest], cols, cnt),
    do:
      make_columns(
        rest,
        cols
        |> Enum.zip(row |> String.split("", trim: true))
        |> Enum.map(fn {col, c} -> [c | col] end),
        cnt + 1
      )

  def part1({cols, cnt}) do
    cols
    |> tilt_north([])
    |> count_load(cnt, 0)
  end

  def tilt_north([], tilted), do: tilted
  def tilt_north([col | rest], tilted), do: tilt_north(rest, [tilt(col) | tilted])

  def tilt(col) when is_binary(col) do
    if res = Process.get(col) do
      res
    else
      res =
        col
        |> String.split("#")
        |> Enum.map(&move_rocks_to_top/1)
        |> Enum.join("#")

      Process.put(col, res)
      res
    end
  end

  def tilt(col) do
    if res = Process.get(col) do
      res
    else
      res =
        col
        |> mrtt_arr([], [], [])

      Process.put(col, res)
      res
    end
  end

  def mrtt_arr([], rocks, dots, res), do: [rocks ++ dots | res] |> add_hashes([])
  def mrtt_arr(["#" | rest], [], [], res), do: mrtt_arr(rest, [], [], [[] | res])
  def mrtt_arr(["#" | rest], rocks, [], res), do: mrtt_arr(rest, [], [], [rocks | res])
  def mrtt_arr(["#" | rest], [], dots, res), do: mrtt_arr(rest, [], [], [dots | res])
  def mrtt_arr(["#" | rest], rocks, dots, res), do: mrtt_arr(rest, [], [], [rocks ++ dots | res])
  def mrtt_arr(["." | rest], rocks, dots, res), do: mrtt_arr(rest, rocks, ["." | dots], res)
  def mrtt_arr(["O" | rest], rocks, dots, res), do: mrtt_arr(rest, ["O" | rocks], dots, res)

  def add_hashes([], res), do: res
  def add_hashes([rocks_dots], res), do: add_hashes([], rocks_dots ++ res)
  def add_hashes([[] | rest], res), do: add_hashes(rest, ["#" | res])
  def add_hashes([rocks_dots | rest], res), do: add_hashes(rest, ["#" | rocks_dots ++ res])

  def move_rocks_to_top(str) do
    if res = Process.get(str) do
      res
    else
      res = str |> rocks_dots([], [])
      Process.put(str, res)
      res
    end
  end

  def rocks_dots("", rocks, dots), do: (rocks |> Enum.join("")) <> (dots |> Enum.join(""))
  def rocks_dots("O" <> rest, rocks, dots), do: rocks_dots(rest, ["O" | rocks], dots)
  def rocks_dots("." <> rest, rocks, dots), do: rocks_dots(rest, rocks, ["." | dots])

  def count_load([], _, load), do: load

  def count_load([col | rest], row_count, load),
    do: count_load(rest, row_count, col_load(col, row_count, 0) + load)

  def col_load("", _, load), do: load
  def col_load("O" <> rest, col, load), do: col_load(rest, col - 1, load + col)
  def col_load(<<_::utf8, rest::binary>>, col, load), do: col_load(rest, col - 1, load)

  def col_load([], _, load), do: load
  def col_load(["O" | rest], col, load), do: col_load(rest, col - 1, load + col)
  def col_load([_ | rest], col, load), do: col_load(rest, col - 1, load)

  def part2({cols, cnt}) do
    {cycle_start, cycle_length, states} = run_cycle_until_cycle(cols, %{}, %{}, 0)

    index = rem(1_000_000_000 - cycle_start, cycle_length) + cycle_start

    Map.get(states, index)
    |> count_load(cnt, 0)
  end

  def run_cycle_until_cycle(cols, states_to_index, index_to_states, index) do
    if Map.has_key?(states_to_index, cols) do
      cycle_start = Map.get(states_to_index, cols)
      {cycle_start, index - cycle_start, index_to_states}
    else
      run_cycle_until_cycle(
        cols |> cycle,
        states_to_index |> Map.put(cols, index),
        index_to_states |> Map.put(index, cols),
        index + 1
      )
    end
  end

  def cycle(data) do
    data
    |> tilt_north([])
    |> rotate([])
    |> tilt_north([])
    |> rotate([])
    |> tilt_north([])
    |> rotate([])
    |> tilt_north([])
    |> rotate([])
  end

  def rotate([], res), do: res |> reverse_join([])
  def rotate([row | rest], []), do: rotate(rest, row |> Enum.map(fn s -> [s] end))

  def rotate([row | rest], cols),
    do:
      rotate(
        rest,
        cols |> prepend(row, [])
      )

  def prepend([], [], res), do: res |> Enum.reverse()

  def prepend([col | rest], ["." | row_rest], res),
    do: prepend(rest, row_rest, [["." | col] | res])

  def prepend([col | rest], ["#" | row_rest], res),
    do: prepend(rest, row_rest, [["#" | col] | res])

  def prepend([col | rest], ["O" | row_rest], res),
    do: prepend(rest, row_rest, [["O" | col] | res])

  def reverse_join([], res), do: res
  def reverse_join([col | rest], cols), do: reverse_join(rest, [col | cols])

  def print_cols(cols) do
    cols |> rotate([]) |> Enum.join("\n") |> IO.puts()
    IO.puts("\n\n")
  end

  def print_board(board) do
    board |> Enum.join("\n") |> IO.puts()
    IO.puts("\n")
    board
  end
end
