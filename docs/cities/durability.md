# City Durability

## City Durability Attribute
When you occupy a city, its Durability starts at 0. Durability increases at a rate of +1 per second, up to a maximum of 3000.

Every 100 Durability grants +1% defense bonus. At maximum Durability (3000), a city gains +30% defense.

If a city is captured by enemies, its Durability immediately resets to 0, and the new owner must rebuild it over time.

## Alliance Border Rules
If an alliance border city is lost, its Durability is immediately reduced by -500.

If a border city is lost but its Durability is still above 0, the alliance **[territory](../alliances/territory.md)** will not collapse immediately.

Durability will then start to decrease over time, and once it reaches 0, the territory collapses.

This provides a buffer window for the alliance to regroup and recapture the city.

