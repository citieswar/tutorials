# Territory Championship

Territory Championship is a large-scale alliance competition focused on land control.
All alliances compete to occupy and hold as much territory as possible on the world map during the season.
The goal is to expand your alliance’s area, population, and value — and earn the highest score by maintaining control over your land.

## Schedule
- **Preparation Phase – 1 Day:** All existing alliance territories will be cleared. During this time, alliances cannot establish capitals and territories.
- **War Phase – 30 Days:** The official championship begins. Alliances expand their territories, capture cities, and defend key positions.
- **Rest Phase – 3 Days:** Alliance scores are finalized. Rewards will be distributed based on final rankings.

## Scoring System
- Scores are updated every 10 minutes based on territories currently held.
- If a territory is lost, the corresponding score will be deducted.
- Final rankings are determined by the accumulated score throughout the season.
- **Evaluation Factors:** 
	- Alliance Territory Area(60%) 
	- Held Cities Value within Territory(25%) 
	- Held Cities Population within Alliance Territory(15%)
- **Score Calculation** 
	- When an alliance controls territory, score increases according to:<br>
		Score Gain = **Minutes × log(1 + (Area × 0.6 + TotalValue × 0.25 + TotalPopulation × 0.15))**
	- When an alliance controls no territory, score may decrease. Alliances with a current score below 50% of the global average do not lose score. If the score is between 50% and 100% of the average, a gradually increasing penalty is applied:	<br>
		Penalty = **log(1 + 1000) × ((CurrentScore − 50% of AverageScore) / (50% of AverageScore))**
	- If the score is above the global average, a stronger penalty applies:	<br>
		Penalty = **log(1 + 1000 + (CurrentScore − AverageScore) × 0.5)**
	- The final score change is the sum of all gains and losses during the interval.

## Rewards
- The top 5 alliances will receive gem rewards.
- Additional daily resource bonus for alliance members.
- The No.1 Alliance will receive an exclusive title and recognition for its domination of the season.