//
//  ChildCell.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ChildCell.h"
#import "Box2DHelpers.h"

@implementation ChildCell

- (void)createBodyAtLocation:(CGPoint)location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    b2FixtureDef fixtureDef;
    b2CircleShape shape;
    shape.m_radius = self.contentSize.width * 0.5f / PTM_RATIO;
    fixtureDef.shape = &shape;
    fixtureDef.density = 1.0;
    fixtureDef.friction = 0.5;
    fixtureDef.restitution = 0.5;
    body->CreateFixture(&fixtureDef);
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    if (characterState == kStateDead) {
        return;
    }
    if ((characterState == kStateTakingDamage) && ([self numberOfRunningActions] > 0)) {
        return;
    }
    if ([self numberOfRunningActions] == 0) {
        if (characterHealth <= 0) {
            [self changeState:kStateDead];
        } else {
            [self changeState:kStateIdle];
        }
    }
    if (isBodyCollidingWithObjectType(body, kEnemyTypeRedCell)) {
        [self changeState:kStateTakingDamage];
    }
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init])) {
        world = theWorld;
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"childcell_idle.png"]];
        gameObjectType = kChildCellType;
//        characterState = kStateSpawning;
        characterHealth = kChildCellHealth;
        [self createBodyAtLocation:location];
    }
    return self;
}

- (void)playHitEffect
{
//    int soundToPlay = random() % 2;
//    if (soundToPlay == 0) {
//        PLAYSOUNDEFFECT(@"VIKING_HIT_1");
//    } else {
//        PLAYSOUNDEFFECT(@"VIKING_HIT_2");
//    }

}

- (void)changeState:(CharacterStates)newState
{
    if (characterState == newState) {
        return;
    }
    
    [self stopAllActions];
    [self setCharacterState:newState];
    
    switch (newState) {
        case kStateTakingDamage:
        {
            [self playHitEffect];
            characterHealth -= kRedCellDamage;
            CCAction *blink = [CCBlink actionWithDuration:1.0 blinks:3.0];
            [self runAction:blink];
            break;
        }
            
        case kStateTraveling:
        {
            // Нужно менять вид клетки. Это состояние принимается клеткой, когда она попадает в зону влияния главной клетки
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"childcell_travelling.png"]];
            break;
        }
            
        case kStateIdle:
        {
            // Меняется внешний вид клетки на обычный. В этом состояний объект может продолжать двигаться по инерции,
            // но на нее уже не влияет игрок.
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"childcell_idle.png"]];
            break;
        }
            
        case kStateDead:
            // Клетка умирает от первого же прикосновения
            break;
            
        default:
            break;
    }
}

- (BOOL)mouseJointBegan
{
    return TRUE;
}

@end
