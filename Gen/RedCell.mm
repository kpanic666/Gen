//
//  RedCell.m
//  Gen
//
//  Created by Andrey Korikov on 18.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "RedCell.h"

@implementation RedCell

- (id)initWithWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name withPinAtPos:(CGPoint)pinPos
{
    if ((self = [super initWithType:kEnemyTypeRedCell withWorld:theWorld position:pos name:name])) {
        
        body->SetType(b2_dynamicBody);
        body->SetUserData(self);
        
        // make pin for the MetalCell body. Need for the revolute joint
        _pin = [[[MetalCellPin alloc] initWithWorld:theWorld atLocation:pinPos] autorelease];
        // Rev Joint creation
        b2RevoluteJointDef revJointDef;
        revJointDef.bodyA = body;
        revJointDef.bodyB = _pin.body;
        revJointDef.localAnchorA = body->GetLocalPoint(_pin.body->GetPosition());
        revJointDef.localAnchorB.SetZero();
        pinJoint = (b2RevoluteJoint*) world->CreateJoint(&revJointDef);
        
        // Set filter properties
        b2Filter filter;
        for (b2Fixture *f = body->GetFixtureList(); f; f = f->GetNext())
        {
            filter = f->GetFilterData();
            filter.categoryBits = kRedCellFilterCategory;
            f->SetFilterData(filter);
        }
        
        initPosition = ccp(pos.x - self.textureRect.size.width/2, pos.y - self.textureRect.size.height/2);

    }
    return self;
}

- (id)initWithWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name
{
    if ((self = [super initWithType:kEnemyTypeRedCell withWorld:theWorld position:pos name:name])) {
        
        // make the body static
        body->SetType(b2_staticBody);
        body->SetUserData(self);
        
        // Set filter properties
        b2Filter filter;
        for (b2Fixture *f = body->GetFixtureList(); f; f = f->GetNext())
        {
            filter = f->GetFilterData();
            filter.categoryBits = kRedCellFilterCategory;
            f->SetFilterData(filter);
        }
        
        initPosition = ccp(pos.x - self.textureRect.size.width/2, pos.y - self.textureRect.size.height/2);
    }
    return self;
}

- (void)setMotorSpeed:(float32)motorSpeed
{
    if (pinJoint != NULL) {
        if (pinJoint->IsMotorEnabled()) {
            pinJoint->SetMotorSpeed(motorSpeed);
        }
        else {
            pinJoint->SetMaxMotorTorque(1000);
            pinJoint->SetMotorSpeed(motorSpeed);
            pinJoint->EnableMotor(YES);
        }
    }
}

+ (id) redCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    return [[[self alloc] initWithWorld:theWorld position:pos name:name] autorelease];
}

+ (id) redCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name withPinAtPos:(CGPoint)pinPos
{
    return [[[self alloc] initWithWorld:theWorld position:pos name:name withPinAtPos:pinPos] autorelease];
}

- (int) getWeaponDamage {
    
    return kRedCellDamage;
}

- (NSString *)getRandomParticleName
{
    // Set Random texture
    return [NSString stringWithFormat:@"bone%i.png", (int)random() % 2 + 1];
}

@end
