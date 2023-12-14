defmodule Day12 do
  Code.compile_file("priority_queue.ex")
  import Bitwise

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
    string
    |> String.split(~r"\.+", trim: true)
    |> Enum.map(fn group ->
      group |> String.split("", trim: true) |> Enum.reverse() |> to_group_inner(0, 0)
    end)
  end

  def to_group_inner([], group, size), do: {group, size}

  def to_group_inner(["#" | rest], group, size),
    do: to_group_inner(rest, (group <<< 1) + 1, size + 1)

  def to_group_inner(["?" | rest], group, size), do: to_group_inner(rest, group <<< 1, size + 1)

  def part1(data) do
    data
    |> Task.async_stream(&valid_count/1)
    |> Enum.map(fn {:ok, res} -> res end)
    # |> Enum.map(&valid_count/1)
    |> Enum.sum()
  end

  def part2(data) do
    data
    |> Task.async_stream(&valid_count/1)
    |> Enum.map(fn {:ok, res} -> res end)
    |> Enum.sum()

    # 1
  end

  def valid_count({groups, sizes}) do
    # {groups, sizes} |> IO.inspect()
    # |> IO.inspect()
    # count_try_placing(
    #  groups,
    #  sizes,
    #  groups |> Enum.reduce(Enum.count(groups) - 1, fn {_, size}, acc -> acc + size end),
    #  (sizes |> Enum.sum()) + Enum.count(sizes) - 1
    # )
    group_size_sum =
      groups |> Enum.reduce(Enum.count(groups) - 1, fn {_, size}, acc -> acc + size end)

    size_sum = (sizes |> Enum.sum()) + Enum.count(sizes) - 1

    cnt =
      count_try_iter(
        PriorityQueue.new()
        |> PriorityQueue.add(-size_sum, {groups, sizes, group_size_sum, size_sum}),
        Map.new([
          {
            group_size_sum * 1000 + size_sum,
            1
          }
        ]),
        0
      )

    # |>IO.inspect(label: "res")
    cnt
  end

  def count_try_iter({nil, _}, _, count), do: count

  def count_try_iter(
        pq,
        seen,
        count
      ) do
    {item, pq} = PriorityQueue.pop_next(pq)

    case item do
      {groups, [], gc, sc} ->
        res =
          if groups |> Enum.any?(fn {group, _} -> group > 0 end) do
            0
          else
            Map.get(seen, gc * 1000 + sc)
          end

        count_try_iter(pq, seen, count + res)

      {[{group, group_size} | groups] = all_groups, [size | sizes] = all_sizes, group_size_sum,
       rem_size_sum} ->
        # item |> IO.inspect(label: "start")

        next =
          cond do
            size < group_size ->
              rest_group = group >>> size
              rest_group_size = group_size - size

              next =
                case rest_group &&& 1 do
                  1 ->
                    []

                  0 ->
                    {next_group, next_group_size} =
                      if rest_group_size == 1 do
                        {groups, group_size_sum - group_size - 1}
                      else
                        {[{rest_group >>> 1, rest_group_size - 1} | groups],
                         group_size_sum - size - 1}
                      end

                    [
                      {
                        next_group,
                        sizes,
                        next_group_size,
                        rem_size_sum - size - 1
                      }
                    ]
                end

              case group &&& 1 do
                1 ->
                  next

                0 ->
                  {next_group, next_group_size} =
                    if group_size == 1 do
                      {groups, group_size_sum - group_size - 1}
                    else
                      {[{group >>> 1, group_size - 1} | groups], group_size_sum - 1}
                    end

                  [
                    {
                      next_group,
                      all_sizes,
                      next_group_size,
                      rem_size_sum
                    }
                    | next
                  ]
              end

            size == group_size ->
              # hell yeah, this size is just the entirety of this group, moving on
              next = [
                {groups, sizes, group_size_sum - group_size - 1, rem_size_sum - size - 1}
              ]

              if group > 0 do
                next
              else
                [
                  {groups, all_sizes, group_size_sum - group_size - 1, rem_size_sum}
                  | next
                ]
              end

            group > 0 ->
              []

            true ->
              [{groups, all_sizes, group_size_sum - group_size - 1, rem_size_sum}]
          end

        filtered_next =
          next
          |> Enum.filter(fn {_, _, group_size, rem_size} ->
            group_size >= rem_size and not Map.has_key?(seen, group_size * 1000 + rem_size)
          end)

        seen =
          next
          |> Enum.reduce(seen, fn {_, _, group_size, rem_size}, seen ->
            k = group_size * 1000 + rem_size

            seen
            |> Map.put(
              k,
              Map.get(seen, k, 0) + Map.get(seen, group_size_sum * 1000 + rem_size_sum)
            )
          end)

        # next |> IO.inspect(label: "adding")
        pq =
          filtered_next
          |> Enum.reduce(pq, fn {_, _, gsize, size} = item, pq ->
            pq |> PriorityQueue.add(-size - gsize, item)
          end)

        count_try_iter(pq, seen, count)
    end
  end

  def count_try_placing(groups, [], _, _) do
    res =
      if groups |> Enum.any?(fn {group, _} -> group > 0 end) do
        0
      else
        1
      end

    Process.put({groups, []}, res)
    res
  end

  def count_try_placing([], [_ | _] = sizes, _, _) do
    Process.put({[], sizes}, 0)
    0
  end

  def count_try_placing(
        [{group, group_size} | groups] = all_groups,
        [size | sizes] = all_sizes,
        group_size_sum,
        rem_size_sum
      ) do
    ret =
      cond do
        rem_size_sum > group_size_sum ->
          0

        size < group_size ->
          rest_group = group >>> size
          rest_group_size = group_size - size

          cnt =
            case rest_group &&& 1 do
              1 ->
                0

              0 ->
                map_key =
                  {next_groups, next_sizes} = {
                    if rest_group_size == 1 do
                      groups
                    else
                      [{rest_group >>> 1, rest_group_size - 1} | groups]
                    end,
                    sizes
                  }

                # alright, let's try placing the next size at whatever is left of this group
                if cnt = Process.get(map_key) do
                  cnt
                else
                  count_try_placing(
                    next_groups,
                    next_sizes,
                    if rest_group_size == 1 do
                      group_size_sum - group_size - 1
                    else
                      group_size_sum - size - 1
                    end,
                    rem_size_sum - size - 1
                  )
                end
            end

          case group &&& 1 do
            1 ->
              cnt

            0 ->
              # the above either worked or it did not, but we can now try shrinking the group and trying this same thing again
              map_key =
                {next_groups, next_sizes} = {
                  if group_size == 1 do
                    groups
                  else
                    [{group >>> 1, group_size - 1} | groups]
                  end,
                  all_sizes
                }

              if c1 = Process.get(map_key) do
                c1 + cnt
              else
                count_try_placing(
                  next_groups,
                  next_sizes,
                  if group_size == 1 do
                    group_size_sum - group_size - 1
                  else
                    group_size_sum - 1
                  end,
                  rem_size_sum
                ) + cnt
              end
          end

        size == group_size ->
          # hell yeah, this size is just the entirety of this group, moving on
          cnt =
            if c1 = Process.get({groups, sizes}) do
              c1
            else
              count_try_placing(
                groups,
                sizes,
                group_size_sum - group_size - 1,
                rem_size_sum - size - 1
              )
            end

          if group > 0 do
            cnt
          else
            if c1 = Process.get({groups, all_sizes}) do
              c1 + cnt
            else
              count_try_placing(groups, all_sizes, group_size_sum - group_size - 1, rem_size_sum) +
                cnt
            end
          end

        group > 0 ->
          0

        true ->
          # try placing the size in the next group
          if c1 = Process.get({groups, all_sizes}) do
            c1
          else
            count_try_placing(groups, all_sizes, group_size_sum - group_size - 1, rem_size_sum)
          end
      end

    Process.put({all_groups, all_sizes}, ret)
    # IO.inspect({all_groups, all_sizes, group_size_sum, rem_size_sum, ret}) 
    ret
  end
end
