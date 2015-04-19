package org.cloudsky.cordovaPlugins;

import java.io.IOException;
import java.lang.RuntimeException;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Resources;
import android.hardware.Camera;
import android.hardware.Camera.CameraInfo;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.AutoFocusCallback;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Gravity;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Collection;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

import net.sourceforge.zbar.ImageScanner;
import net.sourceforge.zbar.Image;
import net.sourceforge.zbar.Symbol;
import net.sourceforge.zbar.SymbolSet;
import net.sourceforge.zbar.Config;

public class ZBarScannerActivity extends Activity
implements SurfaceHolder.Callback {

    //for barcode types
    private Collection<ZBarcodeFormat> mFormats = null;

    // Config ----------------------------------------------------------

    private static int autoFocusInterval = 500; // Interval between AFcallback and next AF attempt.

    // Public Constants ------------------------------------------------

    public static final String EXTRA_QRVALUE = "qrValue";
    public static final String EXTRA_PARAMS = "params";
    public static final int RESULT_ERROR = RESULT_FIRST_USER + 1;

    // State -----------------------------------------------------------

    private Camera camera;
    private Handler autoFocusHandler;
    private SurfaceView scannerSurface;
    private SurfaceHolder holder;
    private ImageScanner scanner;
    private int surfW, surfH;

    // Customisable stuff
    String whichCamera;
    String flashMode;

    // For retrieving R.* resources, from the actual app package
    // (we can't use actual.application.package.R.* in our code as we
    // don't know the applciation package name when writing this plugin).
    private String package_name;
    private Resources resources;

    // Static initialisers (class) -------------------------------------

    static {
        // Needed by ZBar??
        System.loadLibrary("iconv");
    }

    // Activity Lifecycle ----------------------------------------------

    @Override
    public void onCreate (Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        // Get parameters from JS
        Intent startIntent = getIntent();
        String paramStr = startIntent.getStringExtra(EXTRA_PARAMS);
        JSONObject params;
        try { params = new JSONObject(paramStr); }
        catch (JSONException e) { params = new JSONObject(); }
        String textTitle = params.optString("text_title");
        String textInstructions = params.optString("text_instructions");
        Boolean drawSight = params.optBoolean("drawSight", true);
        whichCamera = params.optString("camera");
        flashMode = params.optString("flash");

        // Initiate instance variables
        autoFocusHandler = new Handler();
        scanner = new ImageScanner();
        scanner.setConfig(0, Config.X_DENSITY, 3);
        scanner.setConfig(0, Config.Y_DENSITY, 3);

        // Set the config for barcode formats
        for(ZBarcodeFormat format : getFormats()) {
            scanner.setConfig(format.getId(), Config.ENABLE, 1);
        }

        // Set content view
        setContentView(getResourceId("layout/cszbarscanner"));

        // Update view with customisable strings
        TextView view_textTitle = (TextView) findViewById(getResourceId("id/csZbarScannerTitle"));
        TextView view_textInstructions = (TextView) findViewById(getResourceId("id/csZbarScannerInstructions"));
        view_textTitle.setText(textTitle);
        view_textInstructions.setText(textInstructions);

        // Draw/hide the sight
        if(!drawSight) {
            findViewById(getResourceId("id/csZbarScannerSight")).setVisibility(View.INVISIBLE);
        }

        // Create preview SurfaceView
        scannerSurface = new SurfaceView (this) {
            @Override
            public void onSizeChanged (int w, int h, int oldW, int oldH) {
                surfW = w;
                surfH = h;
                matchSurfaceToPreviewRatio();
            }
        };
        scannerSurface.setLayoutParams(new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT,
            Gravity.CENTER
        ));
        scannerSurface.getHolder().addCallback(this);

        // Add preview SurfaceView to the screen
        FrameLayout scannerView = (FrameLayout) findViewById(getResourceId("id/csZbarScannerView"));
        scannerView.addView(scannerSurface);

        findViewById(getResourceId("id/csZbarScannerTitle")).bringToFront();
        findViewById(getResourceId("id/csZbarScannerInstructions")).bringToFront();
        findViewById(getResourceId("id/csZbarScannerSightContainer")).bringToFront();
        findViewById(getResourceId("id/csZbarScannerSight")).bringToFront();
        scannerView.requestLayout();
        scannerView.invalidate();
    }

    @Override
    public void onResume ()
    {
        super.onResume();

        try {
            if(whichCamera.equals("front")) {
                int numCams = Camera.getNumberOfCameras();
                CameraInfo cameraInfo = new CameraInfo();
                for(int i=0; i<numCams; i++) {
                    Camera.getCameraInfo(i, cameraInfo);
                    if(cameraInfo.facing == CameraInfo.CAMERA_FACING_FRONT) {
                        camera = Camera.open(i);
                    }
                }
            } else {
                camera = Camera.open();
            }

            if(camera == null) throw new Exception ("Error: No suitable camera found.");
        } catch (RuntimeException e) {
            die("Error: Could not open the camera.");
            return;
        } catch (Exception e) {
            die(e.getMessage());
            return;
        }

        Camera.Parameters camParams = camera.getParameters();
        if(flashMode.equals("on")) {
            camParams.setFlashMode(Camera.Parameters.FLASH_MODE_ON);
        } else if(flashMode.equals("off")) {
            camParams.setFlashMode(Camera.Parameters.FLASH_MODE_OFF);
        } else {
            camParams.setFlashMode(Camera.Parameters.FLASH_MODE_AUTO);
        }
        if (android.os.Build.VERSION.SDK_INT >= 14) {
        	camParams.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE);
        }

        try { camera.setParameters(camParams); }
        catch (RuntimeException e) {
            Log.d("csZBar", "Unsupported camera parameter reported for flash mode: "+flashMode);
        }

        tryStartPreview();
    }

    @Override
    public void onPause ()
    {
        releaseCamera();
        super.onPause();
    }

    @Override
    public void onDestroy ()
    {
        scanner.destroy();
        super.onDestroy();
    }

    // Event handlers --------------------------------------------------

    @Override
    public void onBackPressed ()
    {
        setResult(RESULT_CANCELED);
        super.onBackPressed();
    }

    // SurfaceHolder.Callback implementation ---------------------------

    @Override
    public void surfaceCreated (SurfaceHolder hld)
    {
        tryStopPreview();
        holder = hld;
        tryStartPreview();
    }

    @Override
    public void surfaceDestroyed (SurfaceHolder holder)
    {
        // No surface == no preview == no point being in this Activity.
        die("The camera surface was destroyed");
    }

    @Override
    public void surfaceChanged (SurfaceHolder hld, int fmt, int w, int h)
    {
        // Sanity check - holder must have a surface...
        if(hld.getSurface() == null) die("There is no camera surface");

        surfW = w;
        surfH = h;
        matchSurfaceToPreviewRatio();

        tryStopPreview();
        holder = hld;
        tryStartPreview();
    }

    // Continuously auto-focus -----------------------------------------
    // For API Level < 14

    private AutoFocusCallback autoFocusCb = new AutoFocusCallback()
    {
        public void onAutoFocus(boolean success, Camera camera) {
            // some devices crash without this try/catch and cancelAutoFocus()... (#9)
            try {
                camera.cancelAutoFocus();
                autoFocusHandler.postDelayed(doAutoFocus, autoFocusInterval);
            } catch (Exception e) {}
        }
    };

    private Runnable doAutoFocus = new Runnable()
    {
        public void run() {
            if(camera != null) camera.autoFocus(autoFocusCb);
        }
    };

    // Camera callbacks ------------------------------------------------

    // Receives frames from the camera and checks for barcodes.
    private PreviewCallback previewCb = new PreviewCallback()
    {
        public void onPreviewFrame(byte[] data, Camera camera) {
            Camera.Parameters parameters = camera.getParameters();
            Camera.Size size = parameters.getPreviewSize();

            Image barcode = new Image(size.width, size.height, "Y800");
            barcode.setData(data);

            if (scanner.scanImage(barcode) != 0) {
                String qrValue = "";

                SymbolSet syms = scanner.getResults();
                for (Symbol sym : syms) {
                    qrValue = sym.getData();

                    // Return 1st found QR code value to the calling Activity.
                    Intent result = new Intent ();
                    result.putExtra(EXTRA_QRVALUE, qrValue);
                    setResult(Activity.RESULT_OK, result);
                    finish();
                }

            }
        }
    };

    // Misc ------------------------------------------------------------

    // finish() due to error
    private void die (String msg)
    {
        setResult(RESULT_ERROR);
        finish();
    }

    private int getResourceId (String typeAndName)
    {
        if(package_name == null) package_name = getApplication().getPackageName();
        if(resources == null) resources = getApplication().getResources();
        return resources.getIdentifier(typeAndName, null, package_name);
    }

    // Release the camera resources and state.
    private void releaseCamera ()
    {
        if (camera != null) {
            autoFocusHandler.removeCallbacks(doAutoFocus);
            camera.setPreviewCallback(null);
            camera.release();
            camera = null;
        }
    }

    // Match the aspect ratio of the preview SurfaceView with the camera's preview aspect ratio,
    // so that the displayed preview is not stretched/squashed.
    private void matchSurfaceToPreviewRatio () {
        if(camera == null) return;
        if(surfW == 0 || surfH == 0) return;

        // Resize SurfaceView to match camera preview ratio (avoid stretching).
        Camera.Parameters params = camera.getParameters();
        Camera.Size size = params.getPreviewSize();
        float previewRatio = (float) size.height / size.width; // swap h and w as the preview is rotated 90 degrees
        float surfaceRatio = (float) surfW / surfH;

        if(previewRatio > surfaceRatio) {
            scannerSurface.setLayoutParams(new FrameLayout.LayoutParams(
                surfW,
                Math.round((float) surfW / previewRatio),
                Gravity.CENTER
            ));
        } else if(previewRatio < surfaceRatio) {
            scannerSurface.setLayoutParams(new FrameLayout.LayoutParams(
                Math.round((float) surfH * previewRatio),
                surfH,
                Gravity.CENTER
            ));
        }
    }

    // Stop the camera preview safely.
    private void tryStopPreview () {
        // Stop camera preview before making changes.
        try {
            camera.stopPreview();
        } catch (Exception e){
          // Preview was not running. Ignore the error.
        }
    }

    public Collection<ZBarcodeFormat> getFormats() {
        if(mFormats == null) {
            return ZBarcodeFormat.ALL_FORMATS;
        }
        return mFormats;
    }


    // Start the camera preview if possible.
    // If start is attempted but fails, exit with error message.
    private void tryStartPreview () {
        if(holder != null) {
            try {
                // 90 degrees rotation for Portrait orientation Activity.
                camera.setDisplayOrientation(90);

                camera.setPreviewDisplay(holder);
                camera.setPreviewCallback(previewCb);
                camera.startPreview();

                if (android.os.Build.VERSION.SDK_INT >= 14) {
                    camera.autoFocus(autoFocusCb); // We are not using any of the
                        // continuous autofocus modes as that does not seem to work
                        // well with flash setting of "on"... At least with this
                        // simple and stupid focus method, we get to turn the flash
                        // on during autofocus.
                }
            } catch (IOException e) {
                die("Could not start camera preview: " + e.getMessage());
            }
        }
    }
}
