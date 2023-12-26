defmodule Day21 do
  def run(mode) do
    data = read_input(mode)

    [{1, data}, {2, data}]
    |> Task.async_stream(
      fn
        {1, data} -> {1, data |> part1(mode)}
        {2, data} -> {2, data |> part2(mode)}
      end,
      timeout: :infinity
    )
    |> Enum.reduce({0, 0}, fn
      {_, {1, res}}, {_, p2} -> {res, p2}
      {_, {2, res}}, {p1, _} -> {p1, res}
    end)
  end

  def read_input(:test) do
    "...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
..........."
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-21")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data |> make_grid(0, {MapSet.new(), nil})
  end

  def make_grid([], y, {grid, start}), do: {grid, start, y}

  def make_grid([row | rest], y, grid_start),
    do: make_grid(rest, y + 1, parse_row(row, grid_start, y, 0))

  def parse_row("", grid_start, _, _), do: grid_start

  def parse_row("S" <> row, {grid, _}, y, x),
    do: parse_row(row, {grid |> MapSet.put({y, x}), {y, x}}, y, x + 1)

  def parse_row("." <> row, {grid, start}, y, x),
    do: parse_row(row, {grid |> MapSet.put({y, x}), start}, y, x + 1)

  def parse_row(<<_::utf8, row::binary>>, grid_start, y, x),
    do: parse_row(row, grid_start, y, x + 1)

  def part1({map, start, _}, mode) do
    step_limit =
      if mode == :test do
        6
      else
        64
      end

    walk([{start, step_limit}], map, Map.put(%{}, step_limit, MapSet.new([start])))
  end

  def walk([], _, visited), do: visited |> Map.get(0) |> MapSet.size()

  def walk([{{y, x}, steps_left} | rest], map, visited) do
    next_visited = visited |> Map.get(steps_left - 1, MapSet.new())

    next_steps =
      [
        {{y + 1, x}, steps_left - 1},
        {{y - 1, x}, steps_left - 1},
        {{y, x + 1}, steps_left - 1},
        {{y, x - 1}, steps_left - 1}
      ]
      |> Enum.filter(fn {pos, _} ->
        MapSet.member?(map, pos) and not MapSet.member?(next_visited, pos)
      end)

    next_visited =
      next_steps
      |> Enum.reduce(next_visited, fn {pos, _}, next_visited ->
        next_visited |> MapSet.put(pos)
      end)

    next_steps =
      if steps_left == 1 do
        []
      else
        next_steps
      end

    walk(next_steps ++ rest, map, visited |> Map.put(steps_left - 1, next_visited))
  end

  def is_reachable({y, x}, map) do
    [{0, 1}, {1, 0}, {-1, 0}, {0, -1}]
    |> Enum.any?(fn {dy, dx} -> MapSet.member?(map, {y + dy, x + dx}) end)
  end

  def part2({map, start, size}, mode) do
    odd_map =
      map
      |> Enum.filter(fn {y, x} -> rem(y + x, 2) == 1 and is_reachable({y, x}, map) end)
      |> Enum.into(MapSet.new())

    even_map =
      map
      |> Enum.filter(fn {y, x} -> rem(y + x, 2) == 0 and is_reachable({y, x}, map) end)
      |> Enum.into(MapSet.new())

    {full_len, full_map, left_start, left_len, left_map, left_offset, left_w, right_start,
     right_len, right_map, right_offset, right_w, top_start, top_len, top_map, top_offset, top_w,
     bottom_start, bottom_len, bottom_map, bottom_offset, bottom_w, tl_offset, tr_offset,
     bl_offset, br_offset} = find_the_cycles(map, start, size, odd_map, even_map)

    tl_corner =
      walk_corner(
        [{{size - 1, size - 1}, 2}],
        [],
        map,
        %{0 => MapSet.new(), 1 => MapSet.new(), 2 => MapSet.new([{size - 1, size - 1}])},
        even_map
      )

    tr_corner =
      walk_corner(
        [{{size - 1, 0}, 2}],
        [],
        map,
        %{0 => MapSet.new(), 1 => MapSet.new(), 2 => MapSet.new([{size - 1, 0}])},
        even_map
      )

    bl_corner =
      walk_corner(
        [{{0, size - 1}, 2}],
        [],
        map,
        %{0 => MapSet.new(), 1 => MapSet.new(), 2 => MapSet.new([{0, size - 1}])},
        even_map
      )

    br_corner =
      walk_corner(
        [{{0, 0}, 2}],
        [],
        map,
        %{0 => MapSet.new(), 1 => MapSet.new(), 2 => MapSet.new([{0, 0}])},
        even_map
      )

    odd_size = odd_map |> MapSet.size()
    even_size = even_map |> MapSet.size()

    to_visit =
      if mode == :test do
        10
      else
        26_501_365
      end

    zero_size = top_map |> Map.get(0) |> MapSet.size() |> IO.inspect(label: "zero")

    #    top_offset..(top_len + top_offset - 1)  |> Enum.map(fn i -> {i, (top_map |> Map.get(i) |> MapSet.size())} |> IO.inspect() end)
    #    0..left_len |> Enum.map(fn i -> {i, (left_map |> Map.get(i) |> MapSet.size())} |> IO.inspect() end)

    top_start |> IO.inspect(label: "top start")

    {left_w, right_w, top_w, bottom_w} |> IO.inspect(label: "weights")

    res =
      if to_visit <= full_len do
        full_map[to_visit] |> MapSet.size()
      else
        if rem(to_visit, 2) == 0 do
          [
            even_size,
            calc_column(
              to_visit - left_start,
              left_len,
              left_offset,
              left_map,
              if left_w == even_size do
                even_size
              else
                odd_size
              end,
              if left_w == even_size do
                odd_size
              else
                even_size
              end,
              0
            ),
            calc_column(
              to_visit - right_start,
              right_len,
              right_offset,
              right_map,
              if right_w == even_size do
                odd_size
              else
                even_size
              end,
              right_w,
              0
            ),
            calc_column(
              to_visit - top_start,
              top_len,
              top_offset,
              top_map,
              if top_w == even_size do
                odd_size
              else
                even_size
              end,
              top_w,
              0
            ),
            calc_column(
              to_visit - bottom_start,
              bottom_len,
              bottom_offset,
              bottom_map,
              if bottom_w == even_size do
                even_size
              else
                odd_size
              end,
              if bottom_w == even_size do
                odd_size
              else
                even_size
              end,
              0
            ),
            calc_corner(
              div(to_visit - tl_offset, size),
              to_visit - tl_offset,
              size,
              even_size,
              odd_size,
              tl_corner,
              0
            ),
            calc_corner(
              div(to_visit - tr_offset, size),
              to_visit - tr_offset,
              size,
              even_size,
              odd_size,
              tr_corner,
              0
            ),
            calc_corner(
              div(to_visit - bl_offset, size),
              to_visit - bl_offset,
              size,
              even_size,
              odd_size,
              bl_corner,
              0
            ),
            calc_corner(
              div(to_visit - br_offset, size),
              to_visit - br_offset,
              size,
              even_size,
              odd_size,
              br_corner,
              0
            )
          ]
          |> IO.inspect(char_lists: :as_lists)
          |> Enum.sum()
        else
          [
            odd_size,
            calc_column(
              to_visit - left_start,
              left_len,
              left_offset,
              left_map,
              if left_w == even_size do
                odd_size
              else
                even_size
              end,
              if left_w == even_size do
                even_size
              else
                odd_size
              end,
              0
            ),
            calc_column(
              to_visit - right_start,
              right_len,
              right_offset,
              right_map,
              if right_w == even_size do
                odd_size
              else
                even_size
              end,
              if right_w == even_size do
                even_size
              else
                odd_size
              end,
              0
            ),
            calc_column(
              to_visit - top_start,
              top_len,
              top_offset,
              top_map,
              if top_w == even_size do
                odd_size
              else
                even_size
              end,
              if top_w == even_size do
                even_size
              else
                odd_size
              end,
              0
            ),
            calc_column(
              to_visit - bottom_start,
              bottom_len,
              bottom_offset,
              bottom_map,
              if bottom_w == even_size do
                odd_size
              else
                even_size
              end,
              if bottom_w == even_size do
                even_size
              else
                odd_size
              end,
              0
            ),
            calc_corner(
              div(to_visit - tl_offset, size),
              to_visit - tl_offset,
              size,
              odd_size,
              even_size,
              tl_corner,
              0
            ),
            calc_corner(
              div(to_visit - tr_offset, size),
              to_visit - tr_offset,
              size,
              odd_size,
              even_size,
              tr_corner,
              0
            ),
            calc_corner(
              div(to_visit - bl_offset, size),
              to_visit - bl_offset,
              size,
              odd_size,
              even_size,
              bl_corner,
              0
            ),
            calc_corner(
              div(to_visit - br_offset, size),
              to_visit - br_offset,
              size,
              odd_size,
              even_size,
              br_corner,
              0
            )
          ]
          |> IO.inspect(char_lists: :as_lists)
          |> Enum.sum()
        end
        |> IO.inspect()
      end

    if false do
      {even, odd} =
        walk_2(
          [{start, to_visit}],
          [],
          map,
          MapSet.new([start]),
          MapSet.new(),
          size,
          to_visit,
          to_visit
        )

      if rem(to_visit, 2) == 0 do
        convert_to_groups(even, size) |> IO.inspect()

        even |> Enum.count() |> IO.inspect()
      else
        convert_to_groups(odd, size) |> IO.inspect()
        odd |> Enum.count() |> IO.inspect()
      end
    end

    res
  end

  def convert_to_groups(set, size) do
    res = %{
      middle: 0,
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      tl: 0,
      tr: 0,
      bl: 0,
      br: 0
    }

    res =
      set
      |> Enum.reduce(res, fn
        {y, x}, %{middle: m} = res when y >= 0 and y < size and x >= 0 and x < size ->
          %{res | middle: m + 1}

        {y, x}, %{left: l} = res when y >= 0 and y < size and x < 0 ->
          %{res | left: l + 1}

        {y, x}, %{right: r} = res when y >= 0 and y < size and x >= size ->
          %{res | right: r + 1}

        {y, x}, %{top: t} = res when y < 0 and x >= 0 and x < size ->
          %{res | top: t + 1}

        {y, x}, %{bottom: b} = res when y >= size and x >= 0 and x < size ->
          %{res | bottom: b + 1}

        {y, x}, %{tl: tl} = res when y < 0 and x < 0 ->
          %{res | tl: tl + 1}

        {y, x}, %{tr: tr} = res when y < 0 and x >= size ->
          %{res | tr: tr + 1}

        {y, x}, %{bl: bl} = res when y >= size and x < 0 ->
          %{res | bl: bl + 1}

        {y, x}, %{br: br} = res when y >= size and x >= size ->
          %{res | br: br + 1}
      end)
  end

  def calc_column(moves, len, offset, column, odds, evens, sum) do
    if moves < offset + len do
      (column[moves] |> MapSet.size()) + sum
    else
      calc_column(moves - len, len, offset, column, evens, odds, sum + evens)
    end
  end

  def calc_corner(0, moves, len, _even_count, _odd_count, corner, sum) do
    index = rem(moves, 2 * len)
    sum + (corner[index] |> MapSet.size())
  end

  def calc_corner(row, moves, len, even_count, odd_count, corner, sum) do
    evens = div(moves, 2 * len) * even_count
    odds = div(moves - len, 2 * len) * odd_count
    index = rem(moves, 2 * len)

    corner_size =
      if index < len + 2 do
        if index >= len do
          corner[index] |> MapSet.size()
        else
          (corner[index] |> MapSet.size()) + (corner[index + len] |> MapSet.size())
        end
      else
        (corner[index] |> MapSet.size()) + (corner[index - len] |> MapSet.size())
      end

    calc_corner(
      row - 1,
      moves - len,
      len,
      odd_count,
      even_count,
      corner,
      sum + corner_size + evens + odds
    )
  end

  def add_even_odd(0, even, odd, _, sum), do: sum
  def add_even_odd(n, even, odd, :even, sum), do: add_even_odd(n - 1, even, odd, :odd, sum + even)
  def add_even_odd(n, even, odd, :odd, sum), do: add_even_odd(n - 1, even, odd, :even, sum + even)

  def sum_top_odd(0, _, _, _, _, _, _, _, _), do: 0

  def sum_top_odd(count, moves, top_len, odd_size, even_size, tl_len, tl_map, tr_len, tr_map) do
    [
      odd_size,
      add_even_odd(div(moves - top_len, tl_len), even_size, odd_size, :even, 0),
      tl_map |> Map.get(rem(moves - top_len, tl_len)) |> MapSet.size(),
      add_even_odd(div(moves - top_len, tr_len), even_size, odd_size, :even, 0),
      tr_map |> Map.get(rem(moves - top_len, tr_len)) |> MapSet.size(),
      sum_top_even(
        count - 1,
        moves - top_len,
        top_len,
        odd_size,
        even_size,
        tl_len,
        tl_map,
        tr_len,
        tr_map
      )
    ]
    |> Enum.sum()
  end

  def sum_top_even(0, _, _, _, _, _, _, _, _), do: 0

  def sum_top_even(count, moves, top_len, odd_size, even_size, tl_len, tl_map, tr_len, tr_map) do
    [
      even_size,
      add_even_odd(div(moves - top_len, tl_len), even_size, odd_size, :odd, 0),
      tl_map |> Map.get(rem(moves - top_len, tl_len)) |> MapSet.size(),
      add_even_odd(div(moves - top_len, tr_len), even_size, odd_size, :odd, 0),
      tr_map |> Map.get(rem(moves - top_len, tr_len)) |> MapSet.size(),
      sum_top_odd(
        count - 1,
        moves - top_len,
        top_len,
        odd_size,
        even_size,
        tl_len,
        tl_map,
        tr_len,
        tr_map
      )
    ]
    |> Enum.sum()
  end

  def find_the_cycles(map, start, size, odd_map, even_map) do
    walk_until_full(
      [{start, 0}],
      [],
      map,
      Map.new() |> Map.put(0, MapSet.new([start])) |> Map.put(1, MapSet.new()),
      size,
      odd_map,
      even_map,
      nil,
      {0, 0, 0, 0, 0, 0, 0, 0}
    )
  end

  def translate(set, {dy, dx}) do
    set |> Enum.map(fn {y, x} -> {y + dy, x + dx} end) |> Enum.into(MapSet.new())
  end

  def explore_side([], tail, map, res_map, size, constraint, prev, added),
    do: explore_side(tail |> Enum.reverse(), [], map, res_map, size, constraint, prev, added)

  def explore_side(
        [{_, step} | _] = frontier,
        tail,
        map,
        res_map,
        size,
        constraint,
        prev,
        {added, last_seen_at, maybe_a_loop, cycle_start, cycle_size}
      )
      when prev != step do
    added_this_step =
      res_map
      |> Map.get(step)
      |> MapSet.difference(
        res_map
        |> Map.get(step - 2, MapSet.new())
      )
      |> Enum.map(fn {y, x} -> {rem(y, size), rem(x, size)} end)
      |> MapSet.new()

    # {step, added_this_step} |> IO.inspect()
    added = added |> Map.put(step, added_this_step)

    {maybe_a_loop, cycle_start, cycle_size, found} =
      if not maybe_a_loop do
        case Map.get(last_seen_at, added_this_step) do
          nil -> {false, cycle_start, cycle_size, false}
          prev_index -> {true, prev_index, step - prev_index, false} |> IO.inspect()
        end
      else
        added_at_prev = added |> Map.get(step - cycle_size)

        if added_at_prev == added_this_step do
          if step - 2 * cycle_size == cycle_start do
            {maybe_a_loop, cycle_start, cycle_size, true}
          else
            {maybe_a_loop, cycle_start, cycle_size, false}
          end
        else
          {false, cycle_start, cycle_size, false}
        end

        # |> IO.inspect()
      end

    if found do
      size_at_start = Map.get(res_map, cycle_start) |> MapSet.size()
      size_at_end = Map.get(res_map, cycle_start + cycle_size) |> MapSet.size()
      {cycle_size, res_map, cycle_start, size_at_end - size_at_start}
    else
      last_seen_at = last_seen_at |> Map.put(added_this_step, step)

      explore_side(
        frontier,
        tail,
        map,
        res_map,
        size,
        constraint,
        step,
        {added, last_seen_at, maybe_a_loop, cycle_start, cycle_size}
      )
    end
  end

  def explore_side([{{y, x}, step} | rest], tail, map, res_map, size, constraint, step, added) do
    next_visited = res_map |> Map.get(step + 1, Map.get(res_map, step - 1))

    next_steps =
      [
        {{y + 1, x}, step + 1},
        {{y - 1, x}, step + 1},
        {{y, x + 1}, step + 1},
        {{y, x - 1}, step + 1}
      ]
      |> Enum.filter(fn {{y, x} = pos, _} ->
        MapSet.member?(map, {rem(size + rem(y, size), size), rem(size + rem(x, size), size)}) and
          not MapSet.member?(next_visited, pos) and constraint.(pos)
      end)

    next_visited =
      next_steps
      |> Enum.reduce(next_visited, fn {pos, _}, next_visited ->
        next_visited |> MapSet.put(pos)
      end)

    res_map = Map.put(res_map, step + 1, next_visited)
    explore_side(rest, next_steps ++ tail, map, res_map, size, constraint, step, added)
  end

  def walk_corner([], [], _map, res_map, _tgt_map), do: res_map

  def walk_corner([], tail, map, res_map, tgt_map),
    do: walk_corner(tail |> Enum.reverse(), [], map, res_map, tgt_map)

  def walk_corner([{{y, x}, step} | rest], tail, map, res_map, tgt_map) do
    next_visited = res_map |> Map.get(step + 1, Map.get(res_map, step - 1))

    next_steps =
      [
        {{y + 1, x}, step + 1},
        {{y - 1, x}, step + 1},
        {{y, x + 1}, step + 1},
        {{y, x - 1}, step + 1}
      ]
      |> Enum.filter(fn {pos, _} ->
        MapSet.member?(map, pos) and not MapSet.member?(next_visited, pos)
      end)

    next_visited =
      next_steps
      |> Enum.reduce(next_visited, fn {pos, _}, next_visited ->
        next_visited |> MapSet.put(pos)
      end)

    res_map = Map.put(res_map, step + 1, next_visited)

    if next_visited == tgt_map do
      res_map
    else
      walk_corner(rest, next_steps ++ tail, map, res_map, tgt_map)
    end
  end

  def walk_until_full(
        [],
        [],
        map,
        visited,
        size,
        odd_map,
        even_map,
        final_step,
        {tl, tr, bl, br, top_start, left_start, bottom_start, right_start}
      ) do
    # here deal with the the fact that we've fill out the map once so now we need to split and find cycles for the other things

    IO.inspect("things are full will now walk the sides")

    [tl, tr, bl, br] =
      [tl, tr, bl, br]
      |> Enum.map(fn
        0 -> final_step
        value -> value
      end)

    final_step |> IO.inspect()

    {next, next_next} = {
      visited |> Map.get(top_start),
      visited |> Map.get(top_start - 1)
    }

    top_target =
      0..(size - 1)
      |> Enum.filter(fn n -> rem(n, 2) == 0 end)
      |> Enum.map(fn p -> {0, p} end)
      |> Enum.into(MapSet.new())
      |> translate({-1 * size, 0})

    top_constraint = fn {y, x} -> y < 0 and x >= 0 and x < size end
    top_constraint2 = fn {y, x} -> y <= 0 and x >= 0 and x < size end
    top_frontier = next |> Enum.filter(top_constraint)
    top_frontier_as_set = top_frontier |> Enum.into(MapSet.new())
    top_frontier = next |> Enum.filter(top_constraint2)

    top_frontier_as_set_after =
      next_next |> Enum.filter(top_constraint) |> Enum.into(MapSet.new())

    top_frontier = top_frontier |> Enum.map(fn p -> {p, 0} end)

    {next, next_next} = {
      visited |> Map.get(left_start),
      visited |> Map.get(left_start - 1)
    }

    left_target =
      0..(size - 1)
      |> Enum.filter(fn n -> rem(n, 2) == 0 end)
      |> Enum.map(fn p -> {p, 0} end)
      |> Enum.into(MapSet.new())
      |> translate({0, -1 * size})

    left_constraint = fn {y, x} -> x < 0 and y >= 0 and y < size end
    left_constraint2 = fn {y, x} -> x <= 0 and y >= 0 and y < size end
    left_frontier = next |> Enum.filter(left_constraint)
    left_frontier_as_set = left_frontier |> Enum.into(MapSet.new())
    left_frontier = next |> Enum.filter(left_constraint2)

    left_frontier_as_set_after =
      next_next |> Enum.filter(left_constraint) |> Enum.into(MapSet.new())

    left_frontier = left_frontier |> Enum.map(fn p -> {p, 0} end)

    {next, next_next} = {
      visited |> Map.get(right_start),
      visited |> Map.get(right_start - 1)
    }

    right_target =
      0..(size - 1)
      |> Enum.filter(fn n -> rem(n, 2) == 0 end)
      |> Enum.map(fn p -> {p, size - 1} end)
      |> Enum.into(MapSet.new())
      |> translate({0, 1 * size})

    right_constraint = fn {y, x} -> x >= size and y >= 0 and y < size end
    right_constraint2 = fn {y, x} -> x >= size - 1 and y >= 0 and y < size end
    right_frontier = next |> Enum.filter(right_constraint)
    right_frontier_as_set = right_frontier |> Enum.into(MapSet.new())
    right_frontier = next |> Enum.filter(right_constraint2)

    right_frontier_as_set_after =
      next_next |> Enum.filter(right_constraint) |> Enum.into(MapSet.new())

    right_frontier = right_frontier |> Enum.map(fn p -> {p, 0} end)

    {next, next_next} = {
      visited |> Map.get(bottom_start),
      visited |> Map.get(bottom_start - 1)
    }

    bottom_target =
      0..(size - 1)
      |> Enum.filter(fn n -> rem(n, 2) == 0 end)
      |> Enum.map(fn p -> {size - 1, p} end)
      |> Enum.into(MapSet.new())
      |> translate({1 * size, 0})

    bottom_constraint = fn {y, x} -> y >= size and x >= 0 and x < size end
    bottom_constraint2 = fn {y, x} -> y >= size - 1 and x >= 0 and x < size end
    bottom_frontier = next |> Enum.filter(bottom_constraint)
    bottom_frontier_as_set = bottom_frontier |> Enum.into(MapSet.new())
    bottom_frontier = next |> Enum.filter(bottom_constraint2)

    bottom_frontier_as_set_after =
      next_next |> Enum.filter(bottom_constraint) |> Enum.into(MapSet.new())

    bottom_frontier = bottom_frontier |> Enum.map(fn p -> {p, 0} end)

    {left_len, left_map, left_offset, left_w} =
      explore_side(
        left_frontier,
        [],
        map,
        Map.new() |> Map.put(0, left_frontier_as_set) |> Map.put(1, left_frontier_as_set_after),
        size,
        left_constraint,
        0,
        {%{}, %{}, false, 0, 0}
      )

    IO.inspect("got left")

    {right_len, right_map, right_offset, right_w} =
      explore_side(
        right_frontier,
        [],
        map,
        Map.new() |> Map.put(0, right_frontier_as_set) |> Map.put(1, right_frontier_as_set_after),
        size,
        right_constraint,
        0,
        {%{}, %{}, false, 0, 0}
      )

    IO.inspect("got right")

    {top_len, top_map, top_offset, top_w} =
      explore_side(
        top_frontier,
        [],
        map,
        Map.new() |> Map.put(0, top_frontier_as_set) |> Map.put(1, top_frontier_as_set_after),
        size,
        top_constraint,
        0,
        {%{}, %{}, false, 0, 0}
      )

    IO.inspect("got top")

    {bottom_len, bottom_map, bottom_offset, bottom_w} =
      explore_side(
        bottom_frontier,
        [],
        map,
        Map.new()
        |> Map.put(0, bottom_frontier_as_set)
        |> Map.put(1, bottom_frontier_as_set_after),
        size,
        bottom_constraint,
        0,
        {%{}, %{}, false, 0, 0}
      )

    IO.inspect("got bottom")

    {final_step, visited, left_start, left_len, left_map, left_offset, left_w, right_start,
     right_len, right_map, right_offset, right_w, top_start, top_len, top_map, top_offset, top_w,
     bottom_start, bottom_len, bottom_map, bottom_offset, bottom_w, tl, tr, bl, br}
  end

  def walk_until_full([], tail, map, visited, size, odd_map, even_map, final_step, corners),
    do:
      walk_until_full(
        tail |> Enum.reverse(),
        [],
        map,
        visited,
        size,
        odd_map,
        even_map,
        final_step,
        corners
      )

  def walk_until_full(
        [{_, step} | rest],
        tail,
        map,
        visited,
        size,
        odd_map,
        even_map,
        step,
        corners
      ),
      do: walk_until_full(rest, tail, map, visited, size, odd_map, even_map, step, corners)

  def walk_until_full(
        [{{y, x}, step} | rest],
        tail,
        map,
        visited,
        size,
        odd_map,
        even_map,
        final_step,
        {tl, tr, bl, br, top, left, bottom, right}
      ) do
    next_visited = Map.get(visited, step + 1, Map.get(visited, step - 1))

    next_steps =
      [
        {{y + 1, x}, step + 1},
        {{y - 1, x}, step + 1},
        {{y, x + 1}, step + 1},
        {{y, x - 1}, step + 1}
      ]
      |> Enum.filter(fn {{y, x} = pos, _} ->
        MapSet.member?(map, {rem(size + rem(y, size), size), rem(size + rem(x, size), size)}) and
          not MapSet.member?(next_visited, pos)
      end)

    next_visited =
      next_steps
      |> Enum.reduce(next_visited, fn {pos, _}, next_visited ->
        next_visited |> MapSet.put(pos)
      end)

    visited = Map.put(visited, step + 1, next_visited)

    tl = next_has(next_steps, tl, {0, 0})
    tr = next_has(next_steps, tr, {0, size - 1})
    bl = next_has(next_steps, bl, {size - 1, 0})
    br = next_has(next_steps, br, {size - 1, size - 1})

    top = next_has_all(next_visited, step + 1, top, :top, size)
    left = next_has_all(next_visited, step + 1, top, :left, size)
    bottom = next_has_all(next_visited, step + 1, top, :bottom, size)
    right = next_has_all(next_visited, step + 1, top, :right, size)

    cond do
      MapSet.subset?(even_map, next_visited) ->
        walk_until_full(
          rest,
          tail,
          map,
          visited,
          size,
          odd_map,
          even_map,
          step + 1,
          {tl, tr, bl, br, top, left, bottom, right}
        )

      true ->
        walk_until_full(
          rest,
          next_steps ++ tail,
          map,
          visited,
          size,
          odd_map,
          even_map,
          final_step,
          {tl, tr, bl, br, top, left, bottom, right}
        )
    end
  end

  def next_has_all(list, step, 0, kind, size) do
    set =
      case kind do
        :top ->
          0..(size - 1)
          |> Enum.filter(fn n -> rem(n, 2) == 0 end)
          |> Enum.map(fn p -> {0, p} end)
          |> Enum.into(MapSet.new())

        :left ->
          0..(size - 1)
          |> Enum.filter(fn n -> rem(n, 2) == 0 end)
          |> Enum.map(fn p -> {p, 0} end)
          |> Enum.into(MapSet.new())

        :bottom ->
          0..(size - 1)
          |> Enum.filter(fn n -> rem(n, 2) == 0 end)
          |> Enum.map(fn p -> {size - 1, p} end)
          |> Enum.into(MapSet.new())

        :right ->
          0..(size - 1)
          |> Enum.filter(fn n -> rem(n, 2) == 0 end)
          |> Enum.map(fn p -> {p, size - 1} end)
          |> Enum.into(MapSet.new())
      end

    if MapSet.subset?(set, list) do
      step
    else
      0
    end
  end

  def next_has_all(_, _, step, _, _), do: step

  def next_has(list, 0, pos) do
    case list
         |> Enum.find(fn
           {^pos, _} -> true
           _ -> false
         end) do
      nil -> 0
      {_, step} -> step
    end
  end

  def next_has(_, val, _), do: val

  def walk_2([], [], _, visited_even, visited_odd, _, _, _), do: {visited_even, visited_odd}

  def walk_2([], tail, map, visited_even, visited_odd, size, sl, lp),
    do: walk_2(tail |> Enum.reverse(), [], map, visited_even, visited_odd, size, sl, lp)

  def walk_2([{{y, x}, steps_left} | rest], tail, map, visited_even, visited_odd, size, sl, lp) do
    lp =
      if lp != steps_left do
        # "Step: #{sl - lp + 1}" |> IO.inspect()
        # print_map(if rem(sl - lp + 1, 2) == 0 do visited_even else visited_odd end, map, size, sl - lp + 1) 
        steps_left
      else
        lp
      end

    next_visited =
      if rem(sl - steps_left - 1, 2) == 0 do
        visited_even
      else
        visited_odd
      end

    next_steps =
      [
        {{y + 1, x}, steps_left - 1},
        {{y - 1, x}, steps_left - 1},
        {{y, x + 1}, steps_left - 1},
        {{y, x - 1}, steps_left - 1}
      ]
      |> Enum.filter(fn {{y, x} = pos, _} ->
        MapSet.member?(map, {rem(size + rem(y, size), size), rem(size + rem(x, size), size)}) and
          not MapSet.member?(next_visited, pos)
      end)

    next_visited =
      next_steps
      |> Enum.reduce(next_visited, fn {pos, _}, next_visited ->
        next_visited |> MapSet.put(pos)
      end)

    next_steps =
      if steps_left == 1 do
        []
      else
        next_steps
      end

    {visited_even, visited_odd} =
      if rem(sl - steps_left - 1, 2) == 0 do
        {next_visited, visited_odd}
      else
        {visited_even, next_visited}
      end

    walk_2(rest, next_steps ++ tail, map, visited_even, visited_odd, size, sl, lp)
  end

  def print_map(visited, map, size, step_limit) do
    odd_map = map |> Enum.filter(fn {y, x} -> rem(y + x, 2) == 1 end) |> Enum.into(MapSet.new())
    even_map = map |> Enum.filter(fn {y, x} -> rem(y + x, 2) == 0 end) |> Enum.into(MapSet.new())
    {low, high} = {div(size - 1, 2) - step_limit, div(size - 1, 2) + step_limit}
    sub_grids = %{}

    sub_grids =
      low..high
      |> Enum.reduce(sub_grids, fn y, sub_grids ->
        low..high
        |> Enum.reduce(sub_grids, fn x, sub_grids ->
          subgrid_key =
            {if y < 0 do
               div(y - size, size)
             else
               div(y, size)
             end,
             if x < 0 do
               div(x - size, size)
             else
               div(x, size)
             end}

          subgrid = sub_grids |> Map.get(subgrid_key, MapSet.new())

          subgrid =
            if MapSet.member?(visited, {y, x}) do
              subgrid
              |> MapSet.put({rem(size + rem(y, size), size), rem(size + rem(x, size), size)})
            else
              subgrid
            end

          sub_grids |> Map.put(subgrid_key, subgrid)
        end)
      end)

    Map.keys(sub_grids) |> IO.inspect()
    empty_set = MapSet.new()

    {odd, even, partial, empty} =
      sub_grids
      |> Map.values()
      |> Enum.reduce({0, 0, 0, 0}, fn subgrid, {odd, even, partial, empty} ->
        case subgrid do
          ^odd_map -> {odd + 1, even, partial, empty}
          ^even_map -> {odd, even + 1, partial, empty}
          ^empty_set -> {odd, even, partial, empty + 1}
          _ -> {odd, even, partial + 1, empty}
        end
      end)
      |> IO.inspect()

    (odd + even + partial + empty) |> IO.inspect()

    if true do
      low..high
      |> Enum.map(fn y ->
        low..high
        |> Enum.map(fn x ->
          if MapSet.member?(visited, {y, x}) do
            "O"
          else
            if MapSet.member?(
                 map,
                 {rem(size + rem(y, size), size), rem(size + rem(x, size), size)}
               ) do
              "."
            else
              "#"
            end
          end
        end)
        |> Enum.join("")
      end)
      |> Enum.join("\n")
      |> IO.puts()
    end
  end
end
