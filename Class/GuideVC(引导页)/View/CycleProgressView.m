//
//  CycleProgressView.m
//  Demo
//
//  Created by YanSY on 2017/11/29.
//  Copyright © 2017年 YanSY. All rights reserved.
//

#import "CycleProgressView.h"

#define CountTitleFont 50
#define PercentTitleFont 30
#define Message "......\nREADY...\nTRY TO FACE RECOGNITION...\nIS TO IDENTIFY...\nUPDATE THE DATA...\nCOMPLETE..."

@interface CycleProgressView ()

#pragma mark -- 默认参数
/// 进度
@property (nonatomic , assign) CGFloat progress;
/// 是否有动画
@property (nonatomic , assign) BOOL needAnimation;
/// 动画时长
@property (nonatomic, assign) CGFloat animationDuration;
/// 数字递增间隔时间
@property (nonatomic, strong) dispatch_source_t timer;

#pragma mark -- 控件
@property (nonatomic, strong) UILabel * countLabel;
@property (nonatomic, strong) UILabel * percentLabel;
@property (nonatomic, strong) UITextView * nslogTextView;

@end

@implementation CycleProgressView

#pragma mark -- 初始化
- (instancetype)init{
    if (self = [super init]) {
        [self configuration];
    }
    return self;
}

#pragma mark -- 默认配置
- (void)configuration{
    
    [self addSubview:self.countLabel];
    [self addSubview:self.percentLabel];
    [self addSubview:self.nslogTextView];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(60);
    }];
    
    [self.percentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.countLabel.mas_right);
        make.right.equalTo(self.mas_right);
        make.width.mas_equalTo(25);
        make.bottom.equalTo(self.countLabel.mas_bottom);
    }];
    
    [self.nslogTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.countLabel.mas_bottom).offset(0);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(80);
        make.bottom.equalTo(self.mas_bottom);
    }];
}

#pragma mark -- 启动动画
- (void)startAnimationWithProgess:(CGFloat)progess andAnimation:(CGFloat)animation{
    self.progress = progess ? progess : 1;
    self.needAnimation = animation ? YES : NO;
    self.animationDuration = animation ? animation : 3;
    
    __block float _numText = 0.0f;
    __block UITextView * blockText = self.nslogTextView;
    @weakify(self);
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, quene);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), NSEC_PER_SEC * (self.animationDuration/(_progress * 100)), 0);
    dispatch_source_set_event_handler(_timer, ^{
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableString * text = [NSMutableString stringWithFormat:@"%s",Message];
            int cut = 2 * roundf(_numText);
            if (cut < text.length) {
                blockText.text = [text substringToIndex:cut];

            }else{
                blockText.text = text;
            }
            
            [blockText scrollRangeToVisible:NSMakeRange(blockText.text.length, 1)];

            if (_numText< _progress * 100) {
                _countLabel.text = [NSString stringWithFormat:@"%.1f",_numText];
                _numText+= 0.1;
            }
            else
            {
                _countLabel.text = [NSString stringWithFormat:@"%.1f",_progress * 100];
                blockText.text = text;
                [blockText scrollRangeToVisible:NSMakeRange(blockText.text.length, 1)];
                blockText.scrollEnabled = NO;
                dispatch_source_cancel(_timer);
                [self startAnimationWithProgess:_progress andAnimation:self.animationDuration];
            }
            
        });


    });
    //启动源
    dispatch_resume(_timer);
    
}

#pragma mark ******** setter / getter
- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc]init];
        _countLabel.textColor = UIColorFromRGBA(0x1be9f6, 1);
        _countLabel.font = [UIFont systemFontOfSize:CountTitleFont];
        _countLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _countLabel;
}

- (UILabel *)percentLabel{
    if (!_percentLabel) {
        _percentLabel = [[UILabel alloc]init];
        _percentLabel.text = @"%";
        _percentLabel.textColor = UIColorFromRGBA(0x1be9f6, 1);
        _percentLabel.font = [UIFont systemFontOfSize:PercentTitleFont];
        _percentLabel.textAlignment = NSTextAlignmentRight;

    }
    return _percentLabel;
}

- (UITextView *)nslogTextView{
    if (!_nslogTextView) {
        _nslogTextView = [[UITextView alloc]init];
        _nslogTextView.textColor = UIColorFromRGBA(0x1cb1f6, 1);
        _nslogTextView.font = [UIFont systemFontOfSize:12];
        _nslogTextView.textAlignment = NSTextAlignmentLeft;
        _nslogTextView.editable = NO;
        _nslogTextView.selectable = NO;
        _nslogTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _nslogTextView.scrollEnabled = YES;
        _nslogTextView.showsVerticalScrollIndicator = NO;
        _nslogTextView.layoutManager.allowsNonContiguousLayout = NO;
        _nslogTextView.backgroundColor = [UIColor clearColor];
    }
    return _nslogTextView;
}

#pragma mark -- 注销
- (void)dealloc{
    NSLog(@"界面释放");
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
