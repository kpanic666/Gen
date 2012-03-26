//
//  CustomContactListener.m
//  Gen
//
//  Created by Andrey Korikov on 19.03.12.
//  Copyright 2012 Atom Games. All rights reserved.
//

#import "ContactListener.h"
#import "cocos2d.h"
#import "Box2DSprite.h"

void ContactListener::BeginContact(b2Contact* contact)
{
    Box2DSprite *spriteA = (Box2DSprite*)contact->GetFixtureA()->GetBody()->GetUserData();
    Box2DSprite *spriteB = (Box2DSprite*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    // Обработка столкновениий сенсора ParentCell с ChildCell
    if (spriteA.gameObjectType == kParentCellType) {
        [spriteB changeState:kStateConnecting];
    }
    else if (spriteB.gameObjectType == kParentCellType) {
        [spriteA changeState:kStateConnecting];
    }
    
    // Обработка столкновениий ExitCell с ChildCell
    if (spriteA.gameObjectType == kExitCellType) {
        [spriteB changeState:kStateSoul];
    }
    else if (spriteB.gameObjectType == kExitCellType) {
        [spriteA changeState:kStateSoul];
    }
}

void ContactListener::EndContact(b2Contact* contact)
{
    Box2DSprite *spriteA = (Box2DSprite*)contact->GetFixtureA()->GetBody()->GetUserData();
    Box2DSprite *spriteB = (Box2DSprite*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    // Обработка столкновениий сенсора ParentCell с ChildCell
    if (spriteA.gameObjectType == kParentCellType) {
        [spriteB changeState:kStateDisconnecting];
    }
    else if (spriteB.gameObjectType == kParentCellType) {
        [spriteA changeState:kStateDisconnecting];
    }
}