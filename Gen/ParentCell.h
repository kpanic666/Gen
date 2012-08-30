//
//  ParentCell.h
//  Gen
//
//  Created by Andrey Korikov on 15.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DSprite.h"

@interface ParentCell : Box2DSprite
{
    NSMutableArray *disJointsToDestroy;
    float radius;
}

- (void)changeBodyPosition:(b2Vec2)position;
- (void)drawDisJoints;
- (void)drawSensorField;

@end
