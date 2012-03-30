//
//  Scene1.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright 2012 Atom Games. All rights reserved.
//

#import "Scene1.h"
#import "GameManager.h"
#import "ChildCell.h"
#import "ParentCell.h"
#import "Helper.h"
#import "SimpleQueryCallback.h"
#import "ExitCell.h"


@implementation Scene1

- (void)createChildCellAtLocation:(CGPoint)location
{
    ChildCell *childCell = [[[ChildCell alloc] initWithWorld:world atLocation:location] autorelease];
    [childCellsArray addObject:childCell];
    [sceneSpriteBatchNode addChild:childCell z:1 tag:kChildCellSpriteTagValue];
}

- (id)init
{
    if ((self = [super init])) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CGPoint screenCenter = ccp(screenSize.width * 0.5, screenSize.height * 0.5);
    
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.png"];
        [self addChild:sceneSpriteBatchNode];
        
        // add background
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background1.png"];
        [background setPosition:screenCenter];
        [self addChild:background z:-2];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100)] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:ccp(screenSize.width*0.9, screenSize.height*0.1)] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add ChildCells
        for (int i = 0; i < kChildCellStartNum; i++) {
            [self createChildCellAtLocation:ccp(screenCenter.x + i * 5, screenCenter.y + i * 5)];
        }
    }
    return self;
}

#pragma mark Touch Events

- (void)registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //Add a new body/atlas sprite at the touched location
    CGPoint touchLocation = [Helper locationFromTouch:touch];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    
    b2AABB aabb;
    b2Vec2 delta = b2Vec2(1.0/PTM_RATIO, 1.0/PTM_RATIO);
    aabb.lowerBound = locationWorld - delta;
    aabb.upperBound = locationWorld + delta;
    SimpleQueryCallback callback(locationWorld);
    world->QueryAABB(&callback, aabb);
    
    if (callback.fixtureFound) {
        b2Body *body = callback.fixtureFound->GetBody();
        Box2DSprite *sprite = (Box2DSprite*) body->GetUserData();
        if (sprite == NULL) {
            return FALSE;
        }
        if (![sprite mouseJointBegan]) {
            return FALSE;
        }
        b2MouseJointDef mouseJointDef;
        mouseJointDef.bodyA = groundBody;
        mouseJointDef.bodyB = body;
        mouseJointDef.target = locationWorld;
        mouseJointDef.maxForce = 100 * body->GetMass();
        mouseJointDef.collideConnected = true;
        
        mouseJoint = (b2MouseJoint*) world->CreateJoint(&mouseJointDef);
        body->SetAwake(true);
        return YES;
    } else {
//        [self createChildCellAtLocation:touchLocation];
        // Отображаем главную ячейку под пальцем игрока и она начинает притягивать
        [parentCell changeBodyPosition:locationWorld];
        [parentCell changeState:kStateTraveling];
        return TRUE;
    }
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [Helper locationFromTouch:touch];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    if (mouseJoint) {
        mouseJoint->SetTarget(locationWorld);
    }
    if ([parentCell characterState] == kStateTraveling) {
        [parentCell changeBodyPosition:locationWorld];
    }
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (mouseJoint) {
        world->DestroyJoint(mouseJoint);
        mouseJoint = NULL;
    }
    
    // Прячем главную клетку и перестаем притягивать
    [parentCell changeState:kStateIdle];
}

- (void)dealloc
{
    exitCell = nil;
    childCellsArray = nil;
    parentCell = nil;
    [super dealloc];
}

- (void)draw
{
    [super draw];
    
    // Draw lines for distance joints between ChildCell and ParentCell
    [parentCell drawDisJoints];
}

@end
