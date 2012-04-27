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

@class Box2DSprite;
@class Box2DUILayer;

@interface Box2DLayer : CCLayer
{
    b2World *world;
    Box2DUILayer *uiLayer;
    ContactListener *contactListener;
	GLESDebugDraw *m_debugDraw;
    CCSpriteBatchNode *sceneSpriteBatchNode;
    NSMutableArray *bodiesToDestroy;
}

- (id)initWithBox2DUILayer:(Box2DUILayer*)box2DUILayer;
- (void)markBodyForDestruction:(Box2DSprite*)obj;
- (void)destroyBodies;

@end
