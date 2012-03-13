//
//  GameCharacter.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "GameCharacter.h"

@implementation GameCharacter

@synthesize characterHealth;
@synthesize characterState;

- (int)getWeaponDamage {
    return 0;
}

- (void)checkAndClampSpritePosition {
    CGPoint currentSpritePosition = [self position];
    CGSize levelSize = [[GameManager sharedGameManager] getDimensionsOfCurrentScene];
    float xOffset;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        xOffset = 30.0f;
    } else {
        xOffset = 24.0;
    }
    
    if (currentSpritePosition.x < xOffset) {
        [self setPosition:ccp(xOffset, currentSpritePosition.y)];
    } else if (currentSpritePosition.x > (levelSize.width - xOffset)) {
        [self setPosition:ccp((levelSize.width - xOffset), currentSpritePosition.y)];
    }
}

@end
