/*
 * Created on Feb 16, 2005
 * @Author Colin Canfield
 */
package au.com.BI.Dynalite;


public interface DynaliteMessage {

	
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

	
	public int getDeviceType ();
	
	public String getKey ();
	public String getOutputKey ();
	
}
