defmodule Day13 do
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
    "#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-13")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    prepare_data_inner(data, [{[], []}])
  end

  def prepare_data_inner([], blocks), do: blocks

  def prepare_data_inner(["" | rest], blocks), do: prepare_data_inner(rest, [{[], []} | blocks])

  def prepare_data_inner([row | rest], [{[], []} | blocks]) do
    prepare_data_inner(rest, [{[row], row |> String.split("", trim: true)} | blocks])
  end

  def prepare_data_inner([row | rest], [{rows, cols} | blocks]) do
    prepare_data_inner(rest, [
      {[row | rows],
       cols
       |> Enum.zip(row |> String.split("", trim: true))
       |> Enum.map(fn {col, ch} -> "#{col}#{ch}" end)}
      | blocks
    ])
  end

  def part1(data) do
    data
    |> Enum.map(fn {rows, cols} ->
      r_sym = symetry(rows |> Enum.reverse(), [], 0)
      c_sym = symetry(cols, [], 0)
      c_sym + 100 * r_sym
    end)
    |> Enum.sum()
  end

  def part2(data) do
    data
    |> Enum.map(fn {rows, cols} ->
      r_sym = symetry_one_change(rows |> Enum.reverse(), [], 0)
      c_sym = symetry_one_change(cols, [], 0)
      c_sym + 100 * r_sym
    end)
    |> Enum.sum()
  end

  def symetry([], _, _), do: 0
  def symetry([a | rest], [], 0), do: symetry(rest, [a], 1)
  def symetry(_, [], _), do: 0

  def symetry([a | rest], [a | sym_rest], index) do
    if verify_symetry(rest, sym_rest) do
      index
    else
      symetry(rest, [a, a | sym_rest], index + 1)
    end
  end

  def symetry([a | rest], sym_rest, index), do: symetry(rest, [a | sym_rest], index + 1)

  def verify_symetry([], _), do: true
  def verify_symetry(_, []), do: true
  def verify_symetry([a | rest_a], [a | rest_b]), do: verify_symetry(rest_a, rest_b)
  def verify_symetry(_, _), do: false

  def symetry_one_change([], _, _), do: 0
  def symetry_one_change([a | rest], [], 0), do: symetry_one_change(rest, [a], 1)

  def symetry_one_change([a | rest_a], [a | sym_rest], index) do
    if verify_symetry_one_change(rest_a, sym_rest) do
      index
    else
      symetry_one_change(rest_a, [a, a | sym_rest], index + 1)
    end
  end

  def symetry_one_change([a | rest], [b | sym_rest], index) do
    if delta_is_one(a, b) and verify_symetry(rest, sym_rest) do
      index
    else
      symetry_one_change(rest, [a, b | sym_rest], index + 1)
    end
  end

  def verify_symetry_one_change([], _), do: false
  def verify_symetry_one_change(_, []), do: false

  def verify_symetry_one_change([a | rest_a], [a | rest_b]),
    do: verify_symetry_one_change(rest_a, rest_b)

  def verify_symetry_one_change([a | rest_a], [b | rest_b]) do
    if delta_is_one(a, b) and verify_symetry(rest_a, rest_b) do
      true
    else
      false
    end
  end

  def delta_is_one(a, b) do
    delta_cnt =
      a
      |> String.graphemes()
      |> Enum.zip(b |> String.graphemes())
      |> Enum.reduce(
        0,
        fn
          {a, a}, cnt -> cnt
          {_, _}, cnt -> cnt + 1
        end
      )

    delta_cnt == 1
  end
end
