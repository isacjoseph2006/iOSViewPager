//
//  TabBarController.m
//  ViewPager
//
//  Created by Isac Joseph on 05/12/16.
//  Copyright © 2016 MSI Soft. All rights reserved.
//

#import "TabBarController.h"

#define TABBARHEIGHT  49
#define RANDOMCONSTANT  1683

@interface TabBarController ()
{
    CGFloat totalWidth;
    NSMutableArray *individualWidthsArray;
    UIScrollView *scrollView;
    UIView *contentView;
    UIView *selectionView;
    UIView *blueIndicator;
}

@property (strong, nonatomic) UIColor *viewPagerColor;
@property (strong, nonatomic) UIColor *viewPagerSelectionColor;
@property (strong, nonatomic) UIColor *viewPagerTextColor;
@property (assign, nonatomic) int viewPagerTextSize;


@end

@implementation TabBarController


- (void)viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];
    [self setDefaults];
    [super viewDidLoad];
    [self setUpViews];
    [self setupSwipeGestureRecognizer];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setDefaults
{
    _viewPagerColor = (_viewPagerColor)?_viewPagerColor:[UIColor lightGrayColor];
    _viewPagerSelectionColor = (_viewPagerSelectionColor)?_viewPagerSelectionColor:[UIColor blueColor];
    _viewPagerTextColor = (_viewPagerTextColor)?_viewPagerTextColor:[UIColor whiteColor];
    _viewPagerTextSize = (_viewPagerTextSize)?_viewPagerTextSize:12;
}


-(void)setUpViews
{
    if (self.viewControllers.count == 0)
    {
        return;
    }
    
    //Creating a mask view to set color for status bar
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
    view.backgroundColor = _viewPagerColor;
    [[[UIApplication sharedApplication] delegate].window.rootViewController.view addSubview:view];
    
    //Calculate sizes
    [self calculateMaxContentView];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGRect tabBarFrame = CGRectMake(0, 20, width, TABBARHEIGHT);
    self.tabBar.frame = tabBarFrame;
    
    //Scroll view
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, TABBARHEIGHT)];
    scrollView.bounces = FALSE;
    scrollView.showsHorizontalScrollIndicator = FALSE;
    
    //Scroll view's content view
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalWidth, TABBARHEIGHT)];
    contentView.backgroundColor = _viewPagerColor;
    
    //Selection view
    selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [individualWidthsArray[0] floatValue], TABBARHEIGHT)];
    selectionView.backgroundColor = [UIColor clearColor];
    
    //Selection underline
    blueIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, TABBARHEIGHT - 5,[individualWidthsArray[0] floatValue], 5)];
    blueIndicator.backgroundColor = _viewPagerSelectionColor;
    
    [selectionView addSubview:blueIndicator];
    [contentView addSubview:selectionView];
    
    CGFloat startPos = 0;
    for (int i = 0; i < individualWidthsArray.count; i++)
    {
        NSNumber *value = individualWidthsArray[i];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(startPos, 0, value.floatValue, TABBARHEIGHT)];
        [btn setTitle:self.viewControllers[i].title forState:UIControlStateNormal];
        [btn setTitleColor:_viewPagerTextColor forState:UIControlStateNormal];
        btn.tag = i + RANDOMCONSTANT;
        btn.backgroundColor = [UIColor clearColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:_viewPagerTextSize];
        [btn addTarget:self action:@selector(buttonSelectedByUser:) forControlEvents:UIControlEventTouchUpInside];
        startPos = startPos + value.floatValue;
        [contentView addSubview:btn];
    }
    
    
    [scrollView setContentSize:CGSizeMake(totalWidth, TABBARHEIGHT)];
    [scrollView addSubview:contentView];
    [self.tabBar addSubview:scrollView];
}


///Calculating sizes
-(void)calculateMaxContentView
{
    individualWidthsArray = [[NSMutableArray alloc] init];
    CGFloat totalWidthCalculated = 0;
    for (UIViewController *vc in self.viewControllers)
    {
        NSString *title = vc.title;
        CGFloat textWidth = [self getWidthOfString:title];
        totalWidthCalculated += textWidth;
        [individualWidthsArray addObject:[NSNumber numberWithDouble:textWidth]];
    }
    totalWidth = totalWidthCalculated;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (totalWidth < screenWidth)
    {
        CGFloat difference = screenWidth - totalWidth;
        CGFloat individualDifference = difference / self.viewControllers.count;
        
        NSMutableArray *newValuesArray = [[NSMutableArray alloc] init];
        for (NSNumber *value in individualWidthsArray)
        {
            CGFloat newValue = value.floatValue + individualDifference;
            [newValuesArray addObject:[NSNumber numberWithFloat:newValue]];
        }
        individualWidthsArray = newValuesArray;
        totalWidth = screenWidth;
    }
}


//User clicks a button
-(void)buttonSelectedByUser:(UIButton *)sender
{
    CGRect newSelectionViewFrame = CGRectMake(sender.frame.origin.x,0, sender.frame.size.width,TABBARHEIGHT);
    CGRect newSelectionLineViewFrame = CGRectMake(0,44, sender.frame.size.width,5);
    
    [UIView animateWithDuration:0.1 animations:^{
        
        selectionView.frame = newSelectionViewFrame;
        blueIndicator.frame = newSelectionLineViewFrame;
        [scrollView scrollRectToVisible:sender.frame animated:NO];
    }];
    self.selectedIndex = sender.tag - RANDOMCONSTANT;
}

//Size for text
-(CGFloat)getWidthOfString:(NSString *)string
{
    CGSize yourLabelSize = [string sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:_viewPagerTextSize]}];
    return yourLabelSize.width + 30;
}


- (void)setupSwipeGestureRecognizer
{
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)];
    swipeGestureLeft.direction = (UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:swipeGestureLeft];
    
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)];
    swipeGestureRight.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self.view addGestureRecognizer:swipeGestureRight];
}

-(void)swipedScreen:(UISwipeGestureRecognizer*)gesture
{
    NSLog(@"%lu",(unsigned long)gesture.direction);
    
    NSUInteger currentIndex = self.selectedIndex;
    
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if (self.viewControllers.count - 1 == currentIndex)
        {
            return;
        }
        currentIndex++;
    }
    if(gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if (currentIndex == 0)
        {
            return;
        }
        currentIndex--;
    }
    self.selectedIndex = currentIndex;
    
    UIButton *btn = [contentView viewWithTag:RANDOMCONSTANT + currentIndex];
    
    [self buttonSelectedByUser:btn];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
