defmodule Day22 do
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
    "1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-22")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data |> Enum.map(&make_brick/1) |> Enum.sort()
  end

  def make_brick(string) do
    [start_str, end_str] = String.split(string, "~", trim: true)
    [x, y, z] = start_str |> String.split(",") |> Enum.map(&String.to_integer/1)
    [x2, y2, z2] = end_str |> String.split(",") |> Enum.map(&String.to_integer/1)
    {z, y, x, {z2 - z, y2 - y, x2 - x}}
  end

  def part1(data) do
    {grid, fallen_bricks, _} = data |> make_them_fall(%{}, MapSet.new(), 0, false)
    count_removable(fallen_bricks |> MapSet.to_list(), fallen_bricks, grid) |> MapSet.size()
  end

  def place_brick({z, y, x, {dz, dy, dx}} = brick, grid) do
    y_coords = 0..dy |> Enum.map(fn yy -> {z, y + yy, x} end) |> MapSet.new()
    x_coords = 0..dx |> Enum.map(fn xx -> {z, y, x + xx} end) |> MapSet.new()
    z_coords = 0..dz |> Enum.map(fn zz -> {z + zz, y, x} end) |> MapSet.new()
    coords = y_coords |> MapSet.union(x_coords) |> MapSet.union(z_coords)
    coords |> Enum.reduce(grid, fn coord, grid -> grid |> Map.put(coord, brick) end)
  end

  def make_them_fall([], grid, bricks, cnt, _), do: {grid, bricks, cnt}

  def make_them_fall([{1, _, _, _} = brick | rest], grid, bricks, cnt, _) do
    grid = place_brick(brick, grid)
    make_them_fall(rest, grid, bricks |> MapSet.put(brick), cnt, false)
  end

  def make_them_fall([{z, x, y, {dz, dy, dx}} = brick | rest], grid, bricks, cnt, is_falling) do
    items = check_below(brick, grid)

    if MapSet.size(items) == 0 do
      make_them_fall(
        [{z - 1, x, y, {dz, dy, dx}} | rest],
        grid,
        bricks,
        if is_falling do
          cnt
        else
          cnt + 1
        end,
        true
      )
    else
      make_them_fall(rest, place_brick(brick, grid), bricks |> MapSet.put(brick), cnt, false)
    end
  end

  def check_below({z, y, x, {_, dy, dx}}, grid) do
    y_coords = 0..dy |> Enum.map(fn yy -> {z - 1, y + yy, x} end) |> MapSet.new()
    x_coords = 0..dx |> Enum.map(fn xx -> {z - 1, y, x + xx} end) |> MapSet.new()
    to_check = y_coords |> MapSet.union(x_coords) |> MapSet.to_list()
    get_unique_bricks(to_check, grid, MapSet.new())
  end

  def check_above({z, y, x, {dz, dy, dx}}, grid) do
    y_coords = 0..dy |> Enum.map(fn yy -> {z + dz + 1, y + yy, x} end) |> MapSet.new()
    x_coords = 0..dx |> Enum.map(fn xx -> {z + dz + 1, y, x + xx} end) |> MapSet.new()
    to_check = y_coords |> MapSet.union(x_coords) |> MapSet.to_list()
    get_unique_bricks(to_check, grid, MapSet.new())
  end

  def count_removable([], can_be_removed, _), do: can_be_removed

  def count_removable([brick | rest], can_be_removed, grid) do
    items_below = check_below(brick, grid)

    can_be_removed =
      if MapSet.size(items_below) == 1 do
        [item] = items_below |> MapSet.to_list()
        can_be_removed |> MapSet.delete(item)
      else
        can_be_removed
      end

    count_removable(rest, can_be_removed, grid)
  end

  def get_unique_bricks([], _, ret), do: ret

  def get_unique_bricks([coord | rest], map, ret) when is_map_key(map, coord),
    do: get_unique_bricks(rest, map, ret |> MapSet.put(Map.get(map, coord)))

  def get_unique_bricks([_ | rest], map, ret), do: get_unique_bricks(rest, map, ret)

  def part2(data) do
    {grid, fallen_bricks, _} = data |> make_them_fall(%{}, MapSet.new(), 0, false)
    can_be_removed = count_removable(fallen_bricks |> MapSet.to_list(), fallen_bricks, grid)
    bricks_that_support_other_bricks = fallen_bricks |> MapSet.difference(can_be_removed)
    sum_fall_count(bricks_that_support_other_bricks |> MapSet.to_list(), fallen_bricks, 0)
  end

  def sum_fall_count([], _, sum), do: sum

  def sum_fall_count([brick | rest], bricks, sum),
    do: sum_fall_count(rest, bricks, sum + fall_count(brick, bricks))

  def fall_count(brick, bricks) do
    bricks_minus_this_one = bricks |> MapSet.delete(brick)

    {_, _, fall_count} =
      bricks_minus_this_one |> Enum.sort() |> make_them_fall(%{}, MapSet.new(), 0, false)

    fall_count
  end
end
