//
//  CALayer+XibConfiguration.h
//  PixoClub
//
//  Created by Robert Mao on 1/2/14.
//  Copyright (c) 2014 LOCQL INC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (XibConfiguration)

// This assigns a CGColor to borderColor.
@property(nonatomic, assign) UIColor* borderUIColor;
@property(nonatomic, assign) UIColor* shadowUIColor;

@end
