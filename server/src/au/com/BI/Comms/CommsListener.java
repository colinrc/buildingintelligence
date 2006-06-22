/*
 * Created on Apr 15, 2004
 *
 * To change the template for this generated file go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
package au.com.BI.Comms;

import au.com.BI.Command.CommandQueue;
/**
 * @author colinc
 *
 * To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
public interface CommsListener {

	/**
	* @param commandList The synchronised fifo queue for ReceiveEvent objects
	*/
	public void setCommandList (CommandQueue commandList);
	
	public void setTargetDeviceModel (int targetDeviceModel);
	
	/**
	 * start or stop handling events, eg. if closing down
	 * @param flag
	 */
	public   void setHandleEvents (boolean flag) ;
	
	
	public void setTransmitMessageOnBytes(int numberBytes) ;
	
	public void setEndBytes(int endVals[]);
	
	public void setPenultimateVals(int penultimateVals[]);

	public void setStartBytes(int startVals[]);
	
}
