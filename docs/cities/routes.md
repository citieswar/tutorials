# Routes

All cities are connected by routes, which are **[drawn](../cities/request.md#route-request)** by players in the game.

There are 6 types of routes in the game: Open Terrain, Mountain, Desert, Forest, Tundra, and Ocean. Each route type affects the movement speed of your troops.

## Movement rules:
- **[Armies](../units/armies.md)** can move on the Open Terrain, Mountain, Desert, Forest, and Tundra routes.
- **[Navies](../units/navies.md)** can only move on Ocean routes.
- **[Air Forces](../units/airforces.md)** ignore terrain and move in a straight line between cities.

If your army/navy starts from the base or wild area, the starting point will be automatically connected to the nearest city’s route.

If your army or navy is defeated, it will return directly to the base.