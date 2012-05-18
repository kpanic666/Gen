//
//  CommonProtocols.h
//  Gen
//
//  Created by Andrey Korikov on 17.01.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

typedef enum {
    kStateSpawning,         // Начальное состояние для всех объектов
    kStateIdle,             // ParentCell without touch, ChildCell вне радиуса действия ParentCell
    kStateBreathing,
    kStateTakingDamage,     // ChildCell при соприкосновении с RedCell
    kStateDead,             // ChildCell при смерти
    kStateTraveling,        // ParentCell при нажатии на экран
    kStateConnecting,       // ChildCell при входе в зону сенсора ParentCell
    kStateConnected,        // ChildCell в зоне действия сенсора, уже с задействованными джойнтами
    kStateDisconnecting,    // ChildCell при выходе из зоны сенсора. Следующее состояние kStateIdle уже без джоинтов
    kStateBeforeSoul,       // ChildCell при соприкосновении с выходом на мгновение принимает это состояние чтобы отбросить джоинты
    kStateSoul              // ChildCell которые добрались до выхода и плавают в нем, но не выходят
} CharacterStates;

typedef enum {
    kObjectTypeNone,
    kEnemyTypeRedCell,
    kEnemyTypeMagneticCell,
    kEnemyTypeRepulsiveCell,
    kParentCellType,
    kChildCellType,
    kGroundType,
    kExitCellType,
    kMetalType,
    kMetalPinType
} GameObjectType;
 