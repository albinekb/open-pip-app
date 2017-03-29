//
//  PIPViewControllerDelegate.h
//  open-pip
//

#ifndef PIPViewControllerDelegate_h
#define PIPViewControllerDelegate_h

@class PIPViewController;

@protocol PIPViewControllerDelegate <NSObject>
@optional
- (BOOL)pipShouldClose:(PIPViewController *)pip;
- (void)pipDidClose:(PIPViewController *)pip;
- (void)pipActionPlay:(PIPViewController *)pip;
- (void)pipActionPause:(PIPViewController *)pip;
- (void)pipActionStop:(PIPViewController *)pip;
@end

#endif /* PIPViewControllerDelegate_h */
