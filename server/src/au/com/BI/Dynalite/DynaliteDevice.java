/*
 * Created on Feb 16, 2005
 * @Author Colin Canfield
 */
package au.com.BI.Dynalite;


public interface DynaliteDevice {
	public static final int Linear = 0;
	public static final int Classic = 1;
	
	/**
	 * @return Returns if the device represents an area instead of a channel
	 */
	public boolean isAreaDevice( );

	/**
	 * @return Returns if the device represents an area instead of a channel
	 */
	public void setAreaDevice( boolean area);

	
	/**
	 * @return Returns the areaCode.
	 */
	public String getAreaCode(); 
	
	/**
	 * @param areaCode The areaCode to set.
	 */
	public void setAreaCode(String areaCode) ;

	
	public int getMax ();
	
	public boolean isRelay ();
	
	public int getDeviceType ();
	
	public String getKey ();
	

	public int getChannel ();
	public void setChannel(int channel);

	public String getMaxStr ();
	
	public String getOutputKey ();
	
	public String getBLA();
	public void setBLA(String bLA);
	
	public int listensToLinkArea (int linkOffset);
	
	public boolean isLinked();

	public void incLinkCount ();
	
	public void decLinkCount ();
}
