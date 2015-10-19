//
//  ViewController.m
//  IECFreezer Monitor
//
//  Created by Satyen Vats on 08/10/15.
//  Copyright (c) 2015 Motifworks. All rights reserved.
//

#import "ViewController.h"
#import "NKCircleChart.h"
#import "NKColor.h"

@interface ViewController ()

@end

@implementation ViewController{
    NSTimer *myTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self aTime];
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(aTime) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)aTime
{
    [myTimer invalidate];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://dweet.io:443/get/latest/dweet/for/IEC_Freezer1?thing=IEC_Freezer1"]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSArray* contents = [result objectForKey:@"with"];
    
    NSInteger number = [[[[contents objectAtIndex:0] objectForKey:@"content"] objectForKey:@"Actual_t"] integerValue];
    NSInteger Set_t = [[[[contents objectAtIndex:0] objectForKey:@"content"] objectForKey:@"Set_t"] integerValue];
    
//    NSInteger number = 100;
//    NSInteger Set_t = -40;
    
    NSInteger obsolute = Set_t - number;
    if (obsolute < 0) {
        obsolute = -(obsolute);
    }
    
    NSUserDefaults *defaults=[[NSUserDefaults alloc] initWithSuiteName:@"group.IECFreezer.Monitor"];
    [defaults setObject:[NSString stringWithFormat:@"%ld\u00b0C",(long)number] forKey:@"myText"];
    [defaults setObject:[NSString stringWithFormat:@"%ld\u00b0C",(long)Set_t] forKey:@"myText1"];
    [defaults synchronize];
    
    NSString *temp = [NSString stringWithFormat:@"%@",[defaults valueForKey:@"myText"]];
    
//    self.numberLabel.text = temp;
    
    NSNumber* num = @([temp integerValue]);
//    int num = [temp intValue];
//    if(num < 0) num = -(num);
    //    NSNumber* num = @(-70);
    
    CGRect frame = CGRectMake(0, 0, 120, 120);
    UIColor *shadowColor = [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:0.5f];

    NKCircleChart *chart;
    
    if ([temp integerValue] < 0) {
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
        
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:30];
        
        localNotification.alertBody = @"Temprature signal is Yellow";
        
//        localNotification.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"IST"];
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
    }else if (obsolute > 10){
        [self.indicatorImage setImage:[UIImage imageNamed:@"red_heart.png"]];
        chart.strokeColor = NKRed;
        chart.strokeColorGradientStart = NKRed;
        
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showAnimation) userInfo:nil repeats:YES];
        
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:30];
        
        localNotification.alertBody = @"Temprature signal is Red";
        
//        localNotification.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"IST"];
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }else{
        [self.indicatorImage setImage:[UIImage imageNamed:@"green_heart.png"]];
        chart.strokeColor = NKGreen;
        chart.strokeColorGradientStart = NKGreen;
    }
    
//    if (num > [NSNumber numberWithInt:-86] && num < [NSNumber numberWithInt:-74]) {
//        [self.indicatorImage setImage:nil];
//        chart.strokeColor = NKGreen;
//        chart.strokeColorGradientStart = NKLightGreen;
//    }else if (num > [NSNumber numberWithInt:-76] && num < [NSNumber numberWithInt:-64]) {
//        [self.indicatorImage setImage:[UIImage imageNamed:@"alert.png"]];
//        chart.strokeColor = NKYellow;
//        chart.strokeColorGradientStart = NKYellow;
//    }else if (num > [NSNumber numberWithInt:-66] && num < [NSNumber numberWithInt:-1]) {
//        [self.indicatorImage setImage:[UIImage imageNamed:@"fire_alarm.png"]];
//        chart.strokeColor = NKRed;
//        chart.strokeColorGradientStart = NKRed;
//    }else{
//        [self.indicatorImage setImage:nil];
//        chart.strokeColor = NKGreen;
//        chart.strokeColorGradientStart = NKGreen;
//    }
    
//    [self.indicatorImage setImage:[UIImage imageNamed:@"fire_alarm.png"]];
//    chart.strokeColor = NKGreen;
//    chart.strokeColorGradientStart = NKLightGreen;
    
    
    UIImage* image = [chart drawImage];
    [self.myImage setImage:image];
}

- (void)showAnimation{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.indicatorImage.hidden) {
            self.indicatorImage.hidden = NO;
        }else{
            self.indicatorImage.hidden = YES;
        }
    });
}

@end
