//
// REFrostedContainerViewController.m
// REFrostedViewController
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "REFrostedContainerViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "REFrostedViewController.h"

@interface REFrostedContainerViewController ()

@property (strong, readwrite, nonatomic) NSMutableArray *backgroundViews;
@property (strong, readwrite, nonatomic) UIView *containerView;
@property (assign, readwrite, nonatomic) CGPoint containerOrigin;

@end

@interface REFrostedViewController ()

@property (assign, readwrite, nonatomic) BOOL menuVisible;
@property (assign, readwrite, nonatomic) CGSize calculatedMenuViewSize;

@end

@implementation REFrostedContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundViews = [NSMutableArray array];
    for (NSInteger i = 0; i < 4; i++) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectNull];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0.0f;
        [self.view addSubview:backgroundView];
        [self.backgroundViews addObject:backgroundView];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
        [backgroundView addGestureRecognizer:tapRecognizer];
    }
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, self.view.frame.size.height)];
    self.containerView.clipsToBounds = YES;
    [self.view addSubview:self.containerView];
    
    if (self.frostedViewController.liveBlur) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        toolbar.barStyle = (UIBarStyle)self.frostedViewController.liveBlurBackgroundStyle;
        [self.containerView addSubview:toolbar];
    }
    
    if (self.frostedViewController.menuViewController) {
        [self addChildViewController:self.frostedViewController.menuViewController];
        self.frostedViewController.menuViewController.view.frame = self.containerView.bounds;
        [self.containerView addSubview:self.frostedViewController.menuViewController.view];
        [self.frostedViewController.menuViewController didMoveToParentViewController:self];
    }
    
    [self.view addGestureRecognizer:self.frostedViewController.panGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.frostedViewController.menuVisible) {
		CGPoint menuOrigin = self.frostedViewController.menuViewOrigin;
        self.frostedViewController.menuViewController.view.frame = self.containerView.bounds;
        
        if (self.frostedViewController.direction == REFrostedViewControllerDirectionLeft) {
            [self setContainerFrame:CGRectMake(menuOrigin.x - self.frostedViewController.calculatedMenuViewSize.width, menuOrigin.y, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
        }
        
        if (self.frostedViewController.direction == REFrostedViewControllerDirectionRight) {
            [self setContainerFrame:CGRectMake(menuOrigin.x + self.view.frame.size.width, menuOrigin.y, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
        }
        
        if (self.frostedViewController.direction == REFrostedViewControllerDirectionTop) {
            [self setContainerFrame:CGRectMake(menuOrigin.x , menuOrigin.y -self.frostedViewController.calculatedMenuViewSize.height, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
        }
        
        if (self.frostedViewController.direction == REFrostedViewControllerDirectionBottom) {
            [self setContainerFrame:CGRectMake(menuOrigin.x, menuOrigin.y + self.view.frame.size.height, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
        }
        
        if (self.animateApperance)
            [self show];
    }
}

- (void)setContainerFrame:(CGRect)frame
{
    UIView *leftBackgroundView = self.backgroundViews[0];
    UIView *topBackgroundView = self.backgroundViews[1];
    UIView *bottomBackgroundView = self.backgroundViews[2];
    UIView *rightBackgroundView = self.backgroundViews[3];
    
    leftBackgroundView.frame = CGRectMake(0, 0, frame.origin.x, self.view.frame.size.height);
    rightBackgroundView.frame = CGRectMake(frame.size.width + frame.origin.x, 0, self.view.frame.size.width - frame.size.width - frame.origin.x, self.view.frame.size.height);
    
    topBackgroundView.frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.origin.y);
    bottomBackgroundView.frame = CGRectMake(frame.origin.x, frame.size.height + frame.origin.y, frame.size.width, self.view.frame.size.height);
    
    self.containerView.frame = frame;
}

- (void)setBackgroundViewsAlpha:(CGFloat)alpha
{
    for (UIView *view in self.backgroundViews) {
        view.alpha = alpha;
    }
}

- (void)resizeToSize:(CGSize)size
{
	CGPoint menuOrigin = self.frostedViewController.menuViewOrigin;
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionLeft) {
        [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
            [self setContainerFrame:CGRectMake(menuOrigin.x, menuOrigin.y, size.width, size.height)];
            [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
        } completion:nil];
    }
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionRight) {
        [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
            [self setContainerFrame:CGRectMake(menuOrigin.x + self.view.frame.size.width - size.width, menuOrigin.y, size.width, size.height)];
            [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
        } completion:nil];
    }
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionTop) {
        [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
            [self setContainerFrame:CGRectMake(menuOrigin.x, menuOrigin.y, size.width, size.height)];
            [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
        } completion:nil];
    }
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionBottom) {
        [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
            [self setContainerFrame:CGRectMake(menuOrigin.x, menuOrigin.y + self.view.frame.size.height - size.height, size.width, size.height)];
            [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
        } completion:nil];
    }
}

- (void)show
{
    void (^completionHandler)(BOOL finished) = ^(BOOL finished) {
        if ([self.frostedViewController.delegate conformsToProtocol:@protocol(REFrostedViewControllerDelegate)] && [self.frostedViewController.delegate respondsToSelector:@selector(frostedViewController:didShowMenuViewController:)]) {
            [self.frostedViewController.delegate frostedViewController:self.frostedViewController didShowMenuViewController:self.frostedViewController.menuViewController];
        }
    };

	CGPoint menuOrigin = self.frostedViewController.menuViewOrigin;
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionLeft) {
        [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
            [self setContainerFrame:CGRectMake(menuOrigin.x, menuOrigin.y, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
            [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
        } completion:completionHandler];
    }
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionRight) {
        [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
            [self setContainerFrame:CGRectMake(menuOrigin.x + self.view.frame.size.width - self.frostedViewController.calculatedMenuViewSize.width, menuOrigin.y, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
            [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
        } completion:completionHandler];
    }
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionTop) {
        [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
            [self setContainerFrame:CGRectMake(menuOrigin.x, menuOrigin.y, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
            [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
        } completion:completionHandler];
    }
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionBottom) {
        [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
            [self setContainerFrame:CGRectMake(menuOrigin.x, menuOrigin.y + self.view.frame.size.height - self.frostedViewController.calculatedMenuViewSize.height, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
            [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
        } completion:completionHandler];
    }
}


- (void)hide
{
	[self hideWithCompletionHandler:nil];
}

- (void)hideWithCompletionHandler:(void(^)(void))completionHandler
{
    void (^completionHandlerBlock)(void) = ^{
        if ([self.frostedViewController.delegate conformsToProtocol:@protocol(REFrostedViewControllerDelegate)] && [self.frostedViewController.delegate respondsToSelector:@selector(frostedViewController:didHideMenuViewController:)]) {
            [self.frostedViewController.delegate frostedViewController:self.frostedViewController didHideMenuViewController:self.frostedViewController.menuViewController];
        }
        if (completionHandler)
            completionHandler();
    };
    
    if ([self.frostedViewController.delegate conformsToProtocol:@protocol(REFrostedViewControllerDelegate)] && [self.frostedViewController.delegate respondsToSelector:@selector(frostedViewController:willHideMenuViewController:)]) {
        [self.frostedViewController.delegate frostedViewController:self.frostedViewController willHideMenuViewController:self.frostedViewController.menuViewController];
    }

	CGPoint menuOrigin = self.frostedViewController.menuViewOrigin;
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionLeft) {
        [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
            [self setContainerFrame:CGRectMake(menuOrigin.x - self.frostedViewController.calculatedMenuViewSize.width, menuOrigin.y, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
            [self setBackgroundViewsAlpha:0];
        } completion:^(BOOL finished) {
            self.frostedViewController.menuVisible = NO;
            [self.frostedViewController re_hideController:self];
            completionHandlerBlock();
        }];
    }
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionRight) {
        [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
            [self setContainerFrame:CGRectMake(menuOrigin.x + self.view.frame.size.width, menuOrigin.y, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
            [self setBackgroundViewsAlpha:0];
        } completion:^(BOOL finished) {
            self.frostedViewController.menuVisible = NO;
            [self.frostedViewController re_hideController:self];
            completionHandlerBlock();
        }];
    }
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionTop) {
        [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
            [self setContainerFrame:CGRectMake(menuOrigin.x, menuOrigin.y -self.frostedViewController.calculatedMenuViewSize.height, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
            [self setBackgroundViewsAlpha:0];
        } completion:^(BOOL finished) {
            self.frostedViewController.menuVisible = NO;
            [self.frostedViewController re_hideController:self];
            completionHandlerBlock();
        }];
    }
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionBottom) {
        [UIView animateWithDuration:self.frostedViewController.animationDuration animations:^{
            [self setContainerFrame:CGRectMake(menuOrigin.x, menuOrigin.y +  self.view.frame.size.height, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
            [self setBackgroundViewsAlpha:0];
        } completion:^(BOOL finished) {
            self.frostedViewController.menuVisible = NO;
            [self.frostedViewController re_hideController:self];
            completionHandlerBlock();
        }];
    }
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    [self hide];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if ([self.frostedViewController.delegate conformsToProtocol:@protocol(REFrostedViewControllerDelegate)] && [self.frostedViewController.delegate respondsToSelector:@selector(frostedViewController:didRecognizePanGesture:)])
        [self.frostedViewController.delegate frostedViewController:self.frostedViewController didRecognizePanGesture:recognizer];
    
    if (!self.frostedViewController.panGestureEnabled)
        return;
    
    CGPoint point = [recognizer translationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.containerOrigin = self.containerView.frame.origin;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGRect frame = self.containerView.frame;
        if (self.frostedViewController.direction == REFrostedViewControllerDirectionLeft) {
            frame.origin.x = self.containerOrigin.x + point.x;
            if (frame.origin.x > 0) {
                frame.origin.x = 0;
                
                if (!self.frostedViewController.limitMenuViewSize) {
                    frame.size.width = self.frostedViewController.calculatedMenuViewSize.width + self.containerOrigin.x + point.x;
                    if (frame.size.width > self.view.frame.size.width)
                        frame.size.width = self.view.frame.size.width;
                }
            }
        }
        
        if (self.frostedViewController.direction == REFrostedViewControllerDirectionRight) {
            frame.origin.x = self.containerOrigin.x + point.x;
            if (frame.origin.x < self.view.frame.size.width - self.frostedViewController.calculatedMenuViewSize.width) {
                frame.origin.x = self.view.frame.size.width - self.frostedViewController.calculatedMenuViewSize.width;
            
                if (!self.frostedViewController.limitMenuViewSize) {
                    frame.origin.x = self.containerOrigin.x + point.x;
                    if (frame.origin.x < 0)
                        frame.origin.x = 0;
                    frame.size.width = self.view.frame.size.width - frame.origin.x;
                }
            }
        }
        
        if (self.frostedViewController.direction == REFrostedViewControllerDirectionTop) {
            frame.origin.y = self.containerOrigin.y + point.y;
            if (frame.origin.y > 0) {
                frame.origin.y = 0;
            
                if (!self.frostedViewController.limitMenuViewSize) {
                    frame.size.height = self.frostedViewController.calculatedMenuViewSize.height + self.containerOrigin.y + point.y;
                    if (frame.size.height > self.view.frame.size.height)
                        frame.size.height = self.view.frame.size.height;
                }
            }
        }
        
        if (self.frostedViewController.direction == REFrostedViewControllerDirectionBottom) {
            frame.origin.y = self.containerOrigin.y + point.y;
            if (frame.origin.y < self.view.frame.size.height - self.frostedViewController.calculatedMenuViewSize.height) {
                frame.origin.y = self.view.frame.size.height - self.frostedViewController.calculatedMenuViewSize.height;
            
                if (!self.frostedViewController.limitMenuViewSize) {
                    frame.origin.y = self.containerOrigin.y + point.y;
                    if (frame.origin.y < 0)
                        frame.origin.y = 0;
                    frame.size.height = self.view.frame.size.height - frame.origin.y;
                }
            }
        }
        
        [self setContainerFrame:frame];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.frostedViewController.direction == REFrostedViewControllerDirectionLeft) {
            if ([recognizer velocityInView:self.view].x < 0) {
                [self hide];
            } else {
                [self show];
            }
        }
        
        if (self.frostedViewController.direction == REFrostedViewControllerDirectionRight) {
            if ([recognizer velocityInView:self.view].x < 0) {
                [self show];
            } else {
                [self hide];
            }
        }
        
        if (self.frostedViewController.direction == REFrostedViewControllerDirectionTop) {
            if ([recognizer velocityInView:self.view].y < 0) {
                [self hide];
            } else {
                [self show];
            }
        }
        
        if (self.frostedViewController.direction == REFrostedViewControllerDirectionBottom) {
            if ([recognizer velocityInView:self.view].y < 0) {
                [self show];
            } else {
                [self hide];
            }
        }
    }
}

- (void)fixLayoutWithDuration:(NSTimeInterval)duration
{
	CGPoint menuOrigin = self.frostedViewController.menuViewOrigin;

    if (self.frostedViewController.direction == REFrostedViewControllerDirectionLeft) {
        [self setContainerFrame:CGRectMake(menuOrigin.x, menuOrigin.y, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
        [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
    }
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionRight) {
        [self setContainerFrame:CGRectMake(menuOrigin.x + self.view.frame.size.width - self.frostedViewController.calculatedMenuViewSize.width, menuOrigin.y, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
        [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
    }
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionTop) {
        [self setContainerFrame:CGRectMake(menuOrigin.x, menuOrigin.y, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
        [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
    }
    
    if (self.frostedViewController.direction == REFrostedViewControllerDirectionBottom) {
        [self setContainerFrame:CGRectMake(menuOrigin.x, menuOrigin.y + self.view.frame.size.height - self.frostedViewController.calculatedMenuViewSize.height, self.frostedViewController.calculatedMenuViewSize.width, self.frostedViewController.calculatedMenuViewSize.height)];
        [self setBackgroundViewsAlpha:self.frostedViewController.backgroundFadeAmount];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self fixLayoutWithDuration:duration];
}

@end
