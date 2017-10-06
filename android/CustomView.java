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


//         Path path = new Path();


//         canvas.drawColor(Color.TRANSPARENT);
//         paint.setShader(null);
//
//         float width = getWidth();
//         float height = getHeight();
//
//         path.moveTo(0, 0);
//
//         path.lineTo(0, height);
//
//         path.lineTo(width, height);
//
//         path.lineTo(width, 0);
//
//         path.cubicTo(4*width/6, 3*height/4, 2*width/6, 3*height/4, 0, 0);
//
//         paint.setColor(Color.GRAY);
//         paint.setStyle(Paint.Style.FILL);
//         paint.setAlpha(CURRENT_POINT_OPACITY);
//         canvas.drawPath(path, paint);





        int width = canvas.getWidth();
        int height = canvas.getHeight();
        paint.setColor(Color.BLACK);
        paint.setAlpha(CURRENT_POINT_OPACITY);
//         int height1 = (getBottom() /4 );
//        canvas.drawRect( 0, 0 , getRight(), height1  ,paint);
//        canvas.drawRect(0 , (height1 * 3 )+ 1, getRight(), getHeight()  ,paint);
//        canvas.drawRect(0 , height1 , getRight()/8, ((getHeight() * 3)/4) + 1 ,paint);
//        canvas.drawRect(((getRight() * 7)/8) + 1 ,height1 , getRight(), ((getHeight() * 3)/4) + 1,paint);

         Drawable d = getResources().getDrawable(R.drawable.scan_qrcode);
         d.setBounds(0, 0 , getRight(), getHeight());
         d.draw(canvas);

        paint.setColor(Color.rgb(210,39,42));
        paint.setStrokeWidth(3);
        paint.setStyle(Paint.Style.STROKE);
//         RectF r = new RectF(
//                 getLeft()+(getRight()-getLeft())/8 ,
//                 getTop()+(getBottom()-getTop())/4,
//                 getRight()-(getRight()-getLeft())/8,
//                 getBottom()-(getBottom()-getTop())/4
//         );
//         canvas.drawArc(r, 90, 180, false, paint);
//         canvas.drawRoundRect(r, 100,50, paint);
//        canvas.drawRect(
//            getLeft()+(getRight()-getLeft())/8 ,
//            getTop()+(getBottom()-getTop())/4,
//            getRight()-(getRight()-getLeft())/8,
//            getBottom()-(getBottom()-getTop())/4,paint);
//        paint.setStyle(Paint.Style.FILL);

        //the scan barcode string
//        String text = "SCAN BARCODE";
//        paint.setTextSize(40);
//        paint.setColor(Color.WHITE);
//        int bottom = getBottom()-(getBottom()-getTop())/4;
//        canvas.drawText(text, width/2 - (int)(paint.measureText(text)/2) ,bottom + 40 , paint);
        canvas.save();
     }
}
