//
//  ChildCell.h
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DSprite.h"

@interface ChildCell : Box2DSprite
{
    b2World *world;
}

- (id)initWithWorld:(b2World*)theWorld atLocation:(CGPoint)location;

@end
