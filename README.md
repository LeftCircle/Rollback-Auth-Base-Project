# Rollback-Auth-Base-Project
This is the base project I spent the last two and a half years building a custom networking solution for! This was intended to be a competitive multiplayer rogue like battle royale, but instead of developing the gameplay I found myself working on just the networking. This project has undergone several iterations starting with lag compensation and OOP, a full gameplay architecture overhaul to ECS, a network architecture overhaul to Rollback, then a second architecture overhaul to a hybrid rollback/authoritative server networking solution.

## Motivation
Because this was a top down hack and slash game with bullet hell components and rechargeable ranged attacks, it was very important to trust both the shooter and the dodger. I could have continued with the tried and true lag compensation networking solution, but this would have resulted in players getting hit by projectiles that they saw their characters dodge. In a rogue like game where every hit matters, this is unacceptable. Rollback networking seemed like the ideal solution, but there is no way that pure rollback could support 30+ players. And so a hybrid rollback/authoritative server networking solution (similar to what Rocket League does) was born.

The authoritative server does away with the requirement of determinism (which is great because godot is non-deterministic out of the box), and also allows us to spread players out around the dungeon and only inform them about the world immediately around them. Clients will predict their local state and that of the world around them based on predicted and received inputs from other clients, and this world state will be verified and corrected by the authoritative server.

With some subtle tricks to hide the jitter that comes with Rollback, we had a performant solution that trusts the dodger and the shooter at the cost of a few anticipation frames and near perfect hit prediction.


## Future Work
I am currently working on converting this project to work with ECS for all networked components and core gameplay components. 
This is being done through a custom ECS plugin and networking plugin. There's also an open issue where ENet (or godot somehow) tends to have UDP packets arrive in groups of 3+ no matter the size of the packets. Still haven't figured that one out yet, but it isn't the worst issue in the world.  

This is happening [in a new git repo here](https://github.com/LeftCircle/Hybrid_Rollback_Authoritative_Server)


### Terminology:
- client = a players instance of the game.
- server = authoritative server that acts as the ground truth for the game. 
- local player = the character that a given client is controlling.
- remote player = multiplayer characters that a given client can see.
- world state = data representation of all objects on a given frame
- command frame = a synchronized tick of the game
- input = inputs for a given frame such as attack, dodge, move left, etc.

## Features
- Graph Grammar level generation
- local world state prediction
- remote player input prediction
- remote player state prediction
- client rollback correction when desyncs occur due to input/world state misspredictions 
- Frame synchronization keeping all clients synced at the same frame ahead of the server
- and more!

