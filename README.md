**Note: Requires manual import of DTCoreText**
**SST Announcer**
==========================
Made by StatiX Industries  

#NAME:
* SST Announcer

#SYNOPSIS:
The Application is used for fetching RSS feeds over the Internet  
Also, the app can push notifications to the user's iDevice (needs custom UrbanAirship plist to be inserted with data)
Feed source: http://sst-students2013.blogspot.com/feeds/posts/default (Note that date can change dynamically)
  
1. Has inbuilt table that displays RSS feeds.
2. Has loading indicator
3. Is able to display multiple categories of the blog (with static cells)
4. Pushes notifications to the user when the feed is updated
  

#AVAILABILITY:
The App is only usable on the UNIX Darwin ARMv7 iOS 7.0+ platform
Devices compatible include the iPhone 4 and up, iPad 2 and up as well as iPod Touch 4rd Gen and up
Compiles on iOS SDK 7.0


#DESCRIPTION:
* The Application is made for fetching RSS feeds from the abovementioned URL. Other than that, it also pushes notifications to the user's iDevice via UrbanAirship's push notification function.
  
#AUTHOR(S):
StatiX Industries:
* Lead Developer and Debugger: Pan Ziyue
* Graphics Designer: Christopher Kok
* Beta Tester: Liaw Xiao Tao
  

#CAVEATS:
* App does NOT compile on 64 bit architectures, please note
* The Xcode Project file must be opened in Xcode 5 for iOS 7
* You need to import the DTCoreText library manually or it will NOT compile!

#DEPENDENCIES:
* SVProgressHUD
* UrbanAirship iOS Library
* DTCoreText


#LICENSE:
* GNU Public License v2


FINAL NOTE:  
Yes I wrote it in the format of a UNIX command manual page
  
Copyright (C) StatiX Industries 2013-2014