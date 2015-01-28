//
// REFrostedViewController.m
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

#import "REFrostedViewController.h"
#import "REFrostedContainerViewController.h"

@interface REFrostedViewController ()

@property (strong, readwrite, nonatomic) REFrostedContainerViewController *containerViewController;
@property (strong, readwrite, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (assign, readwrite, nonatomic) BOOL automaticSize;
@property (assign, readwrite, nonatomic) CGSize calculatedMenuViewSize;

@end

@implementation REFrostedViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.wantsFullScreenLayout = YES;
#pragma clang diagnostic pop
    _panGestureEnabled = YES;
    _animationDuration = 0.35f;
    _backgroundFadeAmount = 0.3f;
    _containerViewController = [[REFrostedContainerViewController alloc] init];
    _containerViewController.frostedViewController = self;
    _menuViewSize = CGSizeZero;
    _liveBlur = YES;
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:_containerViewController action:@selector(panGestureRecognized:)];
    _automaticSize = YES;
}

- (id)initWithContentViewController:(UIViewController *)contentViewController menuViewController:(UIViewController *)menuViewController
{
    self = [self init];
    if (self) {
        _contentViewController = contentViewController;
        _menuViewController = menuViewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self re_displayController:self.contentViewController frame:self.contentView.bounds];
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.contentViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.contentViewController;
}

#pragma mark -
#pragma mark Getters

- (UIView *)contentView
{
	if (_contentView == nil)
	{
		UIView *autoContView = [[UIView alloc] initWithFrame:self.view.bounds];
		autoContView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		autoContView.translatesAutoresizingMaskIntoConstraints = YES;

		_contentView = autoContView;
	}
	return _contentView;
}


#pragma mark -
#pragma mark Setters

- (void)setMenuVisible:(BOOL)menuVisible
{
	_menuVisible = menuVisible;
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (!_contentViewController) {
        _contentViewController = contentViewController;
        return;
    }
    
    [_contentViewController removeFromParentViewController];
    [_contentViewController.view removeFromSuperview];
    
    if (contentViewController) {
        [self addChildViewController:contentViewController];
        contentViewController.view.frame = self.contentView.bounds;
        [self.contentView insertSubview:contentViewController.view atIndex:0];
        [contentViewController didMoveToParentViewController:self];
    }
    _contentViewController = contentViewController;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (void)setMenuViewController:(UIViewController *)menuViewController
{
    if (_menuViewController) {
        [_menuViewController.view removeFromSuperview];
        [_menuViewController removeFromParentViewController];
    }
    
    _menuViewController = menuViewController;

    CGRect frame = _menuViewController.view.frame;
    [_menuViewController willMoveToParentViewController:nil];
    [_menuViewController removeFromParentViewController];
    [_menuViewController.view removeFromSuperview];
    _menuViewController = menuViewController;
    if (!_menuViewController)
        return;
    
    [self.containerViewController addChildViewController:menuViewController];
    menuViewController.view.frame = frame;
    [self.containerViewController.containerView addSubview:menuViewController.view];
    [menuViewController didMoveToParentViewController:self];
}

- (void)setMenuViewSize:(CGSize)menuViewSize
{
    _menuViewSize = menuViewSize;
    self.automaticSize = NO;
}

#pragma mark -

- (void)presentMenuViewController
{
    [self presentMenuViewControllerWithAnimatedApperance:YES];
}

- (void)presentMenuViewControllerWithAnimatedApperance:(BOOL)animateApperance
{
    if ([self.delegate conformsToProtocol:@protocol(REFrostedViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(frostedViewController:willShowMenuViewController:)]) {
        [self.delegate frostedViewController:self willShowMenuViewController:self.menuViewController];
    }
    
    self.containerViewController.animateApperance = animateApperance;
    if (self.automaticSize) {
        if (self.direction == REFrostedViewControllerDirectionLeft || self.direction == REFrostedViewControllerDirectionRight)
            self.calculatedMenuViewSize = CGSizeMake(self.contentViewController.view.frame.size.width - 50.0f, self.contentViewController.view.frame.size.height);
        
        if (self.direction == REFrostedViewControllerDirectionTop || self.direction == REFrostedViewControllerDirectionBottom)
            self.calculatedMenuViewSize = CGSizeMake(self.contentViewController.view.frame.size.width, self.contentViewController.view.frame.size.height - 50.0f);
    } else {
        self.calculatedMenuViewSize = CGSizeMake(_menuViewSize.width > 0 ? _menuViewSize.width : self.contentViewController.view.frame.size.width,
                                                 _menuViewSize.height > 0 ? _menuViewSize.height : self.contentViewController.view.frame.size.height);
    }
        
    [self re_displayController:self.containerViewController frame:self.contentViewController.view.frame];
    _menuVisible = YES;
}

- (void)hideMenuViewControllerWithCompletionHandler:(void(^)(void))completionHandler
{
    if (!self.menuVisible) {//when call hide menu before menuViewController added to containerViewController, the menuViewController will never added to containerViewController
        return;
    }
    [self.containerViewController hideWithCompletionHandler:completionHandler];
}

- (void)resizeMenuViewControllerToSize:(CGSize)size
{
    [self.containerViewController resizeToSize:size];
}

- (void)hideMenuViewController
{
	[self hideMenuViewControllerWithCompletionHandler:nil];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if ([self.delegate conformsToProtocol:@protocol(REFrostedViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(frostedViewController:didRecognizePanGesture:)])
        [self.delegate frostedViewController:self didRecognizePanGesture:recognizer];
    
    if (!self.panGestureEnabled)
        return;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self presentMenuViewControllerWithAnimatedApperance:NO];
    }
    
    [self.containerViewController panGestureRecognized:recognizer];
}

#pragma mark -
#pragma mark Rotation handler

- (BOOL)shouldAutorotate
{
    return self.contentViewController.shouldAutorotate;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if ([self.delegate conformsToProtocol:@protocol(REFrostedViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(frostedViewController:willAnimateRotationToInterfaceOrientation:duration:)])
        [self.delegate frostedViewController:self willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (self.menuVisible) {
        if (self.automaticSize) {
            if (self.direction == REFrostedViewControllerDirectionLeft || self.direction == REFrostedViewControllerDirectionRight)
                self.calculatedMenuViewSize = CGSizeMake(self.contentView.bounds.size.width - 50.0f, self.contentView.bounds.size.height);
            
            if (self.direction == REFrostedViewControllerDirectionTop || self.direction == REFrostedViewControllerDirectionBottom)
                self.calculatedMenuViewSize = CGSizeMake(self.contentView.bounds.size.width, self.contentView.bounds.size.height - 50.0f);
        } else {
            self.calculatedMenuViewSize = CGSizeMake(_menuViewSize.width > 0 ? _menuViewSize.width : self.contentView.bounds.size.width,
                                                     _menuViewSize.height > 0 ? _menuViewSize.height : self.contentView.bounds.size.height);
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (!self.menuVisible) {
        self.calculatedMenuViewSize = CGSizeZero;
    }
}

@end
