# Rollback-Auth-Base-Project
This is the base project I spent the last two and a half years building a custom networking solution for! 
I am currently working on converting this project to work with ECS for all networked components and core gameplay components. 
This is being done through a custom ECS plugin for godot that I am also working on. 

## Features# Rollback-Auth-Base-Project
This is the base project I spent the last two and a half years building a custom networking solution for! 
I am currently working on converting this project to work with ECS for all networked components and core game-play components. This is happening [in a new git repo here](https://github.com/LeftCircle/Hybrid_Rollback_Authoritative_Server)
This is being done through a custom ECS plugin for Godot that I am also working on. 

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

This project was initially 
