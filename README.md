# TPFinalMobile

Application Flutter utilisant l'API publique Raider.IO:
`https://raider.io/api`.

Modules:

- Guildes raid: appels `/api/v1/guilds/profile` et `/api/v1/raiding/raid-rankings`, recherche par région/royaume/nom et leaderboard top 10.
- Recherche personnage: appel `/api/v1/characters/profile`, profil détaillé avec score Mythic+, rangs, progression raid, équipement, ilvl et meilleures clés.

Le projet respecte les contraintes: pas de Firebase, pas de base locale, pas d'authentification, pas de caméra, pas de GPS et pas de bouton "J'y suis !".
