//
//  RedCell.m
//  Gen
//
//  Created by Andrey Korikov on 18.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "RedCell.h"

@implementation RedCell

- (id)initWithWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name
{
    if ((self = [super initWithType:kEnemyTypeRedCell withWorld:theWorld position:pos name:name])) {
        
        body->SetUserData(self);
    }
    return self;
}

+ (id) redCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    return [[[self alloc] initWithWorld:theWorld position:pos name:name] autorelease];
}

@end
