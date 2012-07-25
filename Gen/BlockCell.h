//
//  Block.h
//  Gen
//  Общий класс для groundCell, RedCell, MetalCell.
//  Created by Andrey Korikov on 18.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DSprite.h"

@interface BlockCell : Box2DSprite
{
    CGPoint initPosition;
}

- (id) initWithType:(GameObjectType)objectType withWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name;
- (void) initWithShape:(NSString*)shapeName inWorld:(b2World*)theWorld;
- (void) setBodyShape:(NSString*)shapeName;
- (void) createParticles;
- (NSString *)getRandomParticleName;

@end
