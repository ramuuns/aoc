defmodule Day13 do
  import Bitwise
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

  def prepare_data_inner([], [{rows, cols} | blocks]), do: [{rows, cols |> Enum.map(fn col -> row_to_number(col, 0) end)} | blocks]

  def prepare_data_inner(["" | rest], [{rows, cols} | blocks]), do: prepare_data_inner(rest, [{[], []}, {rows, cols |> Enum.map(fn col -> row_to_number(col, 0) end)} | blocks])

  def prepare_data_inner([row | rest], [{[], []} | blocks]) do
    prepare_data_inner(rest, [{[row |> row_to_number(0)], row |> String.split("", trim: true)} | blocks])
  end

  def prepare_data_inner([row | rest], [{rows, cols} | blocks]) do
    prepare_data_inner(rest, [
      {[row |> row_to_number(0) | rows],
       cols
       |> Enum.zip(row |> String.split("", trim: true))
       |> Enum.map(fn {col, ch} -> "#{col}#{ch}" end)}
      | blocks
    ])
  end

  def row_to_number("", num), do: num
  def row_to_number("#" <> s, num), do: row_to_number(s, (num <<< 1) + 1)
  def row_to_number("." <> s, num), do: row_to_number(s, num <<< 1)

  def part1(data) do
    data
    |> Enum.reduce(0, fn {rows, cols}, sum ->
      c_sym = symetry(cols, [], 0)
      r_sym = if c_sym == 0 do
        symetry(rows |> Enum.reverse(), [], 0)
      else
        0
      end
      sum + (c_sym + 100 * r_sym)
    end)
  end

  def part2(data) do
    data
    |> Enum.reduce(0, fn {rows, cols}, sum ->
      c_sym = symetry_one_change(cols, [], 0)
      r_sym = if c_sym == 0 do
        symetry_one_change(rows |> Enum.reverse(), [], 0)
      else
        0
      end
      sum + (c_sym + 100 * r_sym)
    end)
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

  def count_bits(0, count), do: count
  def count_bits(num, cnt), do: count_bits(num >>> 1, cnt + (num &&& 1))

  def delta_is_one(a, b) when is_integer(a) and is_integer(b) do
    d = bxor(a,b)
    count_bits(d, 0) == 1
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
