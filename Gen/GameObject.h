//
//  GameObject.h
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import "CommonProtocols.h"
#import "GameManager.h"

@interface GameObject : CCSprite {
    BOOL isActive;
    GameObjectType gameObjectType;
}

@property (readwrite) BOOL isActive;
@property (readwrite) GameObjectType gameObjectType;

- (void)changeState:(CharacterStates)newState;
- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects;
- (CGRect)adjustedBoudingBox;
- (CCAnimation *)loadPlistForAnimationWithName:(NSString*)animationName andClassName:(NSString*)className;

@end
