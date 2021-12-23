defmodule PriorityQueue do
  def new() do
    {nil, %{}}
  end

  def add({min_prio, values}, prio, value) do
    {if min_prio < prio do
       min_prio
     else
       prio
     end, values |> Map.put(prio, [value | values |> Map.get(prio, [])])}
  end

  def pop_next({nil, _} = pq), do: {nil, pq}

  def pop_next({min_prio, values}) do
    [value | rest_values] = values |> Map.get(min_prio)

    if Enum.empty?(rest_values) do
      {value, {values |> Map.keys() |> min_key(min_prio), values |> Map.delete(min_prio)}}
    else
      {value, {min_prio, values |> Map.put(min_prio, rest_values)}}
    end
  end

  defp min_key(keys, old_min) do
    find_smaller(keys, old_min, nil)
  end

  defp find_smaller([], _, ret), do: ret
  defp find_smaller([old | rest], old, min), do: find_smaller(rest, old, min)
  defp find_smaller([min | rest], old, nil), do: find_smaller(rest, old, min)
  defp find_smaller([min | rest], old, larger) when min < larger, do: find_smaller(rest, old, min)
  defp find_smaller([_ | rest], old, min), do: find_smaller(rest, old, min)
end
