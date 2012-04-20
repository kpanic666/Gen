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
        [spriteB changeState:kStateBeforeSoul];
    }
    else if (spriteB.gameObjectType == kExitCellType) {
        [spriteA changeState:kStateBeforeSoul];
    }
    
    // Обработка столкновений MagneticCell с ChildCell
    // isActive=False для ChildCells - если в зоне дейтсвия магнита
    if (spriteA.gameObjectType == kEnemyTypeMagneticCell) {
        spriteB.magneticCount += 1;
    }
    else if (spriteB.gameObjectType == kEnemyTypeMagneticCell) {
        spriteA.magneticCount += 1;
    }
    
    // Обработка столкновениий RedCell с ChildCell
    if (spriteA.gameObjectType == kEnemyTypeRedCell && spriteB.characterState != kStateDead) {
        [spriteB changeState:kStateTakingDamage];
    }
    else if (spriteB.gameObjectType == kEnemyTypeRedCell && spriteA.characterState != kStateDead) {
        [spriteA changeState:kStateTakingDamage];
    }
}

void ContactListener::EndContact(b2Contact* contact)
{
    Box2DSprite *spriteA = (Box2DSprite*)contact->GetFixtureA()->GetBody()->GetUserData();
    Box2DSprite *spriteB = (Box2DSprite*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    // Обработка столкновениий сенсора ParentCell с ChildCell
    if (spriteA.gameObjectType == kParentCellType && spriteB.characterState == kStateConnected) {
        [spriteB changeState:kStateDisconnecting];
    }
    else if (spriteB.gameObjectType == kParentCellType && spriteA.characterState == kStateConnected) {
        [spriteA changeState:kStateDisconnecting];
    }
    
    // Обработка столкновений MagneticCell с ChildCell
    // isActive=True для ChildCells - если выходят из зоны дейтсвия магнита
    if (spriteA.gameObjectType == kEnemyTypeMagneticCell) {
        spriteB.magneticCount -= 1;
    }
    else if (spriteB.gameObjectType == kEnemyTypeMagneticCell) {
        spriteA.magneticCount -= 1;
    }
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
    Box2DSprite *spriteA = (Box2DSprite*)contact->GetFixtureA()->GetBody()->GetUserData();
    Box2DSprite *spriteB = (Box2DSprite*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    // Обработка столкновениий ExitCell с ChildCell. Позволяет клеткам залетать с размаху в выход
    if (spriteA.gameObjectType == kExitCellType) {
        contact->SetEnabled(false);
    }
    else if (spriteB.gameObjectType == kExitCellType) {
        contact->SetEnabled(false);
    }
    
    // Обработка столкновениий RedCell с ChildCell. Позволяет клеткам быстро дохнуть, а не толпиться друг за другом
//    if (spriteA.gameObjectType == kEnemyTypeRedCell) {
//        contact->SetEnabled(false);
//    }
//    else if (spriteB.gameObjectType == kEnemyTypeRedCell) {
//        contact->SetEnabled(false);
//    }
}