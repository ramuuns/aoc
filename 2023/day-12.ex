defmodule Day12 do
  def run(mode) do
    data = read_input(mode, 1)
    data2 = read_input(mode, 2)

    [{1, data}, {2, data2}]
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

  def read_input(:test, part) do
    "???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1"
    |> String.split("\n")
    |> prepare_data(part)
  end

  def read_input(:actual, part) do
    File.stream!("input-12")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data(part)
  end

  def prepare_data(data, 1) do
    data |> Enum.map(&make_data_row/1)
  end

  def prepare_data(data, 2) do
    data |> Enum.map(&make_data_row_p2/1)
  end

  def make_data_row(row) do
    [springs, nums] =
      row
      |> String.split(" ", trim: true)

    {springs |> to_groups,
     nums |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1)}
  end

  def make_data_row_p2(row) do
    [springs, nums] =
      row
      |> String.split(" ", trim: true)

    {
      [springs, springs, springs, springs, springs] |> Enum.join("?") |> to_groups,
      [nums, nums, nums, nums, nums]
      |> Enum.join(",")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
    }
  end

  def to_groups(string) do
    string |> String.split(~r"\.+", trim: true)
  end

  def part1(data) do
    data |> Enum.map(&valid_count/1) |> Enum.sum()
  end

  def part2(data) do
    data |> Enum.map(&valid_count/1) |> Enum.sum()
  end

  def valid_count({groups, sizes}) do
    # {groups, sizes} |> IO.inspect()
    # |> IO.inspect()
    {ret, _} = count_try_placing(groups, sizes, Map.new())
    ret
  end

  def count_try_placing(groups, [], res_map) do
    res =
      if groups |> Enum.join("") |> String.contains?("#") do
        0
      else
        1
      end

    {res, res_map |> Map.put({groups, []}, res)}
  end

  def count_try_placing([], [_ | _] = sizes, res_map), do: {0, res_map |> Map.put({[], sizes}, 0)}

  def count_try_placing([group], [size], res_map) do
    group_length = String.length(group)

    ret =
      cond do
        size == group_length ->
          {1, res_map |> Map.put({[group], [size]}, 1)}

        size > group_length ->
          {0, res_map |> Map.put({[group], [size]}, 0)}

        String.starts_with?(group, "#") ->
          rest_group = group |> String.slice(size, 1000)

          if rest_group |> String.contains?("#") do
            {0, res_map |> Map.put({[group], [size]}, 0)}
          else
            {1, res_map |> Map.put({[group], [size]}, 1)}
          end

        true ->
          rest_group = group |> String.slice(size, 1000)

          cnt =
            if rest_group |> String.contains?("#") do
              0
            else
              1
            end

          if Map.has_key?(res_map, {[group |> String.slice(1, 1000)], [size]}) do
            {Map.get(res_map, [group |> String.slice(1, 1000)], [size]), res_map}
          else
            {rec_count, res_map} =
              count_try_placing([group |> String.slice(1, 1000)], [size], res_map)

            {rec_count + cnt, res_map |> Map.put({[group], [size]}, rec_count + cnt)}
          end
      end

    #  {group, size, ret} |> IO.inspect()
    ret
  end

  def count_try_placing([group | groups] = all_groups, [size | sizes] = all_sizes, res_map) do
    group_length = String.length(group)

    {ret, res_map} =
      if size < group_length do
        rest_group = group |> String.slice(size, 1000)

        {cnt, res_map} =
          if rest_group |> String.starts_with?("#") do
            # bad bad bad, guess we cannot place it at the start
            {0, res_map}
          else
            # alright, let's try placing the next size at whatever is left of this group
            if Map.has_key?(res_map, {[rest_group |> String.slice(1, 1000) | groups], sizes}) do
              {Map.get(res_map, {[rest_group |> String.slice(1, 1000) | groups], sizes}), res_map}
            else
              count_try_placing([rest_group |> String.slice(1, 1000) | groups], sizes, res_map)
            end
          end

        # cnt |> IO.inspect()

        if group |> String.slice(0, size) |> String.starts_with?("#") do
          {cnt, res_map}
        else
          # the above either worked or it did not, but we can now try shrinking the group and trying this same thing again
          if Map.has_key?(res_map, {[group |> String.slice(1, 1000) | groups], all_sizes}) do
            {Map.get(res_map, {[group |> String.slice(1, 1000) | groups], all_sizes}) + cnt,
             res_map}
          else
            {c1, res_map} =
              count_try_placing([group |> String.slice(1, 1000) | groups], all_sizes, res_map)

            {c1 + cnt, res_map}
          end
        end
      else
        if size == group_length do
          # hell yeah, this size is just the entirety of this group, moving on
          {cnt, res_map} =
            if Map.has_key?(res_map, {groups, sizes}) do
              {Map.get(res_map, {groups, sizes}), res_map}
            else
              count_try_placing(groups, sizes, res_map)
            end

          if group |> String.contains?("#") do
            {cnt, res_map}
          else
            if Map.has_key?(res_map, {groups, all_sizes}) do
              {cnt + Map.get(res_map, {groups, all_sizes}), res_map}
            else
              {c1, res_map} = count_try_placing(groups, all_sizes, res_map)
              {c1 + cnt, res_map}
            end
          end
        else
          if group |> String.contains?("#") do
            {0, res_map}
          else
            # try placing the size in the next group
            if Map.has_key?(res_map, {groups, all_sizes}) do
              {Map.get(res_map, {groups, all_sizes}), res_map}
            else
              count_try_placing(groups, all_sizes, res_map)
            end
          end
        end
      end

    #   {all_groups, all_sizes, ret} |> IO.inspect()
    {ret, res_map |> Map.put({all_groups, all_sizes}, ret)}
  end
end
