defmodule Day19 do
  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-14"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-19")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data([_ | data]), do: prepare_data(data, [], [])

  def prepare_data([], scanners, scanner), do: [scanner | scanners]
  def prepare_data(["" | rest], scanners, scanner), do: prepare_data(rest, scanners, scanner)

  def prepare_data(["---" <> _ | rest], scanners, scanner),
    do: prepare_data(rest, [scanner | scanners], [])

  def prepare_data([xyz | rest], scanners, scanner),
    do:
      prepare_data(rest, scanners, [
        xyz |> String.split(",") |> Enum.map(&String.to_integer/1) | scanner
      ])

  def part1(data) do
    coords_by_scanner =
      data
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.map(fn {a, b} -> {b, a} end)
      |> Enum.into(%{})

    normalized_scanners =
      data
      |> Enum.reverse()
      |> Enum.with_index()
      |> Task.async_stream(fn {scanner, n} -> {n, scanner |> normalize_all} end)
      |> Enum.map(fn {_, d} -> d end)

    normalized_scanners
    |> find_unique_coords()
    |> try_convert_to_same_coords({0, %{}}, coords_by_scanner)
    |> then(fn map -> map[0] end)
    #   |> print_found_coords() 
    |> MapSet.size()
  end

  def print_found_coords(map) do
    map
    |> Enum.to_list()
    |> Enum.sort_by(&Enum.at(&1, 0))
    |> Enum.map(fn c -> c |> IO.inspect() end)

    map
  end

  def part2(data) do
    coords_by_scanner =
      data
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.map(fn {_, b} -> {b, [[0, 0, 0]]} end)
      |> Enum.into(%{})

    normalized_scanners =
      data
      |> Enum.reverse()
      |> Enum.with_index()
      |> Task.async_stream(fn {scanner, n} -> {n, scanner |> normalize_all} end)
      |> Enum.map(fn {_, d} -> d end)

    scanner_coords =
      normalized_scanners
      |> find_unique_coords()
      |> try_convert_to_same_coords({0, %{}}, coords_by_scanner)
      |> then(fn map -> map[0] end)
      #    |> print_found_coords()
      |> Enum.to_list()

    scanner_coords |> find_max_distance(scanner_coords, 0)
  end

  def find_max_distance(_, [], max), do: max
  def find_max_distance([], [_ | rest], max), do: find_max_distance(rest, rest, max)
  def find_max_distance([a | rest], [a | _] = vs, max), do: find_max_distance(rest, vs, max)

  def find_max_distance([a | rest], [b | _] = vs, max),
    do: find_max_distance(rest, vs, Enum.max([max, distance(a, b)]))

  def distance(a, b), do: Enum.zip(a, b) |> Enum.map(fn {a, b} -> abs(a - b) end) |> Enum.sum()

  def normalize_all(scanner), do: normalize_all(scanner, scanner, %{})
  def normalize_all([], _, norm), do: norm

  def normalize_all([a | rest], scanners, norm),
    do: normalize_all(rest, scanners, norm |> Map.put(a, scanners |> normalize_vs(a, [])))

  def normalize_vs([], _, ret), do: ret

  def normalize_vs([[x, y, z] | rest], [a, b, c], ret),
    do:
      normalize_vs(rest, [a, b, c], [
        [x - a, y - b, z - c, abs(x - a) + abs(y - b) + abs(z - c)] | ret
      ])

  def find_unique_coords(scanners), do: find_unique_coords(scanners, scanners, %{})
  def find_unique_coords([], _, ret), do: ret

  def find_unique_coords([s | rest], scanners, ret),
    do: find_unique_coords(rest, scanners, find_overlaps(scanners, s, ret))

  def find_overlaps([], _, ret), do: ret
  def find_overlaps([{s, _} | rest], {s, _} = scanner, ret), do: find_overlaps(rest, scanner, ret)

  def find_overlaps([{a, _} | rest], {b, _} = scanner, ret)
      when is_map_key(ret, {a, b}) or is_map_key(ret, {b, a}),
      do: find_overlaps(rest, scanner, ret)

  def find_overlaps([{a, norm_a} | rest], {s, norm_s} = scanner, ret) do
    stuff_for_the_map = norm_a |> Enum.to_list() |> try_find_overlaps(norm_s |> Enum.to_list())
    find_overlaps(rest, scanner, ret |> Map.put({s, a}, stuff_for_the_map))
  end

  def try_find_overlaps([], _), do: {false, nil, nil, nil}

  def try_find_overlaps([a | norms], tgt) do
    case try_find_overlap(tgt, a) do
      {true, _, _, _} = ret -> ret
      _ -> try_find_overlaps(norms, tgt)
    end
  end

  def try_find_overlap([], _), do: {false, nil, nil, nil}

  def try_find_overlap([{c, a} | rest], {bc, b}) do
    {does_match?, matches} = matches_12?(a, b)

    if does_match? do
      {true, {c, a}, {bc, b}, matches}
    else
      try_find_overlap(rest, {bc, b})
    end
  end

  def matches_12?(a, b) do
    mag_a = a |> Enum.map(fn [_, _, _, m] -> m end) |> Enum.into(MapSet.new())
    mag_b = b |> Enum.map(fn [_, _, _, m] -> m end) |> Enum.into(MapSet.new())
    intersection = mag_a |> MapSet.intersection(mag_b)
    int_size = intersection |> MapSet.size()
    ret = int_size >= 12

    if ret do
      int_items = {
        a |> Enum.filter(fn [_, _, _, m] -> intersection |> MapSet.member?(m) end),
        b |> Enum.filter(fn [_, _, _, m] -> intersection |> MapSet.member?(m) end)
      }

      {true, int_items}
    else
      {false, nil}
    end
  end

  def try_convert_to_same_coords(_, {tgt, seen}, _) when is_map_key(seen, tgt), do: seen

  def try_convert_to_same_coords(c, {tgt, seen}, coords_by_scanner) do
    seen = seen |> Map.put(tgt, MapSet.new(coords_by_scanner[tgt]))

    neighbors =
      c
      |> Enum.filter(fn
        {{^tgt, next}, {true, _, _, _}} when not is_map_key(seen, next) -> true
        {{next, ^tgt}, {true, _, _, _}} when not is_map_key(seen, next) -> true
        _ -> false
      end)

    neighbors
    |> Enum.reduce(seen, fn
      {{^tgt, next}, {_, {tgt_c, _}, {next_c, _}, {t1, t2}}}, seen ->
        {t_src, t_dest} = find_trans({t2, t1})
        seen = try_convert_to_same_coords(c, {next, seen}, coords_by_scanner)

        seen
        |> Map.put(
          tgt,
          seen[next]
          |> Enum.reduce(seen[tgt], fn
            coord, seen ->
              seen
              |> MapSet.put(
                coord
                |> translate(next_c)
                |> rotate([t_src], [t_dest])
                |> translate(tgt_c, :add)
              )
          end)
        )

      {{next, ^tgt}, {_, {next_c, _}, {tgt_c, _}, {t1, t2}}}, seen ->
        {t_src, t_dest} = find_trans({t1, t2})
        seen = try_convert_to_same_coords(c, {next, seen}, coords_by_scanner)

        seen
        |> Map.put(
          tgt,
          seen[next]
          |> Enum.reduce(seen[tgt], fn
            coord, seen ->
              seen
              |> MapSet.put(
                coord
                |> translate(next_c)
                |> rotate([t_src], [t_dest])
                |> translate(tgt_c, :add)
              )
          end)
        )
    end)
  end

  def find_trans({a, b}) do
    sorted_a = a |> Enum.sort_by(&Enum.at(&1, 3), :desc)
    sorted_b = b |> Enum.sort_by(&Enum.at(&1, 3), :desc)
    {sorted_a, sorted_b}
    gimme_trans(sorted_a, sorted_b)
  end

  def gimme_trans([[a, _, _, m] | ta], [[d, e, f, m] | tb])
      when abs(a) != abs(d) and abs(a) != abs(e) and abs(a) != abs(f),
      do: gimme_trans(ta, tb)

  def gimme_trans([[a, b, c, m] | _], [[d, e, f, m] | _])
      when abs(a) != abs(b) and abs(b) != abs(c),
      do: {[a, b, c], [d, e, f]}

  def gimme_trans([[_, _, _, m] = a | ta], [_, [_, _, _, m] = b | tb]),
    do: gimme_trans([a | ta], [b | tb])

  def gimme_trans([_, [_, _, _, m] = a | ta], [[_, _, _, m] = b | tb]),
    do: gimme_trans([a | ta], [b | tb])

  def gimme_trans([_ | ta], [_ | tb]), do: gimme_trans(ta, tb)

  def rotate(s, t1, t2),
    do: Enum.zip(t1, t2) |> Enum.reduce(s, fn {t1, t2}, acc -> acc |> rotation(t1, t2) end)

  def translate([a, b, c], [d, e, f], :add), do: [a + d, b + e, c + f]
  def translate([a, b, c], [d, e, f]), do: [a - d, b - e, c - f]

  def rotation([x, y, z], [a, b, c], [a, b, c]), do: [x, y, z]
  def rotation([x, y, z], [a, b, c], [b, aa, c]) when a == -aa, do: [y, -x, z]
  def rotation([x, y, z], [a, b, c], [aa, bb, c]) when a == -aa and b == -bb, do: [-x, -y, z]
  def rotation([x, y, z], [a, b, c], [bb, a, c]) when b == -bb, do: [-y, x, z]

  def rotation([x, y, z], [a, b, c], [aa, b, cc]) when a == -aa and c == -cc, do: [-x, y, -z]
  def rotation([x, y, z], [a, b, c], [b, a, cc]) when c == -cc, do: [y, x, -z]
  def rotation([x, y, z], [a, b, c], [a, bb, cc]) when b == -bb and c == -cc, do: [x, -y, -z]

  def rotation([x, y, z], [a, b, c], [bb, aa, cc]) when a == -aa and b == -bb and c == -cc,
    do: [-y, -x, -z]

  def rotation([x, y, z], [a, b, c], [c, b, aa]) when aa == -a, do: [z, y, -x]
  def rotation([x, y, z], [a, b, c], [aa, b, cc]) when aa == -a and cc == -c, do: [-x, y, -z]
  def rotation([x, y, z], [a, b, c], [cc, b, a]) when cc == -c, do: [-z, y, x]

  def rotation([x, y, z], [a, b, c], [cc, bb, aa]) when cc == -c and bb == -b and aa == -a,
    do: [-z, -y, -x]

  def rotation([x, y, z], [a, b, c], [aa, bb, c]) when aa == -a and bb == -b, do: [-x, -y, z]
  def rotation([x, y, z], [a, b, c], [c, bb, a]) when bb == -b, do: [z, -y, x]

  def rotation([x, y, z], [a, b, c], [a, cc, b]) when cc == -c, do: [x, -z, y]
  def rotation([x, y, z], [a, b, c], [a, bb, cc]) when bb == -b and cc == -c, do: [x, -y, -z]
  def rotation([x, y, z], [a, b, c], [a, c, bb]) when bb == -b, do: [x, z, -y]

  def rotation([x, y, z], [a, b, c], [aa, c, b]) when aa == -a, do: [-x, z, y]
  def rotation([x, y, z], [a, b, c], [aa, bb, c]) when aa == -a and bb == -b, do: [-x, -y, z]

  def rotation([x, y, z], [a, b, c], [aa, cc, bb]) when aa == -a and bb == -b and cc == -c,
    do: [-x, -z, -y]

  def rotation([x, y, z], [a, b, c], [cc, a, bb]) when cc == -c and bb == -b, do: [-z, x, -y]
  def rotation([x, y, z], [a, b, c], [b, cc, aa]) when cc == -c and aa == -a, do: [y, -z, -x]
  def rotation([x, y, z], [a, b, c], [bb, c, aa]) when bb == -b and aa == -a, do: [-y, z, -x]
  def rotation([x, y, z], [a, b, c], [c, aa, bb]) when bb == -b and aa == -a, do: [z, -x, -y]
  def rotation([x, y, z], [a, b, c], [b, c, a]), do: [y, z, x]
  def rotation([x, y, z], [a, b, c], [c, a, b]), do: [z, x, y]
  def rotation([x, y, z], [a, b, c], [bb, cc, a]) when cc == -c and bb == -b, do: [-y, -z, x]

  def rotation([x, y, z], [a, b, c], [cc, aa, b]) when cc == -c and aa == -a, do: [-z, -x, y]
end
