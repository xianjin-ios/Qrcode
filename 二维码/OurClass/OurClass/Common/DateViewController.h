

#import <UIKit/UIKit.h>
@protocol DateViewControllerDelegate;

@interface DateViewController : UIViewController


@property(nonatomic,assign) id<DateViewControllerDelegate> delegate;
@property(nonatomic,assign) BOOL hideOK;
@property(nonatomic,strong) UIDatePicker *picker;
@property(nonatomic,assign)BOOL timeFormat;
@property ( nonatomic, assign) int tag;


@end



@protocol DateViewControllerDelegate <NSObject>
-(void)selectFinish:(DateViewController*)ctrl withDate:(NSString*)date;
-(void)selectCancel:(DateViewController*)ctrl;

@end