**This repository is looking for a maintainer! If you believe you are the right person, please [leave a comment](https://github.com/tjwoon/csZBar/issues/60)!**



# ZBar Barcode Scanner Plugin

This plugin integrates with the [ZBar](http://zbar.sourceforge.net/) library,
exposing a JavaScript interface for scanning barcodes (QR, 2D, etc).

## Installation

    cordova plugins add org.cloudsky.cordovaplugins.zbar

## API

### Scan barcode

    cloudSky.zBar.scan(params, onSuccess, onFailure)

Arguments:

- **params**: Optional parameters:

    ```javascript
    {
        text_title: "OPTIONAL Title Text - default = 'Scan QR Code'", // Android only
        text_instructions: "OPTIONAL Instruction Text - default = 'Please point your camera at the QR code.'", // Android only
        camera: "front" || "back" // defaults to "back"
        flash: "on" || "off" || "auto" // defaults to "auto". See Quirks
        drawSight: true || false //defaults to true, create a red sight/line in the center of the scanner view.
    }
    ```

- **onSuccess**: function (s) {...} _Callback for successful scan._
- **onFailure**: function (s) {...} _Callback for cancelled scan or error._

Return:

- success('scanned bar code') _Successful scan with value of scanned code_
- error('cancelled') _If user cancelled the scan (with back button etc)_
- error('misc error message') _Misc failure_

Status:

- Android: DONE
- iOS: DONE

Quirks:

- __Android__: On Android API Level < 14, flash "on" may cause the flash to
  alternate between on and off at about a half second/one second interval,
  instead of making it stay on...


## LICENSE [Apache 2.0](LICENSE.md)

This plugin is released under the Apache 2.0 license, but the ZBar library on which it depends (and which is distribute with this plugin) is under the LGPL license (2.1).


## Thanks

Thank you to @PaoloMessina and @nickgerman for code contributions.
