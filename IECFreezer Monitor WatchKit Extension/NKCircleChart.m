//
//  NKCircleChart.m
//  NKWatchChartDemo
//
//  Created by Peng on 8/8/15.
//  Copyright © 2015 Peng. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import "NKCircleChart.h"
#import "NKColor.h"

@interface NKCircleChart (){
    BOOL isNegitive;
    int temp;
}

@property (nonatomic) CGRect frame;

@end

@implementation NKCircleChart

- (id)initWithFrame:(CGRect)frame total:(NSNumber *)total current:(NSNumber *)current clockwise:(BOOL)clockwise {
    
    return [self initWithFrame:frame
                         total:total
                       current:current
                     clockwise:clockwise
                        shadow:NO
                   shadowColor:[UIColor clearColor]
          displayCountingLabel:YES
             overrideLineWidth:@8.0f];
    
}

- (id)initWithFrame:(CGRect)frame total:(NSNumber *)total current:(NSNumber *)current clockwise:(BOOL)clockwise shadow:(BOOL)hasBackgroundShadow shadowColor:(UIColor *)backgroundShadowColor {
    
    return [self initWithFrame:frame
                         total:total
                       current:current
                     clockwise:clockwise
                        shadow:shadow
                   shadowColor:backgroundShadowColor
          displayCountingLabel:YES
             overrideLineWidth:@8.0f];
    
}

- (id)initWithFrame:(CGRect)frame total:(NSNumber *)total current:(NSNumber *)current clockwise:(BOOL)clockwise shadow:(BOOL)hasBackgroundShadow shadowColor:(UIColor *)backgroundShadowColor displayCountingLabel:(BOOL)displayCountingLabel {
    
    return [self initWithFrame:frame
                         total:total
                       current:current
                     clockwise:clockwise
                        shadow:shadow
                   shadowColor:NKGreen
          displayCountingLabel:displayCountingLabel
             overrideLineWidth:@8.0f];
    
}

- (id)initWithFrame:(CGRect)frame
              total:(NSNumber *)total
            current:(NSNumber *)current
          clockwise:(BOOL)clockwise
             shadow:(BOOL)hasBackgroundShadow
        shadowColor:(UIColor *)backgroundShadowColor
displayCountingLabel:(BOOL)displayCountingLabel
  overrideLineWidth:(NSNumber *)overrideLineWidth
{
    self = [super init];
    
    if (self) {
        _frame = frame;
        _total = total;
        _current = current;
        _strokeColor = NKFreshGreen;
        _chartType = NKChartFormatTypePercent;
        _displayCountingLabel = displayCountingLabel;
        _clockwise = clockwise;
        _lineWidth = overrideLineWidth;
        _hasBackgroundShadow = hasBackgroundShadow;
        _backgroundShadowColor = backgroundShadowColor;
        
    }
    
    return self;
}

- (UIImage *)drawImage
{
    
    int num = [_current intValue];
    if(num < 0){
        num = -(num);
        num = num - 100;
        num = -(num);
        isNegitive = YES;
    }
    
    _current = @(num);
    
    CGFloat startAngle = 0.f;
    CGFloat endAngle =  0.f;
    
    if (_clockwise)     {
        
        startAngle = -235.7f;
        endAngle =  290.0f*([_current floatValue] / [_total floatValue]) + startAngle + 0.01f;
//        startAngle = -270.0f;
//        endAngle =  360.0f*([_current floatValue] / [_total floatValue]) + startAngle + 0.01f;
        
        
    } else
    {
        startAngle = 270.0f;
        endAngle =  startAngle + 0.01f - 360.0f*([_current floatValue] / [_total floatValue]) ;
        
    }
    
    CGFloat scale = [WKInterfaceDevice currentDevice].screenScale;
    
    UIGraphicsBeginImageContextWithOptions(_frame.size, false, scale);
    
    if (_chartBackgroundColor) {
        UIBezierPath *chartRect = [UIBezierPath bezierPathWithRect:_frame];
        [_chartBackgroundColor setFill];
        [chartRect fill];
    }
    
    CGPoint arcCenter = CGPointMake(_frame.size.width/2.0f, _frame.size.height/2.0f);
    CGFloat radius = (_frame.size.height * 0.4) - ([_lineWidth floatValue]/2.0f);
    
    if (_hasBackgroundShadow)
    {
        UIBezierPath *circleBackground = [UIBezierPath bezierPathWithArcCenter: arcCenter radius:radius startAngle:2.19f endAngle:M_PI*2 + 1.0 clockwise:YES];
        circleBackground.lineWidth = [_lineWidth floatValue];
        if (_backgroundShadowColor) {
            [_backgroundShadowColor setStroke];
        } else {
            [[UIColor clearColor] setStroke];
        }
        [circleBackground stroke];
    }
   
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef arc = CGPathCreateMutable();
    CGPathAddArc(arc, NULL,
                 arcCenter.x, arcCenter.y,
                 radius,
                 DEGREES_TO_RADIANS(startAngle),
                 DEGREES_TO_RADIANS(endAngle),
                 !_clockwise);// core graphic's coordination is reversed to normal
    
    CGPathRef strokedArc =
    CGPathCreateCopyByStrokingPath(arc, NULL,
                                   [_lineWidth floatValue],
                                   kCGLineCapRound,
                                   kCGLineJoinRound, // the default
                                   10); // 10 is default miter limit
    
    CGContextAddPath(context, strokedArc);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // Adding shadows
    CGColorRef shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75].CGColor;
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context,
                                CGSizeMake(0, 2), // Offset
                                3.0,              // Radius
                                shadowColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    // Note that filling the path "consumes it" so we add it again
    CGContextAddPath(context, strokedArc);
    CGContextStrokePath(context);
    
    // Drawing the gradient
    if (_strokeColorGradientStart)
    {
        NSArray *colors = @[
                            (__bridge id)_strokeColorGradientStart.CGColor,
                            (__bridge id)_strokeColor.CGColor
                            ];
        CGFloat locations[] = {0.0, [_current floatValue] / [_total floatValue]};
        
        CGGradientRef gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (__bridge CFArrayRef)colors,locations);
        
        CGContextSaveGState(context);
        CGContextAddPath(context, strokedArc);
        CGContextClip(context);
        
        CGRect boundingBox = CGPathGetBoundingBox(strokedArc);
        CGPoint gradientStart = CGPointMake(0, CGRectGetMinY(boundingBox));
        CGPoint gradientEnd   = CGPointMake(0, CGRectGetMaxY(boundingBox));
        
        CGContextDrawLinearGradient(context, gradient, gradientStart, gradientEnd, 0);
        CGGradientRelease(gradient), gradient = NULL;
        CGContextRestoreGState(context);
     }
    //draw text
    if (_displayCountingLabel)
    {
        NSString *format;
        switch (_chartType) {
            case NKChartFormatTypePercent:
                format = @"%d\u00b0C";
                break;
            case NKChartFormatTypeDollar:
                format = @"$%d";
                break;
            case NKChartFormatTypeNone:
            default:
                format = @"%d";
                break;
        }
        
        NSString *text;
        
        if([format rangeOfString:@"%(.*)d" options:NSRegularExpressionSearch].location != NSNotFound || [format rangeOfString:@"%(.*)i"].location != NSNotFound )
        {
            text = [NSString stringWithFormat:format,(int)[_current floatValue]];
        }
        else
        {
            text = [NSString stringWithFormat:format,[_current floatValue]];
        }
        
        if (isNegitive) {
            temp = [_current intValue];
            temp = 100 - temp;
            text = [NSString stringWithFormat:format,temp];
            text = [NSString stringWithFormat:@"-%@",text];
            temp = -(temp);
        }else{
            temp = [_current intValue] - 100;
            text = [NSString stringWithFormat:format,[_current intValue] - 100];
        }
        
        if (_current == 0) {
            temp = 0;
            text = [NSString stringWithFormat:format,0];
        }

        CGRect textRect = CGRectMake(arcCenter.x-19.0, arcCenter.y+32.0, 50.f, 20.f);
        [text drawInRect:textRect
           withAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:15 weight:normal], NSForegroundColorAttributeName:_strokeColor}];
        
        if (temp > -84 && temp < -74) {
            UIImage *image = [UIImage imageNamed:@"Thermo_blue.png"];
            [image drawInRect:CGRectMake(arcCenter.x-24.0, arcCenter.y- 28.0, 45.0, 55.0)];
        }else if (temp > -74 && temp < -64) {
            UIImage *image = [UIImage imageNamed:@"Thermo_orange.png"];
            [image drawInRect:CGRectMake(arcCenter.x-24.0, arcCenter.y- 28.0, 45.0, 55.0)];
        }else if (temp > -64) {
            UIImage *image = [UIImage imageNamed:@"Thermo_red.png"];
            [image drawInRect:CGRectMake(arcCenter.x-24.0, arcCenter.y- 28.0, 45.0, 55.0)];
        }else{
            UIImage *image = [UIImage imageNamed:@"Thermo_blue.png"];
            [image drawInRect:CGRectMake(arcCenter.x-28.0, arcCenter.y- 28.0, 50.0, 55.0)];
        }
        
//        UIImage *image = [UIImage imageNamed:@"Thermo_red.png"];
//        [image drawInRect:CGRectMake(arcCenter.x-28.0, arcCenter.y- 28.0, 50.0, 55.0)];
//        [image drawAsPatternInRect:CGRectMake(arcCenter.x-15.0, arcCenter.y- 15.0, 10.0, 20.0)];
        
//        text = [NSString stringWithFormat:format,-100];
//        CGRect textRect1 = CGRectMake(arcCenter.x-38.0, arcCenter.y+39.0, 50.f, 20.f);
//        [text drawInRect:textRect1
//          withAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:5 weight:normal], NSForegroundColorAttributeName:NKBlack}];
//        
//        text = [NSString stringWithFormat:format,100];
//        CGRect textRect2 = CGRectMake(arcCenter.x+25.0, arcCenter.y+39.0, 50.f, 20.f);
//        [text drawInRect:textRect2
//          withAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:5 weight:normal], NSForegroundColorAttributeName:NKBlack}];
        
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)drawTextInContext:(CGContextRef )ctx text:(NSString *)text inRect:(CGRect)rect font:(UIFont *)font
{
    NSMutableParagraphStyle *priceParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    priceParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    priceParagraphStyle.alignment = NSTextAlignmentLeft;
    
    [text drawInRect:rect
      withAttributes:@{ NSParagraphStyleAttributeName:priceParagraphStyle, NSFontAttributeName:font, NSForegroundColorAttributeName:NKGreen}];
}


@end
