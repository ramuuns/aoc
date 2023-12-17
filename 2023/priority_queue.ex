defmodule PriorityQueue do
  def new() do
    {nil, %{}}
  end

  def add({nil, values}, prio, value) do
    {[prio], values |> Map.put(prio, [value])}
  end

  def add({[min_prio | _] = prios, values}, prio, value) when prio < min_prio do
    {[prio | prios], values |> Map.put(prio, [value])}
  end

  def add({prios, values}, prio, value) when is_map_key(values, prio) do
    {prios, values |> Map.put(prio, [value | values |> Map.get(prio, [])])}
  end

  def add({[min_prio | prios], values}, prio, value) do
    {[min_prio | insert_sort(prios, prio)], values |> Map.put(prio, [value])}
  end

  def insert_sort([], prio), do: [prio]

  def insert_sort([h | rest], prio) when prio < h do
    [prio, h | rest]
  end

  def insert_sort([h | rest], prio) do
    [h | insert_sort(rest, prio)]
  end

  def pop_next({nil, _} = pq), do: {nil, pq}

  def pop_next({[min_prio | rest_prios] = prios, values}) do
    [value | rest_values] = values |> Map.get(min_prio)

    case rest_values do
      [] ->
        case rest_prios do
          [] -> 
            {value, {nil, %{}}}
          _ ->
            {value, {rest_prios, values |> Map.delete(min_prio)}}
          end

      _ ->
        {value, {prios, values |> Map.put(min_prio, rest_values)}}
    end
  end
end
