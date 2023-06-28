# Knock iOS Example App

## Quick start

Clone this repo:

``` bash
git clone git@github.com:knocklabs/ios-example-app.git
```

Open the Xcode project:

``` bash
cd ios-example-app && xed .
```

### Knock Requirements

In order to test the functionality of this demo app, you should have:

* Your public API key
* One Knock user created
* One in-app channel (Integrations -> Channels)
* One Apple Push Notification Service channel (Integrations -> Channels)

Open the file `Core/Utils.swift` and fill the 4 fields with the above information.

Also, you should have 2 tenants with the following ids: `team-a` and `team-b`.

After this, you can select a simulator as a run destination in case it's not already selected and you can run the app.

**NOTE about a log message that you might see on the console:**

You might see the following message displayed in the console:

```
invalid mode 'kCFRunLoopCommonModes' provided to CFRunLoopRunSpecific - break on _CFRunLoopError_RunCalledWithInvalidMode to debug. This message will only appear once per execution.
```

Apparently, this is a bug in UIKit related to the switches (UISwitch). There's a disscussion on [Apple's Developer Forums](https://developer.apple.com/forums/thread/132035) and the suggestion is just to treat it as [log noise](https://developer.apple.com/forums/thread/115461), so, you can safely ignore the message.