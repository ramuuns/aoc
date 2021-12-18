defmodule Day18 do
  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-18")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data
    |> Enum.map(fn
      line ->
        {row, _} = Code.eval_string(line)
        row |> to_structured
    end)
  end

  def to_structured([a, b]) when is_integer(a) and is_integer(b), do: {0, [a, b]}

  def to_structured([a, b]) when is_integer(a) and is_list(b) do
    b = b |> to_structured
    {elem(b, 0) + 1, [a, b]}
  end

  def to_structured([a, b]) when is_integer(b) and is_list(a) do
    a = a |> to_structured
    {elem(a, 0) + 1, [a, b]}
  end

  def to_structured([a, b]) do
    a = a |> to_structured
    b = b |> to_structured
    {Enum.max([elem(a, 0), elem(b, 0)]) + 1, [a, b]}
  end

  def part1([first | data]) do
    data
    |> Enum.reduce(first, fn
      row, acc -> acc |> add(row)
    end)
    |> magnitude
  end

  def part2(data) do
    find_max_sum(data, data, 0)
  end

  def add({d1, a}, {d2, b}), do: {Enum.max([d1, d2]) + 1, [{d1, a}, {d2, b}]} |> maybe_reduce

  def maybe_reduce({d, _} = n) when d < 4, do: n |> maybe_split

  def maybe_reduce(n) do
    n |> explode |> maybe_reduce
  end

  def explode({_, [{da, a}, {db, b}]}) when da >= db do
    {{da, a}, _, right} = explode_inner({da, a})
    {db, b} = add_left({db, b}, right)
    {Enum.max([da, db]) + 1, [{da, a}, {db, b}]}
  end

  def explode({_, [{da, a}, {db, b}]}) do
    {{db, b}, left, _} = explode_inner({db, b})
    {da, a} = add_right({da, a}, left)
    {Enum.max([da, db]) + 1, [{da, a}, {db, b}]}
  end

  def explode_inner({0, [left, right]}), do: {nil, left, right}

  def explode_inner({_, [{ld, l}, {rd, r}]}) when ld >= rd do
    {newl, left, right} = explode_inner({ld, l})

    case newl do
      nil ->
        {rd, r} = add_left({rd, r}, right)
        {{rd + 1, [0, {rd, r}]}, left, 0}

      {ld, l} ->
        {{Enum.max([ld, rd]) + 1, [{ld, l}, add_left({rd, r}, right)]}, left, 0}
    end
  end

  def explode_inner({_, [{ld, l}, {rd, r}]}) when ld < rd do
    {newr, left, right} = explode_inner({rd, r})

    case newr do
      nil ->
        {ld, l} = add_right({ld, l}, left)
        {{ld + 1, [{ld, l}, 0], 0, right}}

      {rd, r} ->
        {{Enum.max([ld, rd]) + 1, [add_right({ld, l}, left), {rd, r}]}, 0, right}
    end
  end

  def explode_inner({_, [{ld, l}, r]}) do
    {newl, left, right} = explode_inner({ld, l})

    case newl do
      nil ->
        {{0, [0, right + r]}, left, 0}

      {ld, l} ->
        {{ld + 1, [{ld, l}, right + r]}, left, 0}
    end
  end

  def explode_inner({_, [l, {rd, r}]}) do
    {newr, left, right} = explode_inner({rd, r})

    case newr do
      nil ->
        {{0, [left + l, 0]}, 0, right}

      {rd, r} ->
        {{rd + 1, [left + l, {rd, r}]}, 0, right}
    end
  end

  def add_left(l, 0), do: l
  def add_left({d, [l, r]}, n) when is_integer(l), do: {d, [l + n, r]}
  def add_left({d, [l, r]}, n), do: {d, [add_left(l, n), r]}

  def add_right(r, 0), do: r
  def add_right({d, [l, r]}, n) when is_integer(r), do: {d, [l, r + n]}
  def add_right({d, [l, r]}, n), do: {d, [l, add_right(r, n)]}

  def maybe_split(num) do
    {did_split, num} = try_split(num)

    if did_split do
      num |> maybe_reduce
    else
      num
    end
  end

  def depth({d, [_, _]}), do: d
  def depth(_), do: 0

  def try_split({_, [a, b]}) when is_integer(a) and a > 9,
    do: {true, {Enum.max([0, depth(b)]) + 1, [{0, [div(a, 2), ceil(a / 2)]}, b]}}

  def try_split({_, [a, b]}) when is_tuple(a) and is_tuple(b) do
    {did_split?, a} = try_split(a)

    if did_split? do
      {true, {Enum.max([depth(a), depth(b)]) + 1, [a, b]}}
    else
      {did_split?, b} = try_split(b)
      {did_split?, {Enum.max([depth(a), depth(b)]) + 1, [a, b]}}
    end
  end

  def try_split({_, [a, b]}) when is_tuple(a) and is_integer(b) and b < 10 do
    {did_split?, a} = try_split(a)
    {did_split?, {Enum.max([depth(a), depth(b)]) + 1, [a, b]}}
  end

  def try_split({_, [a, b]}) when is_tuple(a) and is_integer(b) and b > 9 do
    {did_split?, a} = try_split(a)

    if did_split? do
      {did_split?, {Enum.max([depth(a), depth(b)]) + 1, [a, b]}}
    else
      {true, {Enum.max([depth(a), 0]) + 1, [a, {0, [div(b, 2), ceil(b / 2)]}]}}
    end
  end

  def try_split({_, [a, b]}) when is_tuple(b) do
    {did_split?, b} = try_split(b)
    {did_split?, {Enum.max([depth(a), depth(b)]) + 1, [a, b]}}
  end

  def try_split({_, [a, b]}) when is_integer(b) and b > 9,
    do: {true, {Enum.max([0, depth(a)]) + 1, [a, {0, [div(b, 2), ceil(b / 2)]}]}}

  def try_split(n), do: {false, n}

  def magnitude({_, [a, b]}) when is_integer(a) and is_integer(b), do: a * 3 + b * 2
  def magnitude({_, [a, b]}) when is_integer(a), do: a * 3 + magnitude(b) * 2
  def magnitude({_, [a, b]}) when is_integer(b), do: magnitude(a) * 3 + b * 2
  def magnitude({_, [a, b]}), do: magnitude(a) * 3 + magnitude(b) * 2

  def find_max_sum([], _, sum), do: sum

  def find_max_sum([a | rest], all, sum),
    do: find_max_sum(rest, all, find_max_for_this(all, a, sum))

  def find_max_for_this([], _, sum), do: sum
  def find_max_for_this([a | rest], a, sum), do: find_max_for_this(rest, a, sum)

  def find_max_for_this([a | rest], b, sum),
    do: find_max_for_this(rest, b, Enum.max([sum, a |> add(b) |> magnitude]))
end
