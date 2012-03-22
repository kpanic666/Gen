//
//  SimpleQueryCallback.h
//  SpaceViking
//
//  Created by Andrey Korikov on 05.02.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#include "Box2D.h"

class SimpleQueryCallback : public b2QueryCallback
{    
public:
    b2Vec2 pointToTest;
    b2Fixture *fixtureFound;
    
    SimpleQueryCallback(const b2Vec2& point)
    {
        pointToTest = point;
        fixtureFound = NULL;
    }
    
    bool ReportFixture(b2Fixture* fixture)
    {
        b2Body *body = fixture->GetBody();
        if (body->GetType() == b2_dynamicBody) {
            if (fixture->TestPoint(pointToTest)) {
                fixtureFound = fixture;
                return false;
            }
        }
        return true;
    }
};
