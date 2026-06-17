# Delivery Driver System

## Video Preview

* [Watch on YouTube](https://youtu.be/S0ZIxUO6q7k)

---

# Overview

The Delivery Driver System is a side activity/job where players deliver packages across Los Santos using warehouse delivery vans.

The system includes:

* Physical package handling
* Dynamic delivery destinations
* Database integration
* Player authentication
* Modular architecture

---

# Features

* Delivery warehouse with delivery van spawns
* Package loading system
* Physical package deliveries
* Delivery destinations with checkpoints and map icons
* Delivery vehicle registration system
* Package counter textdraws
* Delivery rewards
* Score rewards for completed deliveries
* Delivery statistics tracking
* Player statistics command
* MySQL authentication system
* Persistent player data
* Modular architecture powered by YSI hooks

---

# Starting the Job

1. Go to the delivery warehouse
2. Enter a delivery van
3. Use the following command:

```pawn
/startdelivery
```

This will:

* Register the player as a Delivery Driver
* Register the vehicle as a Delivery Van
* Allow package loading

---

# Loading Packages

Players can load packages at the warehouse loading checkpoint.

Once loaded:

* The delivery van stores a limited number of packages
* The package counter is updated automatically

---

# Package Display

While a registered Delivery Driver is inside a Delivery Van, a textdraw displays:

```text
Packages in the van: X
```

This updates dynamically as deliveries are completed.

---

# Starting Deliveries

Players can request a delivery destination using:

```pawn
/nextdelivery
```

Requirements:

* The player must be registered as a Delivery Driver
* The van must contain at least one package

Upon success:

* A delivery destination is selected
* A checkpoint is created
* A map icon is displayed

---

# Completing Deliveries

To complete a delivery:

1. Park the delivery van near the destination
2. Exit the vehicle
3. Open the van rear doors by pressing: [H]
4. Pick up a package by pressing: [Y]
5. Walk to the property's entrance
6. Deliver the package

---

# Statistics

The system tracks player delivery progress and stores it in the database.

Tracked statistics include:

- Completed deliveries
- Player money
- Player score

Players can view their progress at any time using:

```pawn
/stats
```
---

# Rewards

Each completed delivery rewards:

```text
$3,000
+1 score point
```

Player money and delivery statistics are automatically saved in the database.

---

# Commands

| Command          | Description                            |
| ---------------- | -------------------------------------- |
| `/startdelivery` | Starts the Delivery Driver job         |
| `/nextdelivery`  | Requests the next delivery destination |
| `/stopdelivery`  | Stops the current delivery job         |
| `/stats` | Displays player statistics |

---

# Authentication System

The project includes a MySQL-based authentication system with:

* Player registration
* Player login
* Password hashing with SHA-256
* Session handling
* Persistent player data

---

# Database Features

The system stores:

* Player money
* Player score
* Completed deliveries
* Authentication data
* Delivery statistics

All data is loaded and saved automatically using MySQL.

---

# Technical Notes

The system includes:

* Delivery vehicle state management
* Player delivery state tracking
* Dynamic checkpoints
* Dynamic map icons
* Per-player textdraws, checkpoints, and icons
* Physical package handling logic
* Vehicle rear door interaction
* MySQL database integration
* Modular callback architecture
* Persistent player data system

---

# Project Structure

The project uses a modular architecture:

```text
gamemodes/
├── modules/
│    ├── core/
│    │   ├── player/
│    │   │   └── auth/
│    │   │   └── core/
│    │   └── vehicles/
│    └── systems/
|        └── delivery/
|
├── base.inc
└── builder.pwn
```

This structure improves:

* Scalability
* Maintainability
* Code organization
* System separation
