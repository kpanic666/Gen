//
//  CommonProtocols.h
//  Gen
//
//  Created by Andrey Korikov on 17.01.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

typedef enum {
    kStateSpawning,
    kStateIdle,
    kStateWalking,
    kStateBreathing,
    kStateTakingDamage,
    kStateDead,
    kStateTraveling
} CharacterStates;

typedef enum {
    kObjectTypeNone,
    kEnemyTypeRedCell,
    kEnemyTypeMagneticCell,
    kEnemyTypeRepulsiveCell,
    kParentCellType,
    kChildCellType,
    kGroundType
} GameObjectType;

@protocol GameplayLayerDelegate

- (void)createObjectOfType:(GameObjectType)objectType 
                            withHealth:(int)initialHealth
                            atLocation:(CGPoint)spawnLocation
                            withZValue:(int)ZValue;

@end
