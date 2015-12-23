var spells = [
	{
		cost : 53,
		dmg : 4,
		heal : 0,
		mana : 0,
		effect: -1,
		def : 0,
		name : "Magic Missile"
	},
	{
		name : "Drain",
		cost : 73,
		dmg: 2,
		def : 0,
		heal : 2,
		mana : 0,
		effect : -1
	},
	{
		name : "Shield",
		cost : 113,
		dmg : 0,
		heal : 0,
		mana : 0,
		def: 7,
		effect : 6
	},
	{
		name : "Poison",
		cost : 173,
		dmg : 3,
		def : 0,
		heal : 0,
		mana : 0,
		effect : 6
	},
	{
		name : "Recharge",
		cost : 229,
		dmg : 0,
		def : 0,
		heal : 0,
		mana : 101,
		effect : 5
	}
];

var player = {
	hp : 50,
	mana : 500
};

var boss = {
	hp : 55,
	dmg : 8
};

function cloneArr(arr) {
	return arr.map((i) => { return cloneObj(i); });
}

function cloneObj(obj) {
	var ret = {}; for ( var k of Object.keys(obj) ) { ret[k] = obj[k]; } return ret;
}

var hard_mode = false;

function play(players_turn, p, b, effects, spent_mana, min_mana) {
	var p_def = 0;
	//first the effects
	var removed = 0;
	if ( players_turn && hard_mode ) {
		p.hp--;
		if ( p.hp < 1 ) {
			return +Infinity;
		}
	}
	Array.from(effects).forEach((eff, i) => {
		p.hp += eff.heal;
		p.mana += eff.mana;
		b.hp -= eff.dmg;
		p_def += eff.def;
		eff.effect--;
		if ( eff.effect === 0 ) {
			effects.splice(i - removed,1);
			removed++;
		}
	});
	//check if boss is dead after the effects
	if ( b.hp < 1 ) {
		//player wins!!!!
		return spent_mana;
	}
	if ( players_turn ) {
		var cast_a_spell = false;
		for ( var spell of spells ) {
			if ( spent_mana + spell.cost > min_mana || spell.cost > p.mana ) {
				//spell is too expensive anyway
				continue;
			}
			cast_a_spell = true;
			p.mana -= spell.cost;
			if ( spell.effect === -1 ) {
				//apply now
				b.hp -= spell.dmg;
				p.hp += spell.heal;
				if ( b.hp < 1 ) {
					return spent_mana + spell.cost;
				}
				min_mana = Math.min(min_mana, play((players_turn+1)%2, cloneObj(p), cloneObj(b), cloneArr(effects), spent_mana + spell.cost, min_mana) );
				b.hp += spell.dmg;
				p.hp -= spell.heal;
			} else {
				//hey it's an effect
				//check if this effect is already active
				if ( !effects.find((eff) => eff.name === spell.name) ) { 
					effects.push(cloneObj(spell));
					min_mana = Math.min(min_mana, play((players_turn+1)%2, cloneObj(p), cloneObj(b), cloneArr(effects), spent_mana + spell.cost, min_mana) );
					effects.pop();
				}
			}
			p.mana+=spell.cost;
		}
		return cast_a_spell ? min_mana : +Infinity;
	} else {
		p.hp -= Math.max(b.dmg - p_def, 1);
		if ( p.hp < 1 ) {
			//player loses :((((
			return +Infinity;
		}
		return play((players_turn+1)%2, cloneObj(p), cloneObj(b), cloneArr(effects), spent_mana, min_mana);
	}
}

console.log("Answer 1", play(1, cloneObj(player), cloneObj(boss),[],0,+Infinity));
hard_mode = true;
console.log("Answer 2", play(1, cloneObj(player), cloneObj(boss),[],0,+Infinity));