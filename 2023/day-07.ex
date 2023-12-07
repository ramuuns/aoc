defmodule Day7 do
  def run(mode) do
    data1 = read_input(mode, 1)
    data2 = read_input(mode, 2)

    [{1, data1}, {2, data2}]
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

  @card_type_order %{
    five_of_a_kind: 1,
    four_of_a_kind: 2,
    full_house: 3,
    three_of_a_kind: 4,
    two_pairs: 5,
    one_pair: 6,
    high_card: 7
  }

  @card_order %{
    ?2 => 1,
    ?3 => 2,
    ?4 => 3,
    ?5 => 4,
    ?6 => 5,
    ?7 => 6,
    ?8 => 7,
    ?9 => 8,
    ?T => 9,
    ?J => 10,
    ?Q => 11,
    ?K => 12,
    ?A => 13
  }

  @card_order_p2 %{
    ?J => 1,
    ?2 => 2,
    ?3 => 3,
    ?4 => 4,
    ?5 => 5,
    ?6 => 6,
    ?7 => 7,
    ?8 => 8,
    ?9 => 9,
    ?T => 10,
    ?Q => 11,
    ?K => 12,
    ?A => 13
  }

  def read_input(:test, part) do
    "32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"
    |> String.split("\n")
    |> prepare_data(part)
  end

  def read_input(:actual, part) do
    File.stream!("input-07")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data(part)
  end

  def prepare_data(data, 1) do
    data
    |> Enum.map(fn s ->
      [cards, bid] = String.split(s, " ", trim: true)
      bid = String.to_integer(bid)
      type = cards |> get_type(1)
      {type, cards, bid}
    end)
  end

  def prepare_data(data, 2) do
    data
    |> Enum.map(fn s ->
      [cards, bid] = String.split(s, " ", trim: true)
      bid = String.to_integer(bid)
      type = cards |> get_type(2)
      {type, cards, bid}
    end)
  end

  def get_type(cards, 1) do
    cards_by_card =
      cards
      |> String.split("", trim: true)
      |> Enum.reduce(Map.new(), fn c, map -> map |> Map.put(c, Map.get(map, c, 0) + 1) end)

    keys = Map.keys(cards_by_card)

    case keys |> Enum.count() do
      1 ->
        :five_of_a_kind

      4 ->
        :one_pair

      5 ->
        :high_card

      2 ->
        cnt = cards_by_card |> Map.get(keys |> Enum.at(0))

        if cnt == 1 or cnt == 4 do
          :four_of_a_kind
        else
          :full_house
        end

      3 ->
        if cards_by_card |> Map.values() |> Enum.find(fn c -> c == 3 end) do
          :three_of_a_kind
        else
          :two_pairs
        end
    end
  end

  def get_type(cards, 2) do
    cards_by_card =
      cards
      |> String.split("", trim: true)
      |> Enum.reduce(Map.new(), fn c, map -> map |> Map.put(c, Map.get(map, c, 0) + 1) end)

    has_jokers = cards_by_card |> Map.has_key?("J")

    if has_jokers do
      joker_count = Map.get(cards_by_card, "J")

      if joker_count == 5 or joker_count == 4 do
        :five_of_a_kind
      else
        cards_no_jokers = cards_by_card |> Map.delete("J")
        keys = Map.keys(cards_no_jokers)
        key_count = keys |> Enum.count()

        cond do
          key_count == 1 ->
            :five_of_a_kind

          joker_count == 3 ->
            :four_of_a_kind

          joker_count == 2 and key_count == 2 ->
            :four_of_a_kind

          joker_count == 2 ->
            :three_of_a_kind

          joker_count == 1 and key_count == 2 ->
            if cards_no_jokers |> Map.get(keys |> Enum.at(0)) == 2 do
              :full_house
            else
              :four_of_a_kind
            end

          joker_count == 1 and key_count == 3 ->
            :three_of_a_kind

          true ->
            :one_pair
        end
      end
    else
      get_type(cards, 1)
    end
  end

  def part1(data) do
    {_, sum} =
      data
      |> Enum.sort(&card_sort/2)
      |> Enum.reduce({1, 0}, fn {_, _, bid}, {rank, sum} -> {rank + 1, rank * bid + sum} end)

    sum
  end

  def part2(data) do
    {_, sum} =
      data
      |> Enum.sort(&card_sort_2/2)
      |> Enum.reduce({1, 0}, fn {_, _, bid}, {rank, sum} -> {rank + 1, rank * bid + sum} end)

    sum
  end

  def card_sort({type_a, cards_a, _}, {type_b, cards_b, _}) do
    st_a = Map.get(@card_type_order, type_a)
    st_b = Map.get(@card_type_order, type_b)

    if st_a == st_b do
      card_compare(cards_a, cards_b)
    else
      st_a > st_b
    end
  end

  def card_compare(<<a::utf8, rest_a::binary>>, <<a::utf8, rest_b::binary>>),
    do: card_compare(rest_a, rest_b)

  def card_compare(<<a::utf8, _::binary>>, <<b::utf8, rest::binary>>),
    do: Map.get(@card_order, a) < Map.get(@card_order, b)

  def card_sort_2({type_a, cards_a, _}, {type_b, cards_b, _}) do
    st_a = Map.get(@card_type_order, type_a)
    st_b = Map.get(@card_type_order, type_b)

    if st_a == st_b do
      card_compare_2(cards_a, cards_b)
    else
      st_a > st_b
    end
  end

  def card_compare_2(<<a::utf8, rest_a::binary>>, <<a::utf8, rest_b::binary>>),
    do: card_compare_2(rest_a, rest_b)

  def card_compare_2(<<a::utf8, _::binary>>, <<b::utf8, rest::binary>>),
    do: Map.get(@card_order_p2, a) < Map.get(@card_order_p2, b)
end
