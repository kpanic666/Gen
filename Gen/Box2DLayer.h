//
//  Box2DLayer.h
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//  Base class for almost all levels in the game. Setup world,
//  updates and many other things.

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "Constants.h"
#import "ContactListener.h"
#import "ChildCell.h"
#import "BombCell.h"
#import "MovingWall.h"
#import "BubbleCell.h"
#import "GroundCell.h"
#import "MetalCell.h"
#import "RedCell.h"
#import "ParentCell.h"
#import "Helper.h"
#import "ExitCell.h"
#import "MagneticCell.h"
#import "GB2ShapeCache.h"
#import "Box2DUILayer.h"
#import "CompleteLevelLayer.h"

@class Box2DSprite;

@interface Box2DLayer : CCLayer
{
    CGSize screenSize;
    b2World *world;
    b2Body *groundBody;
    Box2DUILayer *uiLayer;
    ContactListener *contactListener;
	GLESDebugDraw *m_debugDraw;
    CCSpriteBatchNode *sceneSpriteBatchNode;
    CCSpriteBatchNode *decorsBatchNode;
    CCSpriteBatchNode *waterBatchNode;
    CCSpriteBatchNode *superpowerBatchNode;
    CCSpriteBatchNode *watershieldsBatchNode;
    NSMutableArray *bodiesToDestroy;
    ParentCell *parentCell;
    ExitCell *exitCell;
    bool gameOver;
    CCParticleSystemQuad *psPlankton;
    float leftmostXPosOfWave;
    float rightmostXPosOfWave;
}

- (id)initWithBox2DUILayer:(Box2DUILayer*)box2DUILayer;
- (void)markBodyForDestruction:(Box2DSprite*)obj;
- (void)destroyBodies;
- (void)setFlowing:(b2Vec2)flowingCurse;

// Конструкторы игровых объектов
- (CCSprite*)createDecorWithSpriteFrameName:(NSString*)name location:(CGPoint)location;
- (ChildCell*)createChildCellAtLocation:(CGPoint)location;
- (ExitCell*)createExitCellAtLocation:(CGPoint)location;
- (BombCell*)createBombCellAtLocation:(CGPoint)location;
- (MagneticCell*)createMagneticCellAtLocation:(CGPoint)location;
- (BubbleCell*)createBubbleCellAtLocation:(CGPoint)location;
- (MovingWall*)createMovingWallAtLocation:(CGPoint)location vertical:(BOOL)vertical;
- (MovingWall*)createMovingWallAtLocation:(CGPoint)location vertical:(BOOL)vertical negOffset:(float32)negOffset posOffset:(float32)posOffset speed:(float32)speed;
- (GroundCell*)createGroundCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name;
- (MetalCell*)createMetalCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name;
- (MetalCell*)createMetalCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name withPinAtPos:(CGPoint)pinPos;
- (RedCell*)createRedCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name;
- (RedCell*)createRedCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name withPinAtPos:(CGPoint)pinPos;

// Активация суперсилы на childcells
- (void)activateWaterShields;

- (void)showTipsElement:(CCNode*)element delay:(float)delay;
- (void)hideTipsElement:(CCNode*)element delay:(float)delay;

@end
