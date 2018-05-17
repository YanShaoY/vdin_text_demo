//
//  SideMenuVC.m
//  Demo
//
//  Created by YanSY on 2017/12/14.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "SideMenuControl.h"
#import "UIView+FindViewController.h"

#define menuCellIdentifier  @"menuCellIdentifier"
#define rootCellIdentifier  @"rootCellIdentifier"

@interface SideMenuControl ()<UITableViewDelegate, UITableViewDataSource>{
    
    CGFloat menuPercentage;
    BOOL _isScrollDown;
}
/**
 主视图
 */
@property (nonatomic , strong) UITableView * rootTableView;
/**
 菜单栏
 */
@property (nonatomic , strong) UITableView * menuTableView;
/**
 拖拽手势
 */
@property (nonatomic , strong) UIPanGestureRecognizer * pan;
/**
 点击手势
 */
@property (nonatomic , strong) UITapGestureRecognizer * tap;
/**
 边缘手势
 */
@property (nonatomic , strong) UIScreenEdgePanGestureRecognizer * screenEdgePan;
/**
 中心视图控制器
 */
@property (nonatomic , weak, readwrite) UIViewController *centerViewController;

@end

@implementation SideMenuControl

#pragma mark -- 初始化
- (instancetype)initWithFrame:(CGRect)frame withSource:(UIViewController *)srcController percentageToMenu:(CGFloat)percentage{
    self = [super initWithFrame:frame];
    if (self) {
        menuPercentage              = percentage;
        self.centerViewController   = srcController;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (pauseGuideAnimation) name: UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

#pragma mark -- set methods
- (void)setDelegate:(id<SideMenuControlDelegate>)delegate{
    _delegate = delegate;
    [self setNeedsLayout];
    [self showShadow];
    NSIndexPath * moveToIndexPath = [[self.rootTableView indexPathsForVisibleRows] firstObject];
    [self.menuTableView selectRowAtIndexPath:moveToIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

/**
 显示侧边栏阴影
 */
- (void)showShadow {
    if (!self.centerViewController.view) { return; }
    self.centerViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.centerViewController.view.layer.shadowOffset = CGSizeMake(6, 6);
    self.centerViewController.view.layer.shadowOpacity = 0.7;
    self.centerViewController.view.layer.shadowRadius = 6.f;
    
    [self.centerViewController.view removeGestureRecognizer:self.screenEdgePan];
    [self.centerViewController.view removeGestureRecognizer:self.pan];
    [self.centerViewController.view removeGestureRecognizer:self.tap];

    [self.centerViewController.view addGestureRecognizer:self.screenEdgePan];
}

/**
 隐藏侧边栏阴影
 */
- (void)hiddenShadow {
    if (!self.centerViewController.view) { return; }
    
    self.centerViewController.view.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.centerViewController.view.layer.shadowOffset = CGSizeMake(0, 0);
    self.centerViewController.view.layer.shadowOpacity = 0;
    self.centerViewController.view.layer.shadowRadius = 0;
    
    [self.centerViewController.view removeGestureRecognizer:self.screenEdgePan];
    [self.centerViewController.view removeGestureRecognizer:self.pan];
    [self.centerViewController.view removeGestureRecognizer:self.tap];

    [self.centerViewController.view addGestureRecognizer:self.pan];
    [self.centerViewController.view addGestureRecognizer:self.tap];
}


#pragma mark -- private methods
- (void)pauseGuideAnimation{
    
    __block CGFloat menuPercen = menuPercentage;
    [UIView animateWithDuration:0.2f animations:^{
        
        CGAffineTransform rightScopeTransform = CGAffineTransformTranslate(KEYWINDOW.transform, SCREENWIDTH * menuPercen, 0);
        if (self.centerViewController.view.frame.origin.x > SCREENWIDTH * 0.4) {
            self.centerViewController.view.transform = rightScopeTransform;
            self.menuTableView.tx = self.centerViewController.view.tx * (1/menuPercen-1);
            [self hiddenShadow];
        } else {
            self.centerViewController.view.transform = CGAffineTransformIdentity;
            self.menuTableView.tx = self.centerViewController.view.tx * (1/menuPercen-1);
            [self showShadow];
        }
        
    }];
}

- (void)handlePanAction:(UIPanGestureRecognizer *)sender{
    
    CGPoint translation = [sender translationInView:sender.view];
    
    sender.view.transform = CGAffineTransformTranslate(sender.view.transform, translation.x, 0);
    self.menuTableView.tx = sender.view.tx * (1/menuPercentage-1);
    [sender setTranslation:CGPointZero inView:sender.view];
    
    CGAffineTransform rightScopeTransform = CGAffineTransformTranslate(KEYWINDOW.transform, SCREENWIDTH * menuPercentage, 0);
    
    if (sender.view.tx > rightScopeTransform.tx) {
        
        sender.view.transform = rightScopeTransform;
        self.menuTableView.tx = sender.view.tx * (1/menuPercentage-1);
        
    } else if (sender.view.tx < 0.0) {
        sender.view.transform = CGAffineTransformTranslate(KEYWINDOW.transform, 0, 0);
        self.menuTableView.tx = sender.view.tx * (1/menuPercentage-1);
    }
    // 拖拽结束时
    __block CGFloat menuPercen = menuPercentage;
    if (sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.3f animations:^{
            if (sender.view.frame.origin.x > SCREENWIDTH * 0.4) {
                sender.view.transform = rightScopeTransform;
                self.menuTableView.tx = sender.view.tx * (1/menuPercen-1);
                [self hiddenShadow];
            } else {
                sender.view.transform = CGAffineTransformIdentity;
                self.menuTableView.tx = sender.view.tx * (1/menuPercen-1);
                [self showShadow];
            }
        }];
    }
}

- (void)handleTapAction:(UITapGestureRecognizer *)sender{
    CGAffineTransform centerVCTrans = self.centerViewController.view.transform;
    if (centerVCTrans.tx < SCREENWIDTH * menuPercentage) {
        return;
    }else{
        [self resetShowType:SideMenu_Tab_Type_Root];
    }
}

#pragma mark - tableView 数据源代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfListForTab:)]) {
        SideMenu_Tab_Type type = (tableView == self.rootTableView) ? SideMenu_Tab_Type_Root : SideMenu_Tab_Type_menu;
        return [_delegate numberOfListForTab:type];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell  * cell;
    if (_delegate && [_delegate respondsToSelector:@selector(viewForTabType:andTabRow:)]) {
        
        SideMenu_Tab_Type type = (tableView == self.rootTableView) ? SideMenu_Tab_Type_Root : SideMenu_Tab_Type_menu;
        NSString * identifier = (tableView == self.rootTableView) ? rootCellIdentifier : menuCellIdentifier;

        UIView * showView = [_delegate viewForTabType:type andTabRow:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:0.50];
        
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:showView];
        
        [showView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.left.equalTo(cell.contentView);
        }];
        [cell layoutIfNeeded];
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.rootTableView) {
        return self.bounds.size.height;
    }else{
        return 40;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.rootTableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        [self.rootTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self resetShowType:SideMenu_Tab_Type_Root];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectAtRowNumber:forTabType:)]) {
        SideMenu_Tab_Type type = (tableView == self.rootTableView) ? SideMenu_Tab_Type_Root : SideMenu_Tab_Type_menu;
        [_delegate didSelectAtRowNumber:indexPath.row forTabType:type];
    }else{
        return;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.menuTableView) return;
    if (!self.rootTableView.dragging) return;
    
    static CGFloat lastOffsetY = 0;
    
    _isScrollDown = lastOffsetY < scrollView.contentOffset.y;
    lastOffsetY = scrollView.contentOffset.y;
    
    NSUInteger sorollY = (NSUInteger)lastOffsetY % (NSUInteger)SCREENHEIGHT;

    NSUInteger indexRow = 0;
    if (sorollY >= SCREENHEIGHT/2) {
        indexRow = sorollY/SCREENHEIGHT+1;
    }else{
        indexRow = sorollY/SCREENHEIGHT;
    }
    // 用户拖拽向下滑动
//    if (_isScrollDown) {
//        // ==
//        if (sorollY >= SCREENHEIGHT/2) {
//            indexRow = sorollY/SCREENHEIGHT+1;
//        }else{
//            indexRow = sorollY/SCREENHEIGHT;
//        }
//        BaseLog(@"应该滑动到的行数%ld",indexRow);
//
//    }
//
//    // 用户拖拽向上滑动
//    if (!_isScrollDown) {
//        // +1
//        if (sorollY >= SCREENHEIGHT/2) {
//            indexRow = sorollY/SCREENHEIGHT+1;
//        }else{
//            indexRow = sorollY/SCREENHEIGHT;
//        }
//        BaseLog(@"应该滑动到的行数%ld",indexRow);
//
//    }
    
    
    NSIndexPath * moveToIndexPath = [NSIndexPath indexPathForRow:indexRow inSection:0];
    [self.menuTableView selectRowAtIndexPath:moveToIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self.rootTableView scrollToRowAtIndexPath:moveToIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

//    NSIndexPath * path =  [self.rootTableView indexPathForRowAtPoint:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y)];
    if (_delegate && [_delegate respondsToSelector:@selector(didScrollAtRowNumber:forTabType:)]) {
        [_delegate didScrollAtRowNumber:indexRow forTabType:SideMenu_Tab_Type_Root];
    }else{
        return;
 }
    
}

#pragma mark -- public methods
- (void)resetShowType:(SideMenu_Tab_Type)showType{
    if (!self.centerViewController.view)  return;
    
    CGAffineTransform rightScopeTransform = CGAffineTransformTranslate(KEYWINDOW.transform, SCREENWIDTH * menuPercentage, 0);
    
    __block CGFloat menuPercen = menuPercentage;
    switch (showType) {
        case SideMenu_Tab_Type_menu:{
            [UIView animateWithDuration:0.3f animations:^{
                self.centerViewController.view.transform = rightScopeTransform;
                self.menuTableView.tx = self.centerViewController.view.tx * (1/menuPercen-1);
                [self hiddenShadow];
            }];
        }
            break;
            
        case SideMenu_Tab_Type_Root:{
            [UIView animateWithDuration:0.3f animations:^{
                self.centerViewController.view.transform = CGAffineTransformIdentity;
                self.menuTableView.tx = self.centerViewController.view.tx * (1/menuPercen-1);
                [self showShadow];
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)scrollTabWithType:(SideMenu_Tab_Type)tableType toRowNumber:(NSUInteger)row{
    
    if (!self.centerViewController.view) return;
    
    NSIndexPath *moveToIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
    UITableView * tableView = (tableType == SideMenu_Tab_Type_Root) ? self.rootTableView : self.menuTableView;
    
    [tableView scrollToRowAtIndexPath:moveToIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

    if (tableType == SideMenu_Tab_Type_Root) {
        [tableView deselectRowAtIndexPath:moveToIndexPath animated:YES];
    }else{
        [tableView selectRowAtIndexPath:moveToIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
    
}


#pragma mark -- 懒加载
- (UITableView *)rootTableView{
    if (!_rootTableView) {
        _rootTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_rootTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:rootCellIdentifier];
        
        _rootTableView.dataSource = self;
        _rootTableView.delegate = self;
        
        _rootTableView.backgroundColor = [UIColor whiteColor];
        _rootTableView.tableFooterView = [[UIView alloc] init];
        
        _rootTableView.bounces                       = NO;
        _rootTableView.scrollEnabled                 = YES;
        _rootTableView.showsVerticalScrollIndicator  = NO;
        _rootTableView.allowsSelection               = NO;
        
        _rootTableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Back"]];
        [self addSubview:_rootTableView];
        if (@available(iOS 11.0, *)) {
            _rootTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _rootTableView;
}

- (UITableView *)menuTableView {
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_menuTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:menuCellIdentifier];
  
        _menuTableView.dataSource = self;
        _menuTableView.delegate = self;
        
        _menuTableView.backgroundColor = [UIColor whiteColor];
        _menuTableView.tableFooterView = [[UIView alloc] init];

        _menuTableView.bounces                       = NO;
        _menuTableView.scrollEnabled                 = YES;
        _menuTableView.showsVerticalScrollIndicator  = NO;
        [_menuTableView setSeparatorColor:UIColorFromRGBA(0xD0EBF9, 1)];
        
        _menuTableView.backgroundView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"cloud"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

        [KEYWINDOW addSubview:_menuTableView];
        [KEYWINDOW sendSubviewToBack:_menuTableView];
        
        CGFloat height = 44+20;
        if (@available(iOS 11.0, *)) {
            _menuTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            height += self.centerViewController.view.safeAreaInsets.bottom;
        }
        _menuTableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, height)];
    }
    return _menuTableView;
}

- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanAction:)];
    }
    return _pan;
}

- (UITapGestureRecognizer *)tap{
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapAction:)];
    }
    return _tap;
}

- (UIScreenEdgePanGestureRecognizer *)screenEdgePan{
    if (!_screenEdgePan) {
        _screenEdgePan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanAction:)];
        _screenEdgePan.edges = UIRectEdgeLeft;
    }
    return _screenEdgePan;
}

#pragma mark -- 刷新UI显示
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.rootTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    
    __block CGFloat menuPercen = menuPercentage;
    [self.menuTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(KEYWINDOW.mas_top).offset(0);
        make.bottom.equalTo(KEYWINDOW.mas_bottom).offset(0);
        make.left.equalTo(KEYWINDOW.mas_left).offset(-SCREENWIDTH * (1 - menuPercen));
        make.width.mas_equalTo(SCREENWIDTH);
    }];
}

- (void)dealloc
{
    [self.centerViewController.view removeGestureRecognizer:self.screenEdgePan];
    [self.centerViewController.view removeGestureRecognizer:self.pan];
    [self.centerViewController.view removeGestureRecognizer:self.tap];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end







