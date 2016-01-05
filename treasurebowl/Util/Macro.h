//
//  Macro.h
//  treasurebowl
//
//  Created by AtSu on 2015/8/24.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#ifndef treasurebowl_Macro_h

#define DEBUG_MODE 1
#define C_FAIL(X) if(DEBUG_MODE) NSLog(@"%s failed!", X)
#define C_FAIL_CUZ(X, Y) if(DEBUG_MODE)  NSLog(@"%s failed : %s", X, Y)
#define DE_LOG(X, ...) if(DEBUG_MODE) NSLog(@X, ##__VA_ARGS__)
#define LOCAL(X) NSLocalizedString(@X, nil)
#define treasurebowl_Macro_h

#define ALERT_SERVER_ERROR \
[Util makeAlertWithTitle: LOCAL("Oops!") \
              andMessage: LOCAL("Cannot connect to server, please try it later ...") \
                 withTag: normal_alert \
                Delegate: self]
#define ALERT_DEVICE_NOT_CONNECTED \
[Util makeAlertWithTitle: LOCAL("Oops!") \
              andMessage: LOCAL("Your device is not connected to the network")\
                 withTag: stopHUD_alert\
                Delegate: self]


#endif