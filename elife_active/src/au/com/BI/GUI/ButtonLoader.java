/*
 * Created on 8/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;

import java.awt.Frame;
import java.awt.Image;
import java.awt.MediaTracker;
import java.awt.Toolkit;
import java.net.URL;

/**
 * @author David
 *
 * 
 * 
 */
public class ButtonLoader {
	/*Base Images*/
	private Image baseTopLeft;
	private Image baseTop;
	private Image baseTopRight;
	private Image baseMiddleLeft;
	private Image baseMiddle;
	private Image baseMiddleRight;
	private Image baseBottomLeft;
	private Image baseBottom;
	private Image baseBottomRight;
	/*Highlight Images*/
	private Image highLightTopLeft;
	private Image highLightTop;
	private Image highLightTopRight;
	private Image highLightMiddleLeft;
	
	private Image highLightMiddleRight;
	private Image highLightBottomLeft;
	private Image highLightBottom;
	private Image highLightBottomRight;
	
	public ButtonLoader(Frame inFrame){
		loadImages(inFrame);
	}
	
	private void loadImages(Frame inFrame){
		URL url = getClass().getClassLoader().getResource("images/base/");
		String path;
		if(url != null){
			path = url.getPath();
		} else{
			path = "/Program Files/eLifejava/images/base/";
		} 
		baseTopLeft = Toolkit.getDefaultToolkit().createImage(path+"button-base_01.png");
		baseTop = Toolkit.getDefaultToolkit().createImage(path+"button-base_02.png");
		baseTopRight = Toolkit.getDefaultToolkit().createImage(path+"button-base_03.png");
		baseMiddleLeft = Toolkit.getDefaultToolkit().createImage(path+"button-base_04.png");
		baseMiddle = Toolkit.getDefaultToolkit().createImage(path+"button-base_05.png");
		baseMiddleRight = Toolkit.getDefaultToolkit().createImage(path+"button-base_06.png");
		baseBottomLeft = Toolkit.getDefaultToolkit().createImage(path+"button-base_07.png");
		baseBottom = Toolkit.getDefaultToolkit().createImage(path+"button-base_08.png");
		baseBottomRight = Toolkit.getDefaultToolkit().createImage(path+"button-base_09.png");
		
		url = getClass().getClassLoader().getResource("images/highlight/");
		if(url != null){
			path = url.getPath();
		} else{
			path = "/Program Files/eLifejava/images/highlight/";
		} 
		highLightTopLeft = Toolkit.getDefaultToolkit().createImage(path+"button-highlight_01.png");
		highLightTop = Toolkit.getDefaultToolkit().createImage(path+"button-highlight_02.png");
		highLightTopRight = Toolkit.getDefaultToolkit().createImage(path+"button-highlight_03.png");
		highLightMiddleLeft = Toolkit.getDefaultToolkit().createImage(path+"button-highlight_04.png");
		
		highLightMiddleRight = Toolkit.getDefaultToolkit().createImage(path+"button-highlight_06.png");
		highLightBottomLeft = Toolkit.getDefaultToolkit().createImage(path+"button-highlight_07.png");
		highLightBottom = Toolkit.getDefaultToolkit().createImage(path+"button-highlight_08.png");
		highLightBottomRight = Toolkit.getDefaultToolkit().createImage(path+"button-highlight_09.png");		
		
		MediaTracker media = new MediaTracker(inFrame);
		media.addImage(baseTopLeft, 0);
		media.addImage(baseTop, 1);
		media.addImage(baseTopRight, 2);
		media.addImage(baseMiddleLeft, 3);
		media.addImage(baseMiddle, 4);
		media.addImage(baseMiddleRight, 5);
		media.addImage(baseBottomLeft, 6);
		media.addImage(baseBottom, 7);
		media.addImage(baseBottomRight, 8);
		media.addImage(baseTopLeft, 9);
		media.addImage(baseTop, 10);
		media.addImage(baseTopRight, 11);
		media.addImage(baseMiddleLeft, 12);
		
		media.addImage(baseMiddleRight, 13);
		media.addImage(baseBottomLeft, 14);
		media.addImage(baseBottom, 15);
		media.addImage(baseBottomRight, 16);
		try{
			media.waitForAll();
		} catch (Exception e){
			System.err.println(e);
			e.printStackTrace();
		}
	}
	
	public Image getBaseTopLeft(){
		return baseTopLeft;
	}
	
	public Image getBaseTop(){
		return baseTop;
	}
	
	public Image getBaseTopRight(){
		return baseTopRight;
	}
	
	public Image getBaseMiddleLeft(){
		return baseMiddleLeft;
	}
	
	public Image getBaseMiddle(){
		return baseMiddle;
	}
	
	public Image getBaseMiddleRight(){
		return baseMiddleRight;
	}
	
	public Image getBaseBottomLeft(){
		return baseBottomLeft;
	}
	
	public Image getBaseBottom(){
		return baseBottom;
	}
	
	public Image getBaseBottomRight(){
		return baseBottomRight;
	}
	/*Highlighted*/
	public Image getHighLightTopLeft(){
		return highLightTopLeft;
	}
	
	public Image getHighLightTop(){
		return highLightTop;
	}
	
	public Image getHighLightTopRight(){
		return highLightTopRight;
	}
	
	public Image getHighLightMiddleLeft(){
		return highLightMiddleLeft;
	}
	
		
	public Image getHighLightMiddleRight(){
		return highLightMiddleRight;
	}
	
	public Image getHighLightBottomLeft(){
		return highLightBottomLeft;
	}
	
	public Image getHighLightBottom(){
		return highLightBottom;
	}
	
	public Image getHighLightBottomRight(){
		return highLightBottomRight;
	}	
}
