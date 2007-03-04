/*
 * Created on Feb 16, 2005
 * @Author Colin Canfield
 */
package au.com.BI.CBUS;


public interface CBUSDevice {
	/**
	 * @return Returns the applicationCode.
	 */
	public String getApplicationCode(); 
	 
	/**
	 * @param applicationCode The applicationCode to set.
	 */
	public void setApplicationCode(String applicationCode) ;

	/**
	 * @param max The applicationCode to set.
	 */

	
	public int getMax ();
	//public void setMax (int max);
	
	public boolean isRelay();
	
	public int getDeviceType ();
	
	public String getKey ();
	
	//public void setGroupName (String groupName);

	public String getGroupName ();
	
	public boolean supportsLevelMMI ();
	
	public boolean isAreaDevice( );
	/**
	 * @return Sets if the device represents an area instead of a channel
	 */
	//public void setAreaDevice( boolean area);
	
	public boolean isGenerateDimmerVals() ;

	public void setGenerateDimmerVals(boolean generateDimmerVals) ;
	
	public String getOutputKey();
}
