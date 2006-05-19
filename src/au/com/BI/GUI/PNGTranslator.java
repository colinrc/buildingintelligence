/*
 * Created on 8/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;

import java.awt.Color;
import java.awt.Image;
import java.awt.image.FilteredImageSource;
import java.awt.image.RGBImageFilter;

/**
 * @author David
 *
 * To change the template for this generated type comment go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
public class PNGTranslator {
	private ResImageFilter m_imageFilter = new ResImageFilter();

	public Image getTintedImage(Image inImage) {
		//m_imageFilter.setColorModel(new ColorModel());
		java.awt.image.ImageProducer ip =
			new FilteredImageSource(inImage.getSource(), m_imageFilter);
		Image newImage = java.awt.Toolkit.getDefaultToolkit().createImage(ip);
		return newImage;
	}

	public class ResImageFilter extends RGBImageFilter {
		private int m_rgbMaskColor = 0;

		public ResImageFilter() {
			//m_rgbMaskColor = new Color(0,0, 120, 0).getRGB();
			m_rgbMaskColor = new Color(0, 0, 0).getRGB();
			canFilterIndexColorModel = false;
		}
		public int filterRGB(int x, int y, int rgb) {
			if (rgb == m_rgbMaskColor) {
				return 0x00FFFFFF & rgb;
			} else {
				return rgb;
			}
		}
	}
}