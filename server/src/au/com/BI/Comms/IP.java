/*
 * Created on Dec 28, 2003
 *
*/
package au.com.BI.Comms;

import java.io.*;
import java.util.logging.*;
import java.util.List;
import java.net.*;

/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 * Implements a multithreaded serial listener.
 * Serial events are received on a seperate thread.
 * Command line seperated strings are placed on the queue.
 * The main controller can be notified to process this.
 */
public class IP extends BaseComms implements CommDevice
{

	protected Socket ipSocket;
	protected boolean portOpen = false;
	protected OutputStream os;
	protected InputStream is;	
	protected IPListener ipListener = null;
	protected InetAddress ipAddress;
	protected int port;
	protected IPHeartbeat ipHeartbeat;
	protected int etxArray[] = null;
	protected int stxArray[] = null;
	protected int penultimateVals[] = null;
	protected int transmitMessageOnBytes = 0;

	
	public IP ()  {

		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
		
	
	public void setPenultimateArray(int[] penultimateVals) {
		this.penultimateVals = penultimateVals;
	}
	
	public boolean sendNextCommand() throws CommsFail{	
		if (ipHeartbeat != null) ipHeartbeat.pause(true);
		super.sendNextCommand();
		if (ipHeartbeat != null) ipHeartbeat.pause(false);
		return true;
	}
	
	public boolean repeatLastCommand () throws CommsFail {
		if (ipHeartbeat != null) ipHeartbeat.pause(true);
		boolean returnCode = super.repeatLastCommand();
		if (ipHeartbeat != null) ipHeartbeat.pause(false);
		
		return returnCode;
	}
	
	public void setETXArray (int etxArray[]){
		this.etxArray = etxArray;
	}

	public void setSTXArray (int stxArray[]){
		this.stxArray = stxArray;
	}
	
	public void setTransmitMessageOnBytes (int transmitMessageOnBytes) {
		this.transmitMessageOnBytes = transmitMessageOnBytes;
	}
	
	/**
	 * 
	 * @param ipAddressTxt The IP address
	 * @param portNum The ip port
	 * @throws au.com.BI.comms.ConnectionFail
	 */
	public void connect (String ipAddressTxt, String portNum,  List commandList, int targetDeviceModel, boolean doHeartBeat, String heartbeatString)
		throws ConnectionFail 
		{
			try
			{
				ipListener = new IPListener();
				if (etxArray != null) ipListener.setEndBytes(etxArray);
				if (penultimateVals != null) ipListener.setPenultimateVals(penultimateVals);
				if (stxArray != null) ipListener.setStartBytes(stxArray);
				if (transmitMessageOnBytes > 0) ipListener.setTransmitMessageOnBytes(transmitMessageOnBytes);

				this.ipAddress = InetAddress.getByName (ipAddressTxt);
				ipListener.setTargetDeviceModel (targetDeviceModel);
				this.port = Integer.parseInt(portNum); 
				SocketAddress sockaddr = new InetSocketAddress(ipAddress, port);

				logger.log (Level.FINEST,"Openning IP " + ipAddressTxt + " port " + portNum);
				ipSocket = new Socket ();
				int timeoutMs = 0;   // wait forever for new data
		        ipSocket.connect(sockaddr, timeoutMs);
				os = ipSocket.getOutputStream();
				is = ipSocket.getInputStream();
				
				if (doHeartBeat) {
					ipHeartbeat = new IPHeartbeat ();
					ipHeartbeat.setCommandQueue(commandList);
					ipHeartbeat.setDeviceNumber(targetDeviceModel);
					ipHeartbeat.setHeartbeatString (heartbeatString);
					ipHeartbeat.setOutputStream(os);
					ipHeartbeat.start();
				}
				
				ipSocket.setKeepAlive(true);
				ipListener.setInputStream (is);
				ipListener.setCommandList(commandList);
				if (this.transmitMessageOnBytes > 0)
				    ipListener.setTransmitMessageOnBytes(this.transmitMessageOnBytes);

				ipListener.setHandleEvents(true);
				ipListener.start();
				portOpen=true;
		    } catch (UnknownHostException e) {
	    			throw new ConnectionFail ("Could not find system " + e.getMessage());
	    		} catch (SocketTimeoutException e) {
		    		throw new ConnectionFail ("Could not connect " + e.getMessage());
		    } catch (IOException e) {
		    		throw new ConnectionFail (e.getMessage());
		    } catch (NumberFormatException e) {
		    		throw new ConnectionFail ("IP port is not a valid number " + e.getMessage());
			    	 	
		    }
		}

	public  boolean isConnected () {
		return portOpen;
	}

	public void gotFeedback() {
		super.gotFeedback();
		if (ipHeartbeat != null && ipHeartbeat.pausing ){
			ipHeartbeat.pause(false);
		}
	}
	
	public void close () throws ConnectionFail 
	{
		if (ipSocket != null) {
			if (ipHeartbeat != null) {
				ipHeartbeat.setHandleEvents(false);
			}
			try {
			// close the i/o streams.
				if (os != null) {
				    synchronized (os) {
				    	if (os != null) os.close();
				    }
			    }
				if (ipListener != null) {
					ipListener.setHandleEvents(false);
				}
				if (is != null) is.close();
			} catch (IOException e) {
				try {
					ipSocket.close();
				} catch (IOException ie){};
				portOpen = false;
				throw new ConnectionFail ("Failure closing port",e);
			}
			
			// Close the port.
			try {
				ipSocket.close();
			} catch (IOException ie){};
			portOpen = false;
		}

	}

	
	public void sendString (String message)
		throws CommsFail 
	{
		try {
			if (portOpen) {
				logger.log (Level.FINEST,"Sending string " + message);
				synchronized (os){
					os.write((message).getBytes());
					os.flush();
				}
			}
		} catch (InterruptedIOException e) {
		    throw new CommsFail ("Timeout in IP connection: ",e);
		} catch (IOException e) {
			throw new CommsFail ("Failure sending the information: ",e);
		}
	}

	public void sendString (byte[] message)
	throws CommsFail 
	{
	try {
		if (portOpen) {
			synchronized (os){
				os.write(message);
				os.flush();
			}
		}
	} catch (IOException e) {
		throw new CommsFail ("Failure sending the information: ",e);
	}
}
	
	
}
