# AppIRC

Flutter (iOS/Android) mobile client for [TheLounge](https://thelounge.chat/). TheLounge is self-hosted IRC proxy and Web client.

* `Private` and `public` thelounge server supprot
* Works on `iOS 11+` `Android 5.0+`
* Native UI widgets for Android and iOS
* Push notifications support
* Day/Night theme support
* Search through messagess support
* Upload files support

<img width="250" src="documentation/images/ios_push_notifications.png">
<img width="250" src="documentation/images/android_connect.png">
<img width="250" src="documentation/images/android_chat.png">

## Push notifications on mobile devices

TheLougne support web push notifications, which works (with some limitations) only on Android via PWA.

AppIRC support native push notifications on iOS and Android via FCM.
FCM push notifications works only with **private** TheLounge mode with additional server code modifications (see below).

App uses FCM config files: `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`. If you want build app from source, you should generate this files in your Firebase account.


## Releases

- [Latest Android release](https://www.dropbox.com/s/olgntomlqohnkvg/appirc_1_0_13_app-release.apk?dl=0)
- Please PM me if you want to test iOS version for TestFlight invite.


## Lounge Test server with push notifications support

URL: [http://167.71.55.184:9000](http://167.71.55.184:9000)

Push notifications works only with private TheLounge mode, but TheLougne don't support registration from Web or via API (registration works only via command line on server side). So, you should use existing test server credentials:

* User: `test1` Password `test1`
* User: `test2` Password `test2`
* User: `test3` Password `test3`
* User: `test4` Password `test4`
* User: `test5` Password `test5`

**Currently test server support only one device per user**, so if push notifications stops working for you (somebody login with same login-password pair) you can login with different credentials.

## Lounge FCM notifications fork

TheLounge fork with push notifications support - [https://github.com/xal/thelounge/tree/xal/fcm_push](https://github.com/xal/thelounge/tree/xal/fcm_push). You should add server FCM key in your `config.js`. For example:

```


			//   - `scope`: LDAP search scope. It is set to `"sub"` by default.
			scope: "sub",
		},
	},

	// push notifications for mobile devices
	fcmPush: {
		// FCM token to send pushes
		// Disabled by default
		// shoud be like serverToken: "AAAALxJhc0Q:APA91bFVC5YwqyFMcXW0ow.........."
		// Applen APNs keys should be added to related FCM project to enabled pushes on iOS
		// More about FCM and how to get key - https://firebase.google.com/docs/cloud-messaging/
		serverToken: "",
	},

	// ## Debugging settings

	// The `debug` object contains several settings to enable debugging in The
	// Lounge. Use them to learn more about an issue you are noticing but be aware
	// this may produce more logging or may affect connection performance so it is
	// not recommended to use them by default.
	//
	// All values in the `debug` object are set to `false`.
	debug: {

```

PM me if you need test FCM key, which used on test server.
