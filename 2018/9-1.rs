use std::collections::HashMap;
use std::collections::VecDeque;

fn main () {
    //10 players; last marble is worth 1618 points
    //let input = get_input("input-9", |s| );

    let players : u16 = 400;
    let last_marble = 71864u32;
    
    let mut player_scores : HashMap<u16,u32> = HashMap::new();
    let mut marbles : VecDeque<u32> = VecDeque::with_capacity(last_marble as usize);
    marbles.push_back(0);
    
    let mut current_player = 0u16;

    for i in 1..=last_marble {
        if i % 23 == 0 {
            let mut score = i;
            for _ in 0..7 {
                let m = marbles.pop_front().unwrap();
                marbles.push_back(m);
            }
            let s = marbles.pop_front().unwrap();
            score += s;
            let m = marbles.pop_back().unwrap();
            marbles.push_front(m);
            let ps = player_scores.entry(current_player).or_insert(0);
            *ps += score;
        } else {
            let m = marbles.pop_back().unwrap();
            marbles.push_front(m);
            marbles.push_front(i);
        }
        current_player = (current_player + 1) % players;
    }

    let max_score :u32 = *player_scores.values().max().unwrap();

    println!("The result: {}", max_score );
}

