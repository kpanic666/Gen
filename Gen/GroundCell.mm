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
    if ((self = [super initWithType:kGroundType withWorld:theWorld position:pos name:name])) {
        
        // make the body static
        body->SetType(b2_staticBody);
        body->SetUserData(self);
        initPosition = ccp(pos.x - self.textureRect.size.width/2, pos.y - self.textureRect.size.height/2);
    }
    return self;
}

+ (id)groundCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    return [[[self alloc] initWithWorld:theWorld position:pos name:name] autorelease];
}

- (NSString *)getRandomParticleName
{
    // Set Random texture
    return [NSString stringWithFormat:@"groundcell_particle%i.png", (int)random() % 2 + 1];
}

@end
