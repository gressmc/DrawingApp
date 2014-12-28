//
//  ViewController.m
//  DrawingApp
//
//  Created by gressmc on 03/12/14.
//  Copyright (c) 2014 gressmc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 20.f;
    opacity = 1.f;
    
    UIGraphicsBeginImageContext(self.brushPreview.frame.size);
    
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
    CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectInset(CGRectMake(0, 0, CGRectGetWidth(self.brushPreview.bounds), CGRectGetHeight(self.brushPreview.bounds)), 10, 10));
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor colorWithRed:red green:green blue:blue alpha:opacity].CGColor);
    CGContextAddArc(UIGraphicsGetCurrentContext(), CGRectGetMidX(self.brushPreview.bounds), CGRectGetMidY(self.brushPreview.bounds), brush/2, M_PI, 3*M_PI, NO);
    CGContextFillPath(UIGraphicsGetCurrentContext());
    self.brushPreview.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.mainView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.mainView];

    UIGraphicsBeginImageContext(self.mainView.frame.size);
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height)];
    
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor colorWithRed:red green:green blue:blue alpha:1.f].CGColor);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.mainView.frame.size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor colorWithRed:red green:green blue:blue alpha:opacity].CGColor);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
    
}

- (IBAction)eraserPressed:(id)sender {
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 255.0/255.0;
    opacity = 1.0;
}

- (IBAction)Save:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Сохранить каракули?"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Save to Camera Roll", @"Cancel", nil];
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        UIGraphicsBeginImageContextWithOptions(self.mainImage.bounds.size, NO,0.0);
        [self.mainImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height)];
        UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(SaveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image could not be saved.Please try again"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image was successfully saved in photoalbum"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alert show];
    }
}

- (IBAction)Reset:(id)sender {
    self.mainImage.image = nil;
}

- (IBAction)sliderChanged:(id)sender{
    UISlider* changedSlider = (UISlider*)sender;
    
    if (changedSlider == self.brushControl) {
        brush = self.brushControl.value;
    }else if(changedSlider == self.opacityControl){
        opacity = self.opacityControl.value;
    } else if(changedSlider == self.redControl) {
        red = self.redControl.value/255.0;
        self.redLabel.text = [NSString stringWithFormat:@"R:%d", (int)self.redControl.value];
    } else if(changedSlider == self.greenControl){
        green = self.greenControl.value/255.0;
        self.greenLabel.text = [NSString stringWithFormat:@"G:%d", (int)self.greenControl.value];
    } else if (changedSlider == self.blueControl){
        blue = self.blueControl.value/255.0;
        self.blueLabel.text = [NSString stringWithFormat:@"B:%d", (int)self.blueControl.value];
    }
    
    UIGraphicsBeginImageContext(self.brushPreview.frame.size);
    
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
    CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectInset(CGRectMake(0, 0, CGRectGetWidth(self.brushPreview.bounds), CGRectGetHeight(self.brushPreview.bounds)), 10, 10));
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor colorWithRed:red green:green blue:blue alpha:opacity].CGColor);
    CGContextAddArc(UIGraphicsGetCurrentContext(), CGRectGetMidX(self.brushPreview.bounds), CGRectGetMidY(self.brushPreview.bounds), brush/2, M_PI, 3*M_PI, NO);
    CGContextFillPath(UIGraphicsGetCurrentContext());
    self.brushPreview.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    
    
}
@end
