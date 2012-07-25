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
        
        // make the body static
        body->SetType(b2_staticBody);
        body->SetUserData(self);
        initPosition = ccp(pos.x - self.textureRect.size.width/2, pos.y - self.textureRect.size.height/2);
    }
    return self;
}

+ (id) redCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    return [[[self alloc] initWithWorld:theWorld position:pos name:name] autorelease];
}

- (int) getWeaponDamage {
    
    return kRedCellDamage;
}

- (NSString *)getRandomParticleName
{
    // Set Random texture
    return [NSString stringWithFormat:@"redcell_particle%d.png", random() % 2 + 1];
}

@end
