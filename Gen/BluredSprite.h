//
//  BluredSprite.h
//  Gen
//
//  Created by Andrey Korikov on 19.06.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "cocos2d.h"

@interface BluredSprite : CCSprite
{
    CGPoint blur_;
	GLfloat	sub_[4];
    
	GLuint	blurLocation;
	GLuint	subLocation;
}

-(void) setBlurSize:(CGFloat)f;
@end
