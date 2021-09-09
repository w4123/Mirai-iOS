//
//  ViewController.m
//  mirai
//
//  Created by Zhao Zhongqi on 2021/8/15.
//

#import "ViewController.h"
#include "javalauncher_api.h"
#include <stdio.h>
#include <unistd.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *mainText;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *enterText;

@end

@implementation ViewController

int stdin_pipefd[2];
int stdout_pipefd[2];

void startMirai(void) {
    jl_initialize([[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"lib"] UTF8String]);
    chdir([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject UTF8String]);
    char buffer[1000];
    buffer[0] = 0;
    strcat(buffer, "-Djava.class.path=");
    strcat(buffer, [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"lib/mirai-console-2.7.0.jar"] UTF8String]);
    strcat(buffer, ":");
    strcat(buffer, [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"lib/mirai-console-terminal-2.7.0.jar"] UTF8String]);
    strcat(buffer, ":");
    strcat(buffer, [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"lib/mirai-core-all-2.7.0.jar"] UTF8String]);
    char* options[] = { "-Xmx256M", "-XX:-UseCompressedClassPointers", buffer };
    jl_createJavaVM(options, 3, NULL, NULL);
    char* miraiOptions[] = { "--no-ansi" };
    jl_callJava("net/mamoe/mirai/console/terminal/MiraiConsoleTerminalLoader", "main", "([Ljava/lang/String;)V", miraiOptions, 1, NULL, NULL);
}

-(void)keyboardWillShow:(NSNotification *)noti {
    CGRect keyboardSize = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - keyboardSize.size.height);

}

-(void)keyboardWillHide:(NSNotification *)noti {
    CGRect keyboardSize = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + keyboardSize.size.height);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_mainText setText:@"Mirai iOS 正在启动中，请耐心等待\n"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    int stdout_bk = dup(fileno(stdout));
    pipe(stdout_pipefd);
    dup2(stdout_pipefd[1], fileno(stdout));
    
    int stdin_bk = dup(fileno(stdin));
    pipe(stdin_pipefd);
    dup2(stdin_pipefd[0], fileno(stdin));
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        startMirai();
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char buf[1024];
        while(1) {
            size_t sz = read(stdout_pipefd[0], buf, 1000);
            buf[sz] = 0;
            NSString* s = [NSString stringWithUTF8String:buf];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (s) {
                    [self->_mainText setText:[self->_mainText.text stringByAppendingString:s]];
                }
            });

            [NSThread sleepForTimeInterval:0.1];
        }
    });

}

- (IBAction)onClick:(id)sender {
    if (_enterText.text) {
        NSString* command = [_enterText.text stringByAppendingString:@"\n"];
        [self->_mainText setText:[self->_mainText.text stringByAppendingString:command]];
        write(stdin_pipefd[1], [command UTF8String], [command length]);
        [_enterText setText:@""];
    }

}

- (IBAction)onReturnPressed:(UITextField *)sender {
    if (_enterText.text) {
        NSString* command = [_enterText.text stringByAppendingString:@"\n"];
        [self->_mainText setText:[self->_mainText.text stringByAppendingString:command]];
        write(stdin_pipefd[1], [command UTF8String], [command length]);
        [_enterText setText:@""];
    }
}


@end
