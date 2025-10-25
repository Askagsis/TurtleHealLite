# TurtleHealLite

TurtleHealLite est un petit addon inspiré de HealBot pour Turtle WoW (vanilla 1.12).  
Il permet de :

- Afficher la durée restante de buffs / HoTs sur des unités (player, target, mouseover)  
- Clic sécurisé pour lancer vos sorts de soin configurés  
- Configuration simple via commandes slash

## Commandes

- `/thl spell <nom>` : définit le sort principal à lancer avec le clic gauche  
- `/thl show <unités>` : définit les unités à afficher (ex : player target mouseover)

## Installation

1. Crée un dossier `TurtleHealLite` dans `Interface/AddOns/`  
2. Ajoute les fichiers :  
   - `TurtleHealLite.toc`  
   - `TurtleHealLite.lua`  
   - `TurtleHealLite.xml`  
   - `README.md`  
   - `LICENSE`  
3. Lance Turtle WoW et coche **TurtleHealLite** dans la liste AddOns  
4. Active **Load out of date AddOns** si nécessaire

## Développement / GitHub

- Crée un repo GitHub et pousse ces fichiers  
- Tu peux ajouter :
  - Plus de sorts suivis
  - Couleurs par joueur
  - Frames de groupe/raid
  - Comportement “mouseover-only”
