# ZBar Barcode Scanner Plugin

This plugin integrates with the [ZBar](http://zbar.sourceforge.net/) library,
exposing a JavaScript interface for scanning barcodes (QR, 2D, etc).

## Installation

    cordova plugins install org.cloudsky.cordovaplugins.zbar

## License

This plugin is released under the Apache 2.0 license, but the ZBar library on which it depends (and which is distribute with this plugin) is under the LGPL license (2.1).

## API

### Scan barcode

    cloudSky.zBar.scan(params, onSuccess, onFailure)

Arguments:

- **params**: Optional parameters:

    ```javascript
    {
        text_title: "Title Text - default = 'Scan QR Code'",
        text_instructions: "Instruction Text - default = 'Please point your camera at the QR code.'",
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
