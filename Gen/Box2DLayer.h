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
#import "GroundCell.h"
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
    Box2DUILayer *uiLayer;
    ContactListener *contactListener;
	GLESDebugDraw *m_debugDraw;
    CCSpriteBatchNode *sceneSpriteBatchNode;
    NSMutableArray *bodiesToDestroy;
    ParentCell *parentCell;
    ExitCell *exitCell;
    bool gameOver;
}

- (id)initWithBox2DUILayer:(Box2DUILayer*)box2DUILayer;
- (void)markBodyForDestruction:(Box2DSprite*)obj;
- (void)destroyBodies;
- (ChildCell*)createChildCellAtLocation:(CGPoint)location;

@end
