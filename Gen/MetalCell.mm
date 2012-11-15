//
//  MetalCell.m
//  Gen
//
//  Created by Andrey Korikov on 19.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "MetalCell.h"

@implementation MetalCell

- (id)initWithWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name withPinAtPos:(CGPoint)pinPos
{
    if ((self = [super initWithType:kMetalType withWorld:theWorld position:pos name:name])) {
        
        body->SetType(b2_dynamicBody);
        body->SetUserData(self);
        // Set filter properties
        b2Filter filter;
        for (b2Fixture *f = body->GetFixtureList(); f; f = f->GetNext())
        {
            filter = f->GetFilterData();
            filter.categoryBits = kMetalCellFilterCategory;
            f->SetFilterData(filter);
        }
        
        // make pin for the MetalCell body. Need for the revolute joint
        self.pin = [[[MetalCellPin alloc] initWithWorld:theWorld atLocation:pinPos] autorelease];
        // Rev Joint creation
        b2RevoluteJointDef revJointDef;
        revJointDef.bodyA = body;
        revJointDef.bodyB = _pin.body;
        revJointDef.localAnchorA = body->GetLocalPoint(_pin.body->GetPosition());
        revJointDef.localAnchorB.SetZero();
        self.pinJoint = (b2RevoluteJoint*) world->CreateJoint(&revJointDef);
    }
    return self;
}

- (id)initWithWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name
{
    if ((self = [super initWithType:kMetalType withWorld:theWorld position:pos name:name])) {
        
        body->SetType(b2_dynamicBody);
        body->SetUserData(self);
        // Set filter properties
        b2Filter filter;
        for (b2Fixture *f = body->GetFixtureList(); f; f = f->GetNext())
        {
            filter = f->GetFilterData();
            filter.categoryBits = kMetalCellFilterCategory;
            f->SetFilterData(filter);
        }
    }
    return self;
}

- (void)setMotorSpeed:(float32)motorSpeed
{
    if (_pinJoint != NULL) {
        if (_pinJoint->IsMotorEnabled()) {
            _pinJoint->SetMotorSpeed(motorSpeed);
        }
        else {
            _pinJoint->SetMaxMotorTorque(1000);
            _pinJoint->SetMotorSpeed(motorSpeed);
            _pinJoint->EnableMotor(YES);
        }
    }
}

+ (id) metalCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    return [[[self alloc] initWithWorld:theWorld position:pos name:name] autorelease];
}

+ (id) metalCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name withPinAtPos:(CGPoint)pinPos
{
    return [[[self alloc] initWithWorld:theWorld position:pos name:name withPinAtPos:pinPos] autorelease];
}

- (void) dealloc
{
    [_pin release];
    _pin = nil;
    _pinJoint = nil;
    [super dealloc];
}

@end
