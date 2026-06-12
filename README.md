# Delivery Driver System

## Video preview

- [Watch on YouTube](https://www.youtube.com/watch?v=Myd-5Kra7AA)

---

## Overview

The Delivery Driver System is a side activity/job where players deliver packages across "Los Santos" using warehouse delivery vans.

---

# Features

* Delivery warehouse with delivery van spawns
* Package loading system
* Delivery destinations with checkpoints and map icons
* Delivery vehicle registration system
* Package counter textdraws
* Delivery rewards
* Dynamic delivery workflow

---

# Starting the Job

1. Go to the delivery warehouse.
2. Enter a delivery van.
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
* A map icon/marker is displayed

---

# Completing Deliveries

To complete a delivery:

1. Park your car closer to the delivery checkpoint
2. Exit the delivery van
3. Open the van rear doors "Press [H]"
4. Pick up a package "Press [Y]"
5. Walk to the property's entrance
6. Deliver the package

---

# Rewards

Each completed delivery rewards:

```text
$3,000
```

---

# Commands

| Command          | Description                            |
| ---------------- | -------------------------------------- |
| `/startdelivery` | Starts the Delivery Driver job         |
| `/nextdelivery`  | Requests the next delivery destination |
| `/stopdelivery`  | Stops the current delivery job            |

# Technical Notes

The system includes:

* Delivery vehicle state management
* Player delivery state tracking
* Dynamic checkpoints
* Dynamic map icons
* Per-player textdraws, checkpoints and icons
* Package handling logic
