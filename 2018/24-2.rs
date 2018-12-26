use std::collections::HashSet;
use std::collections::HashMap;
use std::collections::BTreeMap;

#[derive(Clone)]
struct Army {   
    id : u8, 
    atype : usize,
    units: u32,
    hp : u32,
    initiative : u8,
    dmg : u32,
    damage_type : String,
    immune : HashSet<String>,
    weak : HashSet<String>,
}

impl Army {
    fn new(id : u8, atype : usize, units: u32, hp: u32, initiative: u8, dmg : u32, damage_type_ : &str, immune_ : Vec<&str>, weak_ : Vec<&str>,) -> Army {
        let mut immune = HashSet::new();
        for im in immune_ {
            immune.insert(im.to_string());
        }
        let mut weak = HashSet::new();
        for w in weak_ {
            weak.insert(w.to_string());
        }
        let damage_type = damage_type_.to_string();
        return Army { id, atype, units, hp, initiative, dmg, damage_type, immune, weak };
    }

    
    fn potential_damage(self, to: &Army) -> u32 {
        if to.immune.contains(&self.damage_type) {
            return 0;
        }
        let power = self.units * self.dmg;
        if to.weak.contains(&self.damage_type) {
            return power * 2;
        }
        /*if to.hp > power {
            return 0;
        }*/
        return power;
    }

    fn defend(&mut self, against : &Army) -> bool {
        if self.immune.contains(&against.damage_type) {
            return true;
        }
        let mut power = against.units * against.dmg;
        if self.weak.contains(&against.damage_type) {
            power = power * 2;
        }
        if power / self.hp >= self.units { 
            return false; //we die
        } else {
            self.units -= power/self.hp;
            return true;
        }
    }

    
}

const FAKE_ID : u8 = 255;

fn main(){
    //let mut immune_system : HashMap<u8,Army> = HashMap::new();
    //let mut infection : HashMap<u8,Army> = HashMap::new();
    let mut armies : HashMap<u8,Army> = HashMap::new();
    let mut armies_by_type : Vec<HashSet<u8>> = Vec::new();
    armies_by_type.push(HashSet::new());
    armies_by_type.push(HashSet::new());
    //let mut immune_system : HashSet<u8> = HashSet::new();
    //let mut infection : HashSet<u8> = HashSet::new();



    /*
    Immune System:
17 units each with 5390 hit points (weak to radiation, bludgeoning) with
 an attack that does 4507 fire damage at initiative 2
989 units each with 1274 hit points (immune to fire; weak to bludgeoning,
 slashing) with an attack that does 25 slashing damage at initiative 3

Infection:
801 units each with 4706 hit points (weak to radiation) with an attack
 that does 116 bludgeoning damage at initiative 1
4485 units each with 2961 hit points (immune to radiation; weak to fire,
 cold) with an attack that does 12 slashing damage at initiative 4
    */

    /*
    armies.insert(0,Army::new(
        0, 0, 17, 5390, 2, 4507, "fire", Vec::new(), vec!["radiation","bludgeoning"]
    ));
    armies_by_type[0].insert(0);

    armies.insert(1,Army::new(
        1, 0, 989, 1274, 3, 25, "slashing", vec!["fire"], vec!["slashing","bludgeoning"]
    ));
    armies_by_type[0].insert(1);

    armies.insert(3,Army::new(
        3, 1, 801, 4706, 1, 116, "bludgeoning", Vec::new(), vec!["radiation"]
    ));
    armies_by_type[1].insert(3);

    armies.insert(4,Army::new(
        4, 1, 4485, 2961, 4, 12, "slashing", vec!["radiation"], vec!["fire","cold"]
    ));
    armies_by_type[1].insert(4);

    / */
    armies.insert(0,Army::new(
        0, 0, 197, 6697, 3, 312, "slashing", Vec::new(), vec!["bludgeoning","fire"]
    ));
    armies_by_type[0].insert(0);
    armies.insert(1,Army::new(
        1, 0, 3803, 8760, 9, 21, "slashing", Vec::new(), vec!["bludgeoning"]
    ));
    armies_by_type[0].insert(1);
    armies.insert(2,Army::new(
        2, 0, 5279, 4712, 7, 8, "cold", Vec::new(), Vec::new()
    ));
    armies_by_type[0].insert(2);
    armies.insert(3,Army::new(
        3, 0, 3727, 11858, 19, 25, "cold", Vec::new(), vec!["slashing"]
    ));
    armies_by_type[0].insert(3);
    armies.insert(4,Army::new(
        4, 0, 494, 3486, 6, 70, "cold", vec!["bludgeoning"], vec!["radiation"]
    ));
    armies_by_type[0].insert(4);
    armies.insert(5,Army::new(
        5, 0, 1700, 8138, 18, 41, "slashing", Vec::new(), vec!["slashing"]
    ));
    armies_by_type[0].insert(5);
    armies.insert(6,Army::new(
        6, 0, 251, 4061, 15, 157, "radiation", Vec::new(), vec!["bludgeoning"]
    ));
    armies_by_type[0].insert(6);
    armies.insert(7,Army::new(
        7, 0, 87, 1699, 11, 161, "cold", Vec::new(), Vec::new()
    ));
    armies_by_type[0].insert(7);
    armies.insert(8,Army::new(
        8, 0, 1518, 9528, 2, 60, "slashing", Vec::new(), vec!["cold","slashing"]
    ));
    armies_by_type[0].insert(8);
    armies.insert(9,Army::new(
        9, 0, 347, 6624, 12, 148, "slashing", vec!["fire"], vec!["bludgeoning"]
    ));
    armies_by_type[0].insert(9);

    armies.insert(10,Army::new(
        10, 1, 6929, 51693, 5, 13, "slashing", Vec::new(), Vec::new()
    ));
    armies_by_type[1].insert(10);
    armies.insert(11,Army::new(
        11, 1, 1638, 32400, 16, 27, "bludgeoning", Vec::new(), vec!["bludgeoning"]
    ));
    armies_by_type[1].insert(11);
    armies.insert(12,Army::new(
        12, 1, 2311, 12377, 8, 9, "slashing", vec!["cold"], vec!["fire"]
    ));
    armies_by_type[1].insert(12);
    armies.insert(13,Army::new(
        13, 1, 685, 29080, 10, 57, "bludgeoning", vec!["radiation"], vec!["bludgeoning","fire"]
    ));
    armies_by_type[1].insert(13);
    armies.insert(14,Army::new(
        14, 1, 1225, 7657, 14, 12, "cold", Vec::new(), vec!["slashing"]
    ));
    armies_by_type[1].insert(14);
    armies.insert(15,Army::new(
        15, 1, 734, 52884, 13, 102, "bludgeoning", Vec::new(), Vec::new()
    ));
    armies_by_type[1].insert(15);
    armies.insert(16,Army::new(
        16, 1, 608, 49797, 1, 162, "bludgeoning", vec!["slashing"], vec!["radiation"]
    ));
    armies_by_type[1].insert(16);
    armies.insert(17,Army::new(
        17, 1, 3434, 49977, 4, 28, "radiation", Vec::new(), Vec::new()
    ));
    armies_by_type[1].insert(17);
    armies.insert(18,Army::new(
        18, 1, 1918, 14567, 20, 13, "bludgeoning", Vec::new(), vec!["slashing"]
    ));
    armies_by_type[1].insert(18);
    armies.insert(19,Army::new(
        19, 1, 519, 18413, 17, 69, "fire", vec!["slashing"], Vec::new()
    ));
    armies_by_type[1].insert(19);
    // */

/*
    Immune System:
197 units each with 6697 hit points (weak to bludgeoning, fire) with an attack that does 312 slashing damage at initiative 3
3803 units each with 8760 hit points (weak to bludgeoning) with an attack that does 21 slashing damage at initiative 9
5279 units each with 4712 hit points with an attack that does 8 cold damage at initiative 7
3727 units each with 11858 hit points (weak to slashing) with an attack that does 25 cold damage at initiative 19
494 units each with 3486 hit points (weak to radiation; immune to bludgeoning) with an attack that does 70 cold damage at initiative 6
1700 units each with 8138 hit points (weak to slashing) with an attack that does 41 slashing damage at initiative 18
251 units each with 4061 hit points (weak to bludgeoning) with an attack that does 157 radiation damage at initiative 15
87 units each with 1699 hit points with an attack that does 161 cold damage at initiative 11
1518 units each with 9528 hit points (weak to cold, slashing) with an attack that does 60 slashing damage at initiative 2
347 units each with 6624 hit points (immune to fire; weak to bludgeoning) with an attack that does 148 slashing damage at initiative 12

Infection:
6929 units each with 51693 hit points with an attack that does 13 slashing damage at initiative 5
1638 units each with 32400 hit points (weak to bludgeoning) with an attack that does 27 bludgeoning damage at initiative 16
2311 units each with 12377 hit points (weak to fire; immune to cold) with an attack that does 9 slashing damage at initiative 8
685 units each with 29080 hit points (weak to bludgeoning, fire; immune to radiation) with an attack that does 57 bludgeoning damage at initiative 10
1225 units each with 7657 hit points (weak to slashing) with an attack that does 12 cold damage at initiative 14
734 units each with 52884 hit points with an attack that does 102 bludgeoning damage at initiative 13
608 units each with 49797 hit points (weak to radiation; immune to slashing) with an attack that does 162 bludgeoning damage at initiative 1
3434 units each with 49977 hit points with an attack that does 28 radiation damage at initiative 4
1918 units each with 14567 hit points (weak to slashing) with an attack that does 13 bludgeoning damage at initiative 20
"519 units each with 18413 hit points (immune to slashing) with an attack that does 69 fire damage at initiative 17".match(/^([0-9]+) units each with ([0-9]+) hit points( \(((immune to ([a-z]+))|(weak to (([a-z]+),?)+);?)+\))? with an attack that does ([0-9]+) ([a-z]+) damage at initiative of ([0-9]+)$/)

var idx = -1;
String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
}
document.body.innerText.split("\n\n").forEach(
    (v,t) => { 
        
        console.log(v.split("\n").filter(v => v!="").map(line => { 
            var matches = line.match(/^([0-9]+) units each with ([0-9]+) hit points( \((.+)\))? with an attack that does ([0-9]+) ([a-z]+) damage at initiative ([0-9]+)$/);
            if (!matches) {
                return "";
            }
            var units = matches[1]-0;
            var hp = matches[2]-0;
            var dmg = matches[5]-0;
            var initiative = matches[7] - 0;
            var dmg_type = matches[6].capitalize();
            var weakness = [];
            var immunity = [];
            if (matches[4]) {
                var variants = matches[4].split("; ");
                variants.forEach(v => { 
                    if (v[0] == "i") { 
                        immunity.push(v.split("to ")[1].capitalize());
                    } else { 
                        v.split("to ")[1].split(", ").forEach( w => weakness.push(w.capitalize())); 
                    } 
                }); 
            }
            idx++;
            var im = 'vec!['+immunity.join(',')+']';
            var wk = 'vec!['+weakness.join(',')+']';
            return `Group {team: ${t}, units: ${units}, hp: ${hp}, weak: ${wk}, immune: ${im}, ap: ${dmg}, at: ${dmg_type}, initiative: ${initiative}},`;
             
        }).join("\n")); 
    });


            return `    armies.insert(${idx},Army::new(
        ${idx}, ${t}, ${units}, ${hp}, ${initiative}, ${dmg}, "${dmg_type}", ${im}, ${wk}
    ));
    armies_by_type[${t}].insert(${idx});`;

*/


    let mut min_boost = 0;
    let mut max_boost = 189;
    for (_, a) in &armies {
        if a.atype == 1 && a.units * a.dmg > max_boost {
            max_boost = a.units * a.dmg;
        }
    }

    let mut carmies = armies.clone();
    let mut carmies_by_type = armies_by_type.clone();
    let mut last_set_min_boost = false;

    //let mut boost = 0;

    loop {
        //boost +=1;

        let delta = max_boost - min_boost;
        if delta == 0 || delta == 1 && last_set_min_boost == false {
            break;
        }
        let boost = if max_boost - min_boost == 1 && last_set_min_boost {
            max_boost
        } else {
            min_boost + delta / 2
        };

        carmies = armies.clone();
        carmies_by_type = armies_by_type.clone();
        for (_,army) in carmies.iter_mut() {
            if army.atype == 0 {
                army.dmg+= boost;
            }
        }

        let mut is_stalemate = false;
        let mut immunity_won = false;

        loop {
            if is_stalemate || carmies_by_type[0].len() == 0 || carmies_by_type[1].len() == 0 {
                println!("boost was: {}", boost);
                if carmies_by_type[1].len() == 0 {
                    max_boost = boost;
                    last_set_min_boost = false;
                } else {
                    min_boost = boost;
                    last_set_min_boost = true;
                }
                break;
            }
            let mut did_damage = 0;
            let mut targets_to_select_by_type = carmies_by_type.clone();
            let mut target_from_to = HashMap::new();

            let mut army_tgt_selection_ord : BTreeMap<(i64,i8),u8> = BTreeMap::new();
            for (_k,army) in &carmies {
                army_tgt_selection_ord.insert((-(army.units as i64 * army.dmg as i64), -(army.initiative as i8) ),army.id);
            }

            for (_k, army_id) in army_tgt_selection_ord {
                let me = carmies.get(&army_id).unwrap();
                let other_type = (me.atype + 1) %2;
                if targets_to_select_by_type[other_type].len() > 0 {
                    let mut best = (FAKE_ID, 0, 0, 0); //id, dmg, power, initiative
                    for tgt_id in &targets_to_select_by_type[other_type] {
                        let target = &carmies[&tgt_id];
                        let dmg = me.clone().potential_damage(&target);
                        if dmg > 0 && ( dmg > best.1 || 
                        (dmg == best.1 && target.units*target.dmg > best.2 ) ||
                        (dmg == best.1 && target.units*target.dmg == best.2 && target.initiative > best.3) ) {
                            best = (*tgt_id, dmg, target.units*target.dmg, target.initiative);
                        }
                    }
                    if best.0 != FAKE_ID {
                        targets_to_select_by_type[other_type].remove(&best.0);
                        target_from_to.insert(army_id,best.0);
                    }
                }
            }

            let mut army_attack_ord : BTreeMap<i8,u8> = BTreeMap::new();
            for (_k,army) in &carmies {
                army_attack_ord.insert(-(army.initiative as i8), army.id);
            }
            for (_k,army_id) in army_attack_ord {
                if carmies.contains_key(&army_id) && target_from_to.contains_key(&army_id) {
                    let mut target = carmies[&target_from_to[&army_id]].clone();
                    let me = carmies[&army_id].clone();
                    let old_units = target.units;
                    if !target.defend(&me) {
                        did_damage += old_units;
                        carmies.remove(&target.id);
                        carmies_by_type[target.atype].remove(&target.id);
                    } else {
                        did_damage += old_units - target.units;
                        carmies.insert(target.id, target);
                    }
                }
            }
            if did_damage == 0 {
                is_stalemate = true;
            }
        }
        if immunity_won {
            break;
        }
    }

    let mut cnt = 0;
    for (_,army) in &carmies {
        println!("type: {}, id: {}, units: {}", army.atype, army.id, army.units);
        cnt+= army.units;
    }

    println!("Remaining units: {}", cnt);
    
}