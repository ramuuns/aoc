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

  def to_structured([a, b]) when is_integer(a) and is_integer(b), do: {0, false, [a, b]}

  def to_structured([a, b]) when is_integer(a) and is_list(b) do
    b = b |> to_structured
    {elem(b, 0) + 1, false, [a, b]}
  end

  def to_structured([a, b]) when is_integer(b) and is_list(a) do
    a = a |> to_structured
    {elem(a, 0) + 1, false, [a, b]}
  end

  def to_structured([a, b]) do
    a = a |> to_structured
    b = b |> to_structured
    {Enum.max([elem(a, 0), elem(b, 0)]) + 1, false, [a, b]}
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

  def add({d1, _, a}, {d2, _, b}),
    do: {Enum.max([d1, d2]) + 1, false, [{d1, false, a}, {d2, false, b}]} |> maybe_reduce

  def maybe_reduce({d, _, _} = n) when d < 4, do: n |> maybe_split

  def maybe_reduce(n) do
    n |> explode |> maybe_reduce
  end

  def explode({_, s, [{da, sa, a}, {db, sb, b}]}) when da >= db do
    {{da, sa, a}, _, right} = explode_inner({da, sa, a})
    {db, sb, b} = add_left({db, sb, b}, right)
    {Enum.max([da, db]) + 1, s or sa or sb, [{da, sa, a}, {db, sb, b}]}
  end

  def explode({_, s, [{da, sa, a}, {db, sb, b}]}) do
    {{db, sb, b}, left, _} = explode_inner({db, sb, b})
    {da, sa, a} = add_right({da, sa, a}, left)
    {Enum.max([da, db]) + 1, s or sa or sb, [{da, sa, a}, {db, sb, b}]}
  end

  def explode_inner({0, _, [left, right]}), do: {nil, left, right}

  def explode_inner({_, _, [{ld, sl, l}, {rd, sr, r}]}) when ld >= rd do
    {newl, left, right} = explode_inner({ld, sl, l})

    case newl do
      nil ->
        {rd, sr, r} = add_left({rd, sr, r}, right)
        {{rd + 1, sr, [0, {rd, sr, r}]}, left, 0}

      {ld, sl, l} ->
        {rd, sr, r} = add_left({rd, sr, r}, right)
        {{Enum.max([ld, rd]) + 1, sr or sl, [{ld, sl, l}, {rd, sr, r}]}, left, 0}
    end
  end

  def explode_inner({_, _, [{ld, sl, l}, {rd, sr, r}]}) when ld < rd do
    {newr, left, right} = explode_inner({rd, sr, r})

    case newr do
      nil ->
        {ld, sl, l} = add_right({ld, sl, l}, left)
        {{ld + 1, sl, [{ld, sl, l}, 0], 0, right}}

      {rd, sr, r} ->
        {ld, sl, l} = add_right({ld, sl, l}, left)
        {{Enum.max([ld, rd]) + 1, sl or sr, [{ld, sl, l}, {rd, sr, r}]}, 0, right}
    end
  end

  def explode_inner({_, _, [{ld, sl, l}, r]}) do
    {newl, left, right} = explode_inner({ld, sl, l})

    case newl do
      nil ->
        {{0, right + r > 9, [0, right + r]}, left, 0}

      {ld, sl, l} ->
        {{ld + 1, sl or right + r > 9, [{ld, sl, l}, right + r]}, left, 0}
    end
  end

  def explode_inner({_, _, [l, {rd, sr, r}]}) do
    {newr, left, right} = explode_inner({rd, sr, r})

    case newr do
      nil ->
        {{0, left + l > 9, [left + l, 0]}, 0, right}

      {rd, sr, r} ->
        {{rd + 1, sr or left + l > 9, [left + l, {rd, sr, r}]}, 0, right}
    end
  end

  def add_left(l, 0), do: l
  def add_left({d, s, [l, r]}, n) when is_integer(l), do: {d, s or l + n > 9, [l + n, r]}

  def add_left({d, s, [l, r]}, n) do
    {_, sl, _} = l = add_left(l, n)
    {d, s or sl, [l, r]}
  end

  def add_right(r, 0), do: r
  def add_right({d, s, [l, r]}, n) when is_integer(r), do: {d, s or r + n > 9, [l, r + n]}

  def add_right({d, s, [l, r]}, n) do
    {_, sr, _} = r = add_right(r, n)
    {d, s or sr, [l, r]}
  end

  def maybe_split({_, false, _} = num), do: num

  def maybe_split(num), do: try_split(num) |> maybe_reduce

  def depth({d, _, [_, _]}), do: d
  def depth(_), do: 0

  def needs_split({_, s, _}), do: s
  def needs_split(n), do: n > 9

  def try_split({_, false, _} = n), do: n

  def try_split({_, true, [a, b]}) when is_integer(a) and a > 9,
    do:
      {Enum.max([0, depth(b)]) + 1, needs_split(b) or ceil(a / 2) > 9,
       [{0, ceil(a / 2) > 9, [div(a, 2), ceil(a / 2)]}, b]}

  def try_split({_, true, [{_, true, _} = a, b]}) do
    a = try_split(a)
    {Enum.max([depth(a), depth(b)]) + 1, needs_split(a) or needs_split(b), [a, b]}
  end

  def try_split({_, true, [a, {_, true, _} = b]}) do
    b = try_split(b)
    {Enum.max([depth(a), depth(b)]) + 1, needs_split(a) or needs_split(b), [a, b]}
  end

  def try_split({_, true, [a, b]}) when is_integer(b) and b > 9,
    do:
      {Enum.max([0, depth(b)]) + 1, needs_split(a) or ceil(b / 2) > 9,
       [a, {0, ceil(b / 2) > 9, [div(b, 2), ceil(b / 2)]}]}

  def magnitude({_, _, [a, b]}) when is_integer(a) and is_integer(b), do: a * 3 + b * 2
  def magnitude({_, _, [a, b]}) when is_integer(a), do: a * 3 + magnitude(b) * 2
  def magnitude({_, _, [a, b]}) when is_integer(b), do: magnitude(a) * 3 + b * 2
  def magnitude({_, _, [a, b]}), do: magnitude(a) * 3 + magnitude(b) * 2

  def find_max_sum([], _, sum), do: sum

  def find_max_sum([a | rest], all, sum),
    do: find_max_sum(rest, all, find_max_for_this(all, a, sum))

  def find_max_for_this([], _, sum), do: sum
  def find_max_for_this([a | rest], a, sum), do: find_max_for_this(rest, a, sum)

  def find_max_for_this([a | rest], b, sum),
    do: find_max_for_this(rest, b, Enum.max([sum, a |> add(b) |> magnitude]))
end
