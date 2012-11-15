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
    b2Fixture *fixtureA = contact->GetFixtureA();
    b2Fixture *fixtureB = contact->GetFixtureB();
    
    // Обработка столкновениий сенсора ParentCell с ChildCell
    if (spriteA.gameObjectType == kParentCellType && spriteA.characterState == kStateTraveling) {
        [spriteB changeState:kStateConnecting];
    }
    else if (spriteB.gameObjectType == kParentCellType && spriteB.characterState == kStateTraveling) {
        [spriteA changeState:kStateConnecting];
    }
    
    // Обработка столкновениий ExitCell с ChildCell
    if (spriteA.gameObjectType == kExitCellType) {
        if (fixtureA->IsSensor()) {
            [spriteA changeState:kStateOpenedMouth];
        }
        else
        {
            [spriteA changeState:kStateEating];
            [spriteB changeState:kStateBeforeSoul];
        }
    }
    else if (spriteB.gameObjectType == kExitCellType) {
        if (fixtureB->IsSensor()) {
            [spriteB changeState:kStateOpenedMouth];
        }
        else
        {
            [spriteB changeState:kStateEating];
            [spriteA changeState:kStateBeforeSoul];
        }
    }
    
    // Обработка столкновениий GroundCell с ChildCell
    if (spriteA.gameObjectType == kGroundType && spriteB.gameObjectType == kChildCellType) {
        PLAYSOUNDEFFECT(@"GROUNDCELL_BUMPED");
    }
    else if (spriteB.gameObjectType == kGroundType && spriteA.gameObjectType == kChildCellType) {
        PLAYSOUNDEFFECT(@"GROUNDCELL_BUMPED");
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
    if (spriteA.gameObjectType == kEnemyTypeRedCell && (spriteB.gameObjectType == kChildCellType || spriteB.gameObjectType == kEnemyTypeBomb)) {
        [spriteB changeState:kStateTakingDamage];
    }
    else if (spriteB.gameObjectType == kEnemyTypeRedCell && (spriteA.gameObjectType == kChildCellType || spriteA.gameObjectType == kEnemyTypeBomb)) {
        [spriteA changeState:kStateTakingDamage];
    }
    
    // Обработка столкновений BubbleCell с ChildCell
    if ((spriteA.gameObjectType == kEnemyTypeBubble && spriteA.characterState == kStateIdle) && spriteB.gameObjectType == kChildCellType) {
        [spriteB changeState:kStateBubbling];
        [spriteA changeState:kStateTraveling];
    }
    else if ((spriteB.gameObjectType == kEnemyTypeBubble && spriteB.characterState == kStateIdle) && spriteA.gameObjectType == kChildCellType) {
        [spriteA changeState:kStateBubbling];
        [spriteB changeState:kStateTraveling];
    }
}

void ContactListener::EndContact(b2Contact* contact)
{
    Box2DSprite *spriteA = (Box2DSprite*)contact->GetFixtureA()->GetBody()->GetUserData();
    Box2DSprite *spriteB = (Box2DSprite*)contact->GetFixtureB()->GetBody()->GetUserData();
    b2Fixture *fixtureA = contact->GetFixtureA();
    b2Fixture *fixtureB = contact->GetFixtureB();
    
    // Обработка столкновениий сенсора ParentCell с ChildCell
    if (spriteA.gameObjectType == kParentCellType && spriteB.characterState == kStateConnected) {
        [spriteB changeState:kStateDisconnecting];
    }
    else if (spriteB.gameObjectType == kParentCellType && spriteA.characterState == kStateConnected) {
        [spriteA changeState:kStateDisconnecting];
    }
    
    // Обработка столкновениий ExitCell с ChildCell
    if (spriteA.gameObjectType == kExitCellType && fixtureA->IsSensor() && spriteB.characterState != kStateBeforeSoul) {
        [spriteA changeState:kStateCloseMouth];
    }
    else if (spriteB.gameObjectType == kExitCellType && fixtureB->IsSensor() && spriteA.characterState != kStateBeforeSoul) {
        [spriteB changeState:kStateCloseMouth];
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
}