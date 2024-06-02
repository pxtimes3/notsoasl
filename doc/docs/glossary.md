###### **Effective fire**
Aimed shots by a entity not fatigued, panicked or similar negative conditions at 
a target the entity can see.

###### **Fatigue (int)**
: A value from 1-100 representing how fatigued an entity is. Regenerates at a rate 
of 5 per minute when not engaged in any activity.

###### **Activity (state)**
Moving, shooting, under fire, repairing, first aid etc. 

###### **Tired (state)**
Fatigue value of 51-75. Can not "Assault". Decreases hit probability by 10%.

###### **Fatigued (state)**
Fatigue value of 25-50. Can not "Assault" or "Move Fast". Decreases hit 
probability by 20%.

###### **Exhausted (state)**
Fatigue value of 1-25. Can only "Move". Decreases hit probability by 30%.

###### **Morale (int)**
A value from 1-100 representing how willing an entity is to follow orders. 
Leaders can rally their troops by using points from their rally pool. Decreases
depending on what happens to an entity. Ex. a unit member getting killed 
decreases the value by 10. Being under direct fire decreases the value by 1 for 
every turn. Indirect fire decreases the value by 4 for every turn one entity in
the unit is in the blast radius of an exploding munition etc.

######<a id="rally-pool"></a> **Rally pool (int)**
Leaders have 1-10 points they can use to rally their unit (or adjacent ones). 
This increases morale by 20%. Once these are exhausted a unit or entity can only
self rally.

###### **Self rally (action)**
A successful self rally action increases the morale value by 10. Performed at
every turn if there is no entity to hand out rally points. 

###### **Panicked (state)**
Morale value of 1-10. Acts as an NPC. Fires back if fired upon. Moves at fastest 
possible pace towards the starting edge of the map. 

###### **Hit probability (int)**
An entity has a base probability of 50% for hitting a standing target within the
weapons "range". This decreases depending on the targets "morale", "fatigue", 
"stance" and the targets "cover". Base value increases depending on the entitys 
"experience". Can not be less than 5% due to game reasons (would be boring).

Order of calculation is (50 + exp) - (fatigue + stance + cover).
So a tired entity with a conscript experience trying to hit a kneeling target 
behind a brick wall would be as follows: 50 - (10 + 20 + 20) = 5 (min value). A
veteran entity (+15) would have a 15% chance of hitting the target.

###### **Stance (state)**
Standing, kneeling, prone. Used for calculating hit probability.

###### **Standing (state)**
No decrease in hit probability. Entity can see over "cover" with a height of 
maximum 1.25 meters.

###### **Kneeling (state)**
Hit probability decreased by 20%. Entity can see over "cover" with a height of 
maximum 0.75 meters.

###### **Prone (state)**
Hit probability decreased by 40%. Entity can see over "cover" with a height of 
maximum 0.25 meters.

###### **Cover (float)**
Decreases hit probability depending on type of cover. A stone wall decreases hit 
probability by 20%, a bunker by 50%, a tree by 10% etc. 

###### **Experience** (int, range 1-4)
1. **Conscript:** Just out of basic.
	+0 hit, +0 morale
2. **Experienced:** Has seen combat.
	+10 hit, +5 morale, cost 1.2
3. **Veteran:** Veteran of many engagements.
	+20 hit, +10 morale, cost 1.4
4. **Elite:** Specially trained and/or has seen a lot of combat.
	+30 hit, +15 morale, cost 1.6

###### **Straggler (state)** 
A soldier that has become decoupled from his unit by exiting LOS with the unit. Stragglers are considered a separate unit that cannot self rally. The straggler state ends if the straggler comes within his units zone of influence.

###### **Zone of Influence (area, r)** 
