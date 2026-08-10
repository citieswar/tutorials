# Alliance Diplomacy

There are five diplomacy statuses between alliances:

- **Neutral**
- **Allied**
- **NAP**
- **Embargo**
- **At War**

The previous **Active / Passive** one-way relationships have been removed. Alliance relations are now **symmetrical** where applicable.

All existing **None** relationships have been renamed to **Neutral**.

## Managing Diplomacy

Alliance **Leaders** and **Co-Leaders** can set diplomatic statuses with other alliances.

All members can view an alliance's diplomacy by clicking the **Alliance Diplomacy → Show** button.

When you move your troops, launch a missile, or use the radar, cities will be shown in different colors based on your alliance's diplomatic status with other alliances.

## Allied and NAP

Forming an **Allied** or **NAP** relationship requires approval from the other alliance.

- Only the **Leader** or **Co-Leader** of the other alliance can approve the request.
- **Allied** and **NAP** alliances cannot attack each other's cities.
- **Allied** alliances do not block each other's territory.
- **NAP** alliances still block each other's territory.

## Embargo

An alliance can impose an **Embargo** on another alliance without requiring approval.

- Embargoed alliances **cannot pass through your cities**.
- Embargoed alliances can still **attack your cities**.
- Embargoed alliances' troops are blocked by your cities when using your routes.

## At War

When two alliances are **At War**, the relationship cannot be changed directly.

To end the war:

1. One alliance must send an **Offer Peace** request.
2. The opposing alliance must accept the request.
3. The relationship will then become **Neutral**.

While two alliances are At War:

- Their cities **block each other's troops** from passing through their routes.
- Their territories **block each other's troops**.
- They can **attack each other's cities**.

## Route Blocking

When your alliance sets another alliance to a status that blocks routes, your occupied cities will prevent the other alliance's **armies and navies** from marching through your [routes](../cities/routes.md).

## Summary of Alliance Relations

| Relation Type | Requires Consent | Route Blocked | Territory Blocked | Can Attack |
|---------------|------------------|---------------|-------------------|------------|
| Neutral       | No               | No            | Yes               | Yes        |
| Allied        | Yes              | No            | No                | No         |
| NAP           | Yes              | No            | Yes               | No         |
| Embargo       | No               | Yes           | Yes               | Yes        |
| At War        | No               | Yes           | Yes               | Yes        |