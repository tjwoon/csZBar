package org.cloudsky.cordovaPlugins;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.View;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;

import ion.com.dmo2.R;

import static android.R.attr.bottom;
import static android.R.attr.path;
import static android.R.attr.right;


class CustomView extends View {
      private static final int CURRENT_POINT_OPACITY = 0xA0;

    public CustomView(Context context)
        {
            super(context);
        }
        public CustomView(Context context, AttributeSet attrs)
        {
            super(context, attrs);
        }
        public CustomView(Context context, AttributeSet attrs, int defStyle) {
            super(context, attrs, defStyle);
        }

     @Override
     protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        Paint paint = new Paint();
        int width = canvas.getWidth();
        int height = canvas.getHeight();
        paint.setColor(Color.BLACK);
        paint.setAlpha(CURRENT_POINT_OPACITY);
        Drawable d = getResources().getDrawable(R.drawable.scan_qrcode);
        d.setBounds(0, 0 , getRight(), getHeight());
        d.draw(canvas);

        paint.setColor(Color.rgb(210,39,42));
        paint.setStrokeWidth(3);
        paint.setStyle(Paint.Style.STROKE);
        canvas.save();
     }
}
