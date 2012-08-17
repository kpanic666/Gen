//
//  SimpleQueryCallback.h
//  SpaceViking
//
//  Created by Andrey Korikov on 05.02.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#include "Box2D.h"
#include "CommonProtocols.h"
#include "Box2DSprite.h"

// Входные параметры: point - точка для (в которую монтируется AABB) для поиска тел, queryBody - если не нужна выставляем
// в nil или задаем конкретное тело, фикстуру которого нужно вернуть, objectType - тип игрового объекта, фикстуру которого
// нужно вернуть или nil.

class SimpleQueryCallback : public b2QueryCallback
{    
public:
    b2Vec2 pointToTest;
    b2Body *bodyToTest;
    b2Fixture *fixtureFound;
    GameObjectType gObjectType;
    
    SimpleQueryCallback(const b2Vec2& point, b2Body *queryBody, GameObjectType objectType)
    {
        pointToTest = point;
        bodyToTest = queryBody;
        fixtureFound = NULL;
        gObjectType = objectType;
    }
    
    bool ReportFixture(b2Fixture* fixture)
    {
        b2Body *body = fixture->GetBody();
        if (body == bodyToTest)
        {
            if (fixture->TestPoint(pointToTest))
            {
                fixtureFound = fixture;
                return false;
            }
        }
        else if (bodyToTest == nil)
        {
            Box2DSprite *spr = (Box2DSprite*)body->GetUserData();
            if (body->GetType() == b2_dynamicBody && spr.gameObjectType == gObjectType)
            {
                if (fixture->TestPoint(pointToTest)) {
                    fixtureFound = fixture;
                    return false;
                }
            }
        }
        
        return true;
    }
};
