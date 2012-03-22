//
//  CustomContactListener.h
//  Gen
//
//  Created by Andrey Korikov on 19.03.12.
//  Copyright 2012 Atom Games. All rights reserved.
//

#import "Box2D.h"

class ContactListener : public b2ContactListener
{
private:
	void BeginContact(b2Contact* contact);
	void EndContact(b2Contact* contact);
};