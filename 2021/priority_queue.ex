defmodule PriorityQueue do
  def new() do
    {[], %{}}
  end

  def add({priorities, values}, prio, value) do
    {maybe_add_prio(priorities, prio, []),
     values |> Map.put(prio, [value | values |> Map.get(prio, [])])}
  end

  defp maybe_add_prio([], n, acc), do: [n | acc] |> Enum.reverse()
  defp maybe_add_prio([n | rest], n, acc), do: ([n | acc] |> Enum.reverse()) ++ rest
  defp maybe_add_prio([a | rest], n, acc) when n < a, do: ([a, n | acc] |> Enum.reverse()) ++ rest
  defp maybe_add_prio([a | rest], n, acc), do: maybe_add_prio(rest, n, [a | acc])

  def pop_next({[], _} = pq), do: {nil, pq}

  def pop_next({[prio | rest_prios] = all_prio, values}) do
    [value | rest_values] = values |> Map.get(prio)

    if Enum.empty?(rest_values) do
      {value, {rest_prios, values |> Map.delete(prio)}}
    else
      {value, {all_prio, values |> Map.put(prio, rest_values)}}
    end
  end
end
