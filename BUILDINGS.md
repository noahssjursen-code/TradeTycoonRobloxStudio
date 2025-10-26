# Building System Documentation

## Overview

The building system in Trade Tycoon uses a generic, type-based architecture that allows buildings to be defined once and used across all industries. Buildings are placed on the grid and produce resources or process materials.

## Building Types

### 1. Raw Material Producers
Extract resources directly from the ground/nature.

**Examples:**
- **Iron Mine** - Produces: Iron Ore
- **Coal Mine** - Produces: Coal
- **Copper Mine** - Produces: Copper Ore
- **Lumberjack** - Produces: Wood Logs
- **Stone Quarry** - Produces: Stone

**Common Attributes:**
- Production rate (resources per cycle)
- Upgrade levels
- Maintenance cost

### 2. Processing Buildings
Convert raw materials into refined products.

**Examples:**
- **Smelting Station** - Converts: Iron Ore → Iron Ingot, Copper Ore → Copper Ingot
- **Sawmill** - Converts: Wood Logs → Wood Planks
- **Coal Power Plant** - Converts: Coal → Energy
- **Forge** - Converts: Iron Ingot → Iron Plates

**Common Attributes:**
- Input resources required
- Output resources produced
- Processing speed
- Efficiency multiplier

### 3. Storage Buildings (Future)
Store excess resources.

**Examples:**
- **Warehouse** - Increases storage capacity

### 4. Upgrade Buildings (Future)
Improve efficiency of other buildings.

**Examples:**
- **Tool Workshop** - Increases production speed

## Building Data Structure

```lua
Building = {
    id = "iron_mine_01",
    name = "Iron Mine",
    type = "RawMaterialProducer",
    category = "Mining",
    price = 500,
    
    -- Production stats
    produces = {
        iron_ore = 10  -- 10 iron ore per production cycle
    },
    
    -- Building stats
    level = 1,
    maxLevel = 5,
    
    -- Visual
    icon = "⛏️",
    color = Color3.fromRGB(180, 100, 80),
    
    -- Grid requirements
    size = { width = 1, height = 1 },
    
    -- Costs to upgrade
    upgradeCost = {
        level2 = { gold = 200 },
        level3 = { gold = 500 },
    }
}
```

## Building Manager

The BuildingManager handles:
- Available buildings for the current industry
- Building definitions and stats
- Purchase/placement logic
- Upgrade system
- Building interactions

## Industry-Specific Buildings

Each industry type has its own set of available buildings:

**Coal Mining Industry:**
- Coal Mine (Basic)
- Deep Coal Mine (Advanced)
- Coal Power Plant (Processing)

**Iron Mining Industry:**
- Iron Mine (Basic)
- Deep Iron Mine (Advanced)
- Smelting Station (Processing)
- Forge (Processing)

**Copper Mining Industry:**
- Copper Mine (Basic)
- Deep Copper Mine (Advanced)
- Wire Factory (Processing)

**Logging Industry:**
- Lumberjack Station (Basic)
- Advanced Logging (Advanced)
- Sawmill (Processing)
- Furniture Workshop (Processing)

## Building Placement

1. Click "Buildings" panel
2. Select building type
3. Select cell on grid
4. Validate (have enough money, cell is empty, requirements met)
5. Place building
6. Deduct cost from money
7. Update grid cell state

## Building Upgrades

1. Click placed building
2. View upgrade options
3. Pay upgrade cost
4. Increase building level
5. Update production rates

## Building States

- **Empty** - No building
- **Constructing** - Being built (timer)
- **Active** - Producing resources
- **Maintenance** - Needs repair
- **Upgrading** - Being upgraded (timer)
- **Idle** - No resources to produce

## Grid Cell System

Each grid cell stores:
```lua
Cell = {
    id = 0,
    row = 0,
    col = 0,
    
    -- Building info
    building = nil or Building,  -- nil if empty
    
    -- Visual state
    isEmpty = true,
    isSelectable = true
}
```

## Production Cycles

Buildings produce resources on cycles:
- **Basic mines**: 10 seconds per cycle
- **Advanced mines**: 8 seconds per cycle
- **Processing**: 5 seconds per cycle

Resources automatically add to player's inventory (stored in DataStore save).

## Building Prices

Starting prices (balanced):
- Basic producer: 500 gold
- Advanced producer: 1500 gold
- Basic processor: 1000 gold
- Advanced processor: 2500 gold

## Future Features

- Building chains (one building feeds another)
- Automated production lines
- Global upgrades (affects all buildings)
- Building decor/customization
- Energy system (buildings need power)
- Worker assignment (NPCs to increase efficiency)

