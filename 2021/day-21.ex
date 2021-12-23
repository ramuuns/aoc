defmodule Day21 do
  def run(mode) do
    data = read_input(mode)

    [{1, data}, {2, data}]
    |> Task.async_stream(fn
      {1, data} -> {1, data |> part1}
      {2, data} -> {2, data |> part2}
    end)
    |> Enum.reduce({0, 0}, fn
      {_, {1, res}}, {_, p2} -> {res, p2}
      {_, {2, res}}, {p1, _} -> {p1, res}
    end)
  end

  def read_input(:test) do
    "Player 1 starting position: 4
Player 2 starting position: 8"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-21")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(["Player 1 starting position: " <> p1, "Player 2 starting position: " <> p2]) do
    [{1, (p1 |> String.to_integer()) - 1, 0}, {2, (p2 |> String.to_integer()) - 1, 0}]
  end

  def part1(players) do
    play_game(players, 0)
  end

  def play_game([{i, pos, score}, p2], dice_rolls) do
    newpos =
      rem(
        pos + rem(dice_rolls, 1000) + 3 + rem(dice_rolls + 1, 1000) + rem(dice_rolls + 2, 1000),
        10
      )

    score = score + newpos + 1

    if score >= 1000 do
      {_, _, lscore} = p2
      (dice_rolls + 3) * lscore
    else
      play_game([p2, {i, newpos, score}], dice_rolls + 3)
    end
  end

  def part2([{_, p1, _}, {_, p2, _}]) do
    {[{:p1, p1, 0, 1, p2, 0, 1}], 0, 0}
    #    { [{:p1, 0, 0, 1, 1, 0, 1}], 0, 0 }
    |> play_dirac_game()
    |> then(fn {a, b} -> Enum.max([a, b]) end)
  end

  @dice_rolls3 [
    {3, 1},
    {4, 3},
    {5, 6},
    {6, 7},
    {7, 6},
    {8, 3},
    {9, 1}
  ]

  @cutoff 21
  @board_size 10

  def play_dirac_game({[], p1_wins, p2_wins}), do: {p1_wins, p2_wins}

  def play_dirac_game({states, p1_wins, p2_wins}) do
    @dice_rolls3
    |> add_to_states(@dice_rolls3, states, [], p1_wins, p2_wins)
    |> play_dirac_game()
  end

  def group_states(states) do
    states
    |> Enum.frequencies()
    |> Enum.reduce([], fn
      {{next, p1_pos, p1_score, p1_cnt, p2_pos, p2_score, p2_cnt}, cnt}, acc ->
        [{next, p1_pos, p1_score, p1_cnt * cnt, p2_pos, p2_score, p2_cnt * cnt} | acc]
    end)
  end

  def add_to_states(_, _, [], states, p1_wins, p2_wins),
    do: {states |> group_states, p1_wins, p2_wins}

  def add_to_states([], rest, [_ | states], newstates, p1_wins, p2_wins),
    do: add_to_states(rest, rest, states, newstates, p1_wins, p2_wins)

  def add_to_states(
        [{dice, cnt} | rest],
        odice,
        [{:p1, p1_pos, p1_score, p1_cnt, _, _, _} | _] = states,
        newstates,
        p1_wins,
        p2_wins
      )
      when p1_score + rem(p1_pos + dice, @board_size) + 1 >= @cutoff,
      do: add_to_states(rest, odice, states, newstates, p1_wins + cnt * p1_cnt, p2_wins)

  def add_to_states(
        [{dice, cnt} | rest],
        odice,
        [{:p2, _, _, _, p2_pos, p2_score, p2_cnt} | _] = states,
        newstates,
        p1_wins,
        p2_wins
      )
      when p2_score + rem(p2_pos + dice, @board_size) + 1 >= @cutoff,
      do: add_to_states(rest, odice, states, newstates, p1_wins, cnt * p2_cnt + p2_wins)

  def add_to_states(
        [{dice, cnt} | rest],
        odice,
        [{:p1, p1_pos, p1_score, p1_cnt, p2_pos, p2_score, p2_cnt} | _] = states,
        newstates,
        p1_wins,
        p2_wins
      ),
      do:
        add_to_states(
          rest,
          odice,
          states,
          [
            {:p2, rem(p1_pos + dice, @board_size), p1_score + rem(p1_pos + dice, @board_size) + 1,
             cnt * p1_cnt, p2_pos, p2_score, cnt * p2_cnt}
            | newstates
          ],
          p1_wins,
          p2_wins
        )

  def add_to_states(
        [{dice, cnt} | rest],
        odice,
        [{:p2, p1_pos, p1_score, p1_cnt, p2_pos, p2_score, p2_cnt} | _] = states,
        newstates,
        p1_wins,
        p2_wins
      ),
      do:
        add_to_states(
          rest,
          odice,
          states,
          [
            {:p1, p1_pos, p1_score, cnt * p1_cnt, rem(p2_pos + dice, @board_size),
             p2_score + rem(p2_pos + dice, @board_size) + 1, cnt * p2_cnt}
            | newstates
          ],
          p1_wins,
          p2_wins
        )
end
