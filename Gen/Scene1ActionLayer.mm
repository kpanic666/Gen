//
//  Scene1ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 23.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene1ActionLayer.h"
#import "ChildCell.h"
#import "ParentCell.h"
#import "Helper.h"
#import "ExitCell.h"
#import "MagneticCell.h"
#import "GroundCell.h"
#import "RedCell.h"
#import "GB2ShapeCache.h"

@implementation Scene1ActionLayer

- (void)createChildCellAtLocation:(CGPoint)location
{
    ChildCell *childCell = [[[ChildCell alloc] initWithWorld:world atLocation:location] autorelease];
    [sceneSpriteBatchNode addChild:childCell z:1 tag:kChildCellSpriteTagValue];
    [GameManager sharedGameManager].numOfTotalCells++;
}

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CGPoint screenCenter = ccp(screenSize.width * 0.5, screenSize.height * 0.5);
        
        // pre load the sprite frames from the texture atlas
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        [self addChild:sceneSpriteBatchNode];
        
        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene1bodies.plist"];
        
        // add background
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background1.png"];
        [background setPosition:screenCenter];
        [self addChild:background z:-2];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100)] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:ccp(screenSize.width*0.9, screenSize.height*0.15)] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add ChildCells
        for (int i = 0; i < kChildCellStartNum; i++) {
            [self createChildCellAtLocation:ccp(screenCenter.x + i * 5, screenCenter.y + i * 5)];
        }
        
        // add MagneticCells
        MagneticCell *magneticCell1 = [[[MagneticCell alloc] initWithWorld:world atLocation:ccp(screenSize.width*0.3, screenSize.height*0.3)] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell1 z:-1];
        
        // add GroundCells
        GroundCell *groundCell1 = [GroundCell groundCellInWorld:world position:ccp(screenSize.width*0.65, screenSize.height*0.08) name:@"groundCell1"];
        GroundCell *groundCell2 = [GroundCell groundCellInWorld:world position:ccp(screenSize.width*0.25, screenSize.height*0.7) name:@"groundCell2"];
        [self addChild:groundCell1 z:-1];
        [self addChild:groundCell2 z:-1];
        
        // add RedCells
        RedCell *redCell1 = [RedCell redCellInWorld:world position:ccp(screenSize.width*0.87, screenSize.height*0.45) name:@"redCell1"];
        [self addChild:redCell1 z:-1];
        
        // Play background Music
//        [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_1];
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
    
    // Отображаем главную ячейку под пальцем игрока и она начинает притягивать
    [parentCell changeBodyPosition:locationWorld];
    [parentCell changeState:kStateTraveling];
    return TRUE;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [Helper locationFromTouch:touch];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    if ([parentCell characterState] == kStateTraveling) {
        [parentCell changeBodyPosition:locationWorld];
    }    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{    
    // Прячем главную клетку и перестаем притягивать
    [parentCell changeState:kStateIdle];
}

- (void)dealloc
{
    exitCell = nil;
    parentCell = nil;
    [super dealloc];
}

- (void)draw
{
    [super draw];
    
    // Draw lines for distance joints between ChildCell and ParentCell
    [parentCell drawDisJoints];
    
    // Рисуем линии от магнитов к ChildCells
    for (MagneticCell *magneticCell in [sceneSpriteBatchNode children])
    {
        if (magneticCell.gameObjectType == kEnemyTypeMagneticCell)
        {
            [magneticCell drawMagnetForces];
        }
    }
    
    
}

@end
