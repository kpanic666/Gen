//
//  MetalCell.m
//  Gen
//
//  Created by Andrey Korikov on 19.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "MetalCell.h"

@implementation MetalCell

- (id)initWithWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name
{
    if ((self = [super initWithType:kMetalType withWorld:theWorld position:pos name:name])) {
        
        // make the body static
        body->SetType(b2_dynamicBody);
        body->SetUserData(self);
    }
    return self;
}

+ (id) metalCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    return [[[self alloc] initWithWorld:theWorld position:pos name:name] autorelease];
}

@end
