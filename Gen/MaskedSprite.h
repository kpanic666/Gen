//
//  MaskedSprite.h
//  Делает из 2х текстур один спрайт. Маскирует прозрачную область из _maskTexture и накладывает ее на интересующую нас текстуру
//
//  Created by Andrey Korikov on 17.04.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#import "cocos2d.h"

@interface MaskedSprite : CCSprite
{
    CCTexture2D *_maskTexture;
    GLuint _textureLocation;
    GLuint _maskLocation;
}

- (id)initWithTexture:(CCTexture2D *)texture rect:(CGRect)rect maskTexture:(CCTexture2D*)maskTexture;

@end
