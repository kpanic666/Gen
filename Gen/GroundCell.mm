//
//  GroundCell.m
//  Gen
//
//  Created by Andrey Korikov on 10.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "GroundCell.h"

@implementation GroundCell

- (id)initWithWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name
{
    if ((self = [super initWithShape:name inWorld:theWorld])) {
        gameObjectType = kGroundType;
        characterState = kStateIdle;
        
        // set the body position
        body->SetTransform([Helper toMeters:pos], 0.0f);
        
        // make the body static
        body->SetType(b2_staticBody);
    }
    return self;
}

+ (id) groundCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    return [[[self alloc] initWithWorld:theWorld position:pos name:name] autorelease];
}

@end
