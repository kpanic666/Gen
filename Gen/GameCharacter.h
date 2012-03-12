//
//  GameCharacter.h
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"

@interface GameCharacter : GameObject {
    int characterHealth;
    CharacterStates characterState;
}

@property (readwrite) int characterHealth;
@property (readwrite) CharacterStates characterState;

- (void)checkAndClampSpritePosition;
- (int)getWeaponDamage;

@end
