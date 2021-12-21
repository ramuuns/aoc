defmodule Day21 do
  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
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
    [{:p1, p1, 0, 1, p2, 0, 1}]
    |> play_dirac_game(0, 0)
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

  def play_dirac_game([], p1_wins, p2_wins), do: {p1_wins, p2_wins}

  def play_dirac_game([{:p1, _, _, _, _, p2_score, p2_cnt} | states], p1_wins, p2_wins)
      when p2_score >= @cutoff,
      do: play_dirac_game(states, p1_wins, p2_wins + p2_cnt)

  def play_dirac_game([{:p2, _, p1_score, p1_cnt, _, _, _} | states], p1_wins, p2_wins)
      when p1_score >= @cutoff,
      do: play_dirac_game(states, p1_wins + p1_cnt, p2_wins)

  def play_dirac_game([state | states], p1_wins, p2_wins) do
    @dice_rolls3
    |> add_to_states(state, states)
    |> play_dirac_game(p1_wins, p2_wins)
  end

  def add_to_states([], _, states), do: states

  def add_to_states(
        [{dice, count} | rest],
        {:p1, p1_pos, p1_score, p1_cnt, p2_pos, p2_score, p2_cnt} = st,
        states
      ),
      do:
        add_to_states(rest, st, [
          {:p2, rem(p1_pos + dice, @board_size), p1_score + rem(p1_pos + dice, @board_size) + 1,
           count * p1_cnt, p2_pos, p2_score, count * p2_cnt}
          | states
        ])

  def add_to_states(
        [{dice, count} | rest],
        {:p2, p1_pos, p1_score, p1_cnt, p2_pos, p2_score, p2_cnt} = st,
        states
      ),
      do:
        add_to_states(rest, st, [
          {:p1, p1_pos, p1_score, count * p1_cnt, rem(p2_pos + dice, @board_size),
           p2_score + rem(p2_pos + dice, @board_size) + 1, count * p2_cnt}
          | states
        ])

end
