//
//  InterfaceController.m
//  IECFreezer Monitor WatchKit Extension
//
//  Created by Satyen Vats on 08/10/15.
//  Copyright (c) 2015 Motifworks. All rights reserved.
//

#import "InterfaceController.h"
#import "NKCircleChart.h"
#import "NKColor.h"

@interface InterfaceController()

@end


@implementation InterfaceController{
    NSTimer *myTimer;
    NSTimer *myTimer1;
    BOOL isYello;
    BOOL isRed;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self aTime];
    // Configure interface objects here.
    [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(aTime) userInfo:nil repeats:YES];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

-(void)aTime
{
    [myTimer invalidate];
    [myTimer1 invalidate];
    
    NSUserDefaults *defaults=[[NSUserDefaults alloc] initWithSuiteName:@"group.IECFreezer.Monitor"];
    [defaults synchronize];
    
    NSInteger number = [[NSString stringWithFormat:@"%@",[defaults valueForKey:@"myText"]] integerValue];
    NSInteger Set_t = [[NSString stringWithFormat:@"%@",[defaults valueForKey:@"myText1"]] integerValue];
    
//    NSInteger number = -106;
//    NSInteger Set_t = -100;
    
    NSInteger obsolute = Set_t - number;
    if (obsolute < 0) {
        obsolute = -(obsolute);
    }
    
    
    NSString *temp = [NSString stringWithFormat:@"%@",[defaults valueForKey:@"myText"]];
    self.hw.text = temp;
    
    NSNumber* num = @([temp integerValue]);
//    NSNumber* num = @(-10);
    
    CGRect frame = CGRectMake(0, 0, 120, 120);
    UIColor *shadowColor = [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:0.5f];
//    NKCircleChart *chart = [[NKCircleChart alloc] initWithFrame:frame total:@150 current:num clockwise:YES shadow:YES shadowColor:shadowColor displayCountingLabel:YES overrideLineWidth:@7];

    NKCircleChart *chart;
    if ([temp integerValue] < 0) {
        //        int i = [temp intValue];
        //        if (i < 0) {
        //            i = -(i);
        //        }
        //        num = @(i - 100);
        chart = [[NKCircleChart alloc] initWithFrame:frame total:@200 current:num clockwise:YES shadow:YES shadowColor:shadowColor displayCountingLabel:YES overrideLineWidth:@7];
    }else if([temp integerValue] > 0){
        num = @([num intValue]+100);
        chart = [[NKCircleChart alloc] initWithFrame:frame total:@200 current:num clockwise:YES shadow:YES shadowColor:shadowColor displayCountingLabel:YES overrideLineWidth:@7];
    }else{
        chart = [[NKCircleChart alloc] initWithFrame:frame total:@200 current:@(100) clockwise:YES shadow:YES shadowColor:shadowColor displayCountingLabel:YES overrideLineWidth:@7];
    }
    
    if (obsolute < 5) {
        [self.indicatorImage setImage:[UIImage imageNamed:@"green_heart.png"]];
        chart.strokeColor = NKGreen;
        chart.strokeColorGradientStart = NKGreen;
    } else if (obsolute > 5 && obsolute < 10){
        [self.indicatorImage setImage:[UIImage imageNamed:@"yellow_heart.png"]];
        chart.strokeColor = NKYellow;
        chart.strokeColorGradientStart = NKYellow;
        
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showAnimation) userInfo:nil repeats:YES];
        
    }else if (obsolute > 10){
        [self.indicatorImage setImage:[UIImage imageNamed:@"red_heart.png"]];
        chart.strokeColor = NKRed;
        chart.strokeColorGradientStart = NKRed;
        
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showAnimation1) userInfo:nil repeats:YES];
        
    }else{
        [self.indicatorImage setImage:[UIImage imageNamed:@"green_heart.png"]];
        chart.strokeColor = NKGreen;
        chart.strokeColorGradientStart = NKGreen;
    }
    
    UIImage* image = [chart drawImage];
//    [self.myImage setImage:image];
    [self.groupView setBackgroundImage:image];
}

- (void)showAnimation{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!isRed) {
            isRed = YES;
            [self.indicatorImage setImage:[UIImage imageNamed:@"yellow_heart.png"]];
        }else{
            isRed = NO;
            [self.indicatorImage setImage:nil];
        }
    });
}

- (void)showAnimation1{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!isYello) {
            [self.indicatorImage setImage:[UIImage imageNamed:@"red_heart.png"]];
            isYello = YES;
        }else{
            isYello = NO;
            [self.indicatorImage setImage:nil];
        }
    });
}

@end



