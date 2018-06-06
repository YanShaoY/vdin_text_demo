//
//  xunFeiMscPopMenuView.m
//  Demo
//
//  Created by YanSY on 2018/5/11.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "xunFeiMscPopMenuView.h"
#import "UIButton+ImageTitleSpacing.h"
#import "UIImage+Extension.h"
#define BackViewWidth SCREENWIDTH * 0.25
#define AnimateDuration 0.3
#define ButtonHeight 100

@interface xunFeiMscPopMenuView (){
    NSArray * imageList;
    NSArray * nameList;
}

/// 是否显示视图
@property (nonatomic , assign) BOOL isOpen;
/// 记录选中的按钮
@property (nonatomic , assign) NSUInteger selectedIndex;
/// 点击按钮后的block
@property (nonatomic , strong) menuBtClickedBlock Myblock;
/// 存储按钮列表
@property (nonatomic , strong) NSMutableArray * buttonList;
/// 背景视图
@property (nonatomic , strong) UIView * backView;

@end

@implementation xunFeiMscPopMenuView

#pragma mark -- 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configuration];
        [self addUI];
        [self addConstraint];
    }
    return self;
}

#pragma mark -- 子类方法
- (void)configuration{
    
    self.backgroundColor = [UIColor clearColor];
    
    self.backView = [[UIView alloc]init];
    self.backView.backgroundColor = UIColorFromRGBA(0x999999, 0.6);
    self.backView.layer.masksToBounds = YES;
    self.backView.layer.cornerRadius = 20.f;
    
    imageList = @[[UIImage imageNamed:@"recording"],
                  [UIImage imageNamed:@"play"],
                  [UIImage imageNamed:@"grammar"],
                  [UIImage imageNamed:@"review"],
                  [UIImage imageNamed:@"cancel_blue"]];
    
    nameList = @[@"听写",
                 @"合成",
                 @"翻译",
                 @"原生",
                 @"取消"];
    
    self.buttonList = [NSMutableArray arrayWithCapacity:imageList.count];
}

- (void)addUI{
    
    [KEYWINDOW addSubview:self];
    [self addSubview:self.backView];
    [KEYWINDOW bringSubviewToFront:self];
    
    for (int i = 0; i < imageList.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        
        [button setTitle:nameList[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:UIColorFromRGBA(0xffffff, 1) forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGBA(0xB2B2B2, 1) forState:UIControlStateHighlighted];
        [button setTitleColor:UIColorFromRGBA(0x1296db, 1) forState:UIControlStateSelected];
        
        UIImage * img = [imageList[i]thumbnailWithSize:CGSizeMake(64, 64)];
        [button setImage:img forState:UIControlStateNormal];
        [button setImage:[[UIImage imageNamed:@"menuBtSelect"]thumbnailWithSize:CGSizeMake(64, 64)] forState:UIControlStateSelected];
        
        [button addTarget:self action:@selector(onMenuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonList addObject:button];
        [self.backView addSubview:button];
    }
}

- (void)addConstraint{
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(KEYWINDOW);
    }];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_right).offset(0);
        make.centerY.equalTo(self.mas_centerY).offset(0);
        make.width.mas_equalTo(BackViewWidth);
    }];
    
    
    for (int i = 0; i < self.buttonList.count; i++) {
        UIButton * button = self.buttonList[i];
        if (i == 0) {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.backView.mas_top).offset(20);
                make.left.right.equalTo(self.backView);
                make.height.mas_equalTo(ButtonHeight);
            }];
        }else if (i == self.buttonList.count -1){
            UIButton * buttonTop = self.buttonList[i-1];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(buttonTop.mas_bottom).offset(10);
                make.left.right.equalTo(self.backView);
                make.height.mas_equalTo(ButtonHeight);
                make.bottom.equalTo(self.backView.mas_bottom).offset(-20);
            }];
        }else{
            UIButton * buttonTop = self.buttonList[i-1];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(buttonTop.mas_bottom).offset(10);
                make.left.right.equalTo(self.backView);
                make.height.mas_equalTo(ButtonHeight);
            }];
        }
        [button layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:10];
    }
}

#pragma mark -- 按钮点击响应
- (void)onMenuButtonClick:(UIButton*)button
{
    if (button.tag == self.buttonList.count-1) {
        self.Myblock(self.selectedIndex);
    }else{
        self.Myblock(button.tag);
        
        UIButton * bt = self.buttonList[self.selectedIndex];
        bt.userInteractionEnabled = YES;
        bt.selected = NO;
        
        button.selected = YES;
        button.userInteractionEnabled = NO;
    }
    
    [self dismissMenuWithSelection:button];
}

- (void)dismissMenuWithSelection:(UIButton*)button
{
    [UIView animateWithDuration:AnimateDuration
                          delay:0.0f
         usingSpringWithDamping:.2f
          initialSpringVelocity:10.f
                        options:0
                     animations:^{
                         
                         button.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self dismissMenu];
                         }
                     }];
}

#pragma mark -- 手势响应
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    self.Myblock(self.selectedIndex);
    [self dismissMenu];
}

/**
 弹窗菜单栏弹窗
 
 @param index 默认选中按钮的位置
 @param block 返回选中按钮的位置
 */
+ (void)showXFMscPopMenuViewWithType:(NSUInteger)index WithBlock:(menuBtClickedBlock)block{
    
    xunFeiMscPopMenuView * view = [[xunFeiMscPopMenuView alloc]init];
    if (block) {
        view.Myblock = block;
    }
    if (index) {
        view.selectedIndex = index;
    }
    [view showMenu];
}

- (void)showMenu
{
    if (!_isOpen)
    {
        _isOpen = !_isOpen;
        [self performSelectorInBackground:@selector(performOpenAnimation) withObject:nil];
    }
}
#pragma mark -- 隐藏视图
- (void)dismissMenu
{
    if (_isOpen)
    {
        _isOpen = !_isOpen;
        [self performDismissAnimation];
    }
}

#pragma mark - Animations
- (void)performDismissAnimation
{
    [UIView animateWithDuration:AnimateDuration animations:^{
        self.backView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)performOpenAnimation
{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        for (UIButton *button in self.buttonList){
            button.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, BackViewWidth, 0);
            if (button.tag == self.selectedIndex) {
                button.selected = YES;
                button.userInteractionEnabled = NO;
            }
        }
        
        [UIView animateWithDuration:AnimateDuration animations:^{
            self.backView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -BackViewWidth, 0);
        }];
    });
    
    
    for (UIButton *button in _buttonList)
    {
        [NSThread sleepForTimeInterval:0.02f];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:AnimateDuration
                                  delay:0.2f
                 usingSpringWithDamping:0.4f
                  initialSpringVelocity:8.0f
                                options:0
                             animations:^{
                                 button.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
                             }
                             completion:nil];
        });
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
