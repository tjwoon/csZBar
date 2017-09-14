package org.cloudsky.cordovaPlugins;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;


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
         int height1 = (getBottom() /4 );
        canvas.drawRect( 0, 0 , getRight(), height1  ,paint);
        canvas.drawRect(0 , (height1 * 3 )+ 1, getRight(), getHeight()  ,paint);
        canvas.drawRect(0 , height1 , getRight()/8, ((getHeight() * 3)/4) + 1 ,paint);
        canvas.drawRect(((getRight() * 7)/8) + 1 ,height1 , getRight(), ((getHeight() * 3)/4) + 1,paint);

        paint.setColor(Color.rgb(210,39,42));
        paint.setStrokeWidth(3);
        paint.setStyle(Paint.Style.STROKE);
        canvas.drawRect(
            getLeft()+(getRight()-getLeft())/8 ,
            getTop()+(getBottom()-getTop())/4,
            getRight()-(getRight()-getLeft())/8,
            getBottom()-(getBottom()-getTop())/4,paint);
         
        paint.setStyle(Paint.Style.FILL);
        
        //the scan barcode string
        String text = "SCAN BARCODE";
        paint.setTextSize(40);
        paint.setColor(Color.WHITE);
        int bottom = getBottom()-(getBottom()-getTop())/4;
        canvas.drawText(text, width/2 - (int)(paint.measureText(text)/2) ,bottom + 40 , paint);
        canvas.save();
     }
}
