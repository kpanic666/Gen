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

@interface Box2DLayer : CCLayer
{
    b2World *world;
	GLESDebugDraw *m_debugDraw;
    b2Body *groundBody;
    b2MouseJoint *mouseJoint;
    CCSpriteBatchNode *sceneSpriteBatchNode;
    b2Body *parentCellBody;
    b2Body *exitCellBody;
    BOOL hasWon;
}

+(CCScene *) scene;

@end
