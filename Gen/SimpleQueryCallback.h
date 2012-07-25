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
    b2Body *bodyToTest;
    b2Fixture *fixtureFound;
    
    SimpleQueryCallback(const b2Vec2& point, b2Body *queryBody)
    {
        pointToTest = point;
        bodyToTest = queryBody;
        fixtureFound = NULL;
    }
    
    bool ReportFixture(b2Fixture* fixture)
    {
        b2Body *body = fixture->GetBody();
        if (body == bodyToTest)
        {
            if (fixture->TestPoint(pointToTest)) {
                fixtureFound = fixture;
                return false;
            }
        }
        return true;
    }
};
