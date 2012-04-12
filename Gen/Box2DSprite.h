//
//  Box2DSprite.h
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "GameCharacter.h"
#import "Box2D.h"
#import "GB2ShapeCache.h"
#import "Helper.h"

@interface Box2DSprite : GameCharacter {
    b2Body *body;
    b2World *world;
    BOOL markedForDestruction;
}

@property (assign) b2Body *body;
@property (readwrite, assign) BOOL markedForDestruction;

- (id)initWithWorld:(b2World*)theWorld atLocation:(CGPoint)location;
- (id)initWithShape:(NSString*)shapeName inWorld:(b2World*)theWorld;
- (void)setBodyShape:(NSString*)shapeName;
- (void)createBodyAtLocation:(CGPoint)location;

@end
