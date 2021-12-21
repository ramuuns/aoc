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

  def part2(players) do
    players
    # |> Enum.map(fn 
    #  {1, _, _} -> {1, 0, 0}
    #  {2, _, _} -> {2, 1, 0}
    # end)
    |> Enum.map(fn {i, p, _} -> {p, 0, 0, 1} end)
    |> play_dirac_game(1)
    |> then(fn {a, b} -> Enum.max([a, b]) end)
  end

  @dice_rolls2 [
    {2, 1},
    {3, 2},
    {4, 1}
  ]

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

  def universe_count(state),
    do: state |> Enum.reduce(0, fn {_, m}, acc -> (m |> Map.values() |> Enum.sum()) + acc end)

  def play_dirac_game([{_, _, wins, _}, {_, p1_score, p1_wins, count}] = state, l)
      when p1_score >= @cutoff,
      do: {wins, p1_wins + count}

  def play_dirac_game(
        [{p1_pos, p1_score, p1_wins, count}, {p2_pos, p2_score, p2_wins, p2_cnt}],
        l
      ) do
    @dice_rolls3
    |> Enum.map(fn {dice, cnt1} ->
      play_dirac_game(
        [
          {
            p2_pos,
            p2_score,
            p2_wins,
            p2_cnt * cnt1
          },
          {
            rem(p1_pos + dice, @board_size),
            p1_score + rem(p1_pos + dice, @board_size) + 1,
            p1_wins,
            count * cnt1
          }
        ],
        l + 1
      )
    end)
    |> Enum.reduce({0, 0}, fn {p2s, p1s}, {p1, p2} -> {p1 + p1s, p2 + p2s} end)
  end

  ####  NOT THE ACTUAL APPROACH but something I spent lots of time on and want to be commited so that I can think about it maybe
  def play_dirac_game([{i, score, wins}, p2] = state, universes, total_universes) do
    {state, score |> universe_count(), universes, total_universes} |> IO.inspect(label: "dirac")

    newscore =
      score
      |> Enum.to_list()
      |> calc_newscore(%{}, div(total_universes, score |> universe_count()))
      |> IO.inspect()

    winning_scores = newscore |> Map.keys() |> Enum.filter(fn s -> s >= @cutoff end)

    {wins_this_turn, newscore} =
      winning_scores
      |> Enum.reduce({0, newscore}, fn
        ws, {wins, newscore} ->
          {wins + (newscore[ws] |> Map.values() |> Enum.sum()), newscore |> Map.delete(ws)}
      end)

    if Enum.empty?(newscore) do
      wins
    else
      universes = newscore |> universe_count()
      play_dirac_game([p2, {i, newscore, wins + wins_this_turn}], universes, total_universes * 4)
    end
  end

  def calc_newscore([], ret, _), do: ret

  def calc_newscore([{s, positions} | rest], ret, universes),
    do:
      calc_newscore(rest, add_to_score(s, positions |> Enum.to_list(), ret, universes), universes)

  def add_to_score(_, [], ret, _), do: ret

  def add_to_score(s, [{pos, n} | rest], ret, universes) do
    ret =
      apply_roll(%{}, {pos, n}, @dice_rolls2, universes)
      |> IO.inspect(label: "roll #{s}")
      |> Enum.to_list()
      |> Enum.map(fn {pos, n} -> {s + pos + 1, pos, n} end)
      |> Enum.reduce(ret, fn
        {news, pos, n}, ret ->
          posmap = ret[news] || %{}
          ret |> Map.put(news, Map.put(posmap, pos, (posmap[pos] || 0) + n))
      end)

    add_to_score(s, rest, ret, universes)
  end

  def apply_roll(ret, _, [], _), do: ret

  def apply_roll(ret, {pos, n}, [{move, universes} | rest], u),
    do:
      apply_roll(
        ret
        |> Map.put(
          rem(pos + move, @board_size),
          n * universes * u
        ),
        {pos, n},
        rest,
        u
      )

  ### END OF THE not the approach approach
end
