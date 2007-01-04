/*
 * Created on Feb 8, 2004
 *
 */
package au.com.BI.Comms;

import gnu.io.*;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Util.Utility;

//import javax.comm.SerialPortEvent;
//import javax.comm.SerialPortEventListener;
import java.io.*;
import java.util.logging.*;


/**
 * @author Colin Canfield
 * The main serial listener thread
 *
 **/
public class SerialListener extends Thread implements SerialPortEventListener , CommsListener
{
	protected InputStream is;
	protected volatile boolean handleEvents = false;
	protected CommandQueue commandList;
	protected Logger logger;
	protected StringBuffer inputBuffer ;
	protected int targetDeviceModel = -1;
	protected boolean hasETXArray = false;
	protected int eTXArray[];
	protected int numberCharsEtx = 0;
	protected int bufferHandle = CommDevice.FullLine;
	protected boolean startVals[];
	protected boolean endVals[];
	protected boolean twoByteFinish = false;
	protected boolean penultimateVals[];
	protected 	String debugName = "";


	protected int defaultTransmitOnBytes = 100000; 
	byte retBuff[];
	protected int transmitOnBytes = defaultTransmitOnBytes; 
	// number of bytes to receive before sending the string if we do not get newline.
	// can be set lower if required by device (eg. 1 character for many devices
	
	/**
	 * The main constructor
	 */
	public SerialListener ( ThreadGroup threadGroup) {
		super (threadGroup,"Serial Listener");
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		retBuff = new byte [this.transmitOnBytes];
		inputBuffer = new StringBuffer();
		startVals = new boolean[256];
		endVals = new boolean [256];
		penultimateVals = new boolean [256];
		this.setName("Serial Listener");

	}
	
	public void setDeviceName (String deviceName) {
		super.setName("Serial Listener - " + deviceName);
		debugName = deviceName  + ":";
	}
	
	/**
	* @param commandList The synchronised fifo queue for ReceiveEvent objects
	*/
	public void setCommandList (CommandQueue commandList){
		this.commandList = commandList;
	}
	
	public void setTargetDeviceModel (int targetDeviceModel) {
		this.targetDeviceModel = targetDeviceModel;
	}
	
	public void setTransmitMessageOnBytes(int numberBytes) {
		transmitOnBytes = numberBytes;
		this.bufferHandle = CommDevice.BufferLength;
	}
	/**
	 * start or stop handling events, eg. if closing down
	 * @param flag
	 */
	public   void setHandleEvents (boolean flag) {
		this.handleEvents = flag;
	}

	public void setEndBytes(int endVals[]) {
		for (int i = 0; i < endVals.length; i ++) {
			this.endVals[endVals[i]] = true;
		}
		this.bufferHandle = CommDevice.KnownChars;
		hasETXArray = true;
	}
	
	public void setPenultimateVals(int penultimateVals[]) {
		for (int i = 0; i < penultimateVals.length; i ++) {
			this.penultimateVals[penultimateVals[i]] = true;
		}

		twoByteFinish = true;
	}
	
	public void setStartBytes(int startVals[]) {
		for (int i = 0; i < startVals.length; i ++) {
			this.startVals[startVals[i]] = true;
		}
		this.bufferHandle = CommDevice.KnownChars;
	}
	/**
	 * Main run method for the class
	 */
	public void run ()  throws RuntimeException {
		handleEvents = true;
	}
	
	/**
	 * Set the current input stream
	 * @param is The input stream to read items from
	 */
	public void setInputStream (InputStream  is){
		this.is = is;
	}

	/* (non-Javadoc)
	 * @see javax.comm.SerialPortEventListener#serialEvent(javax.comm.SerialPortEvent)
	 */
	public void serialEvent(SerialPortEvent e) 
	{
		/* If some overriding item is happening do not handle the event */
		if (handleEvents == false) return;
		
		// Determine type of event.
		switch (e.getEventType()) {

		case SerialPortEvent.PE :
			logger.log (Level.SEVERE,"Parity error on serial port");
		break;

		case SerialPortEvent.FE :
			logger.log (Level.SEVERE,"Framing error on serial port");
		break;

		// Read data until -1 is returned. 
		case SerialPortEvent.DATA_AVAILABLE:
			
			if (this.transmitOnBytes != this.defaultTransmitOnBytes || this.hasETXArray)
				readSingleByteAtATime ();
			else 
				readLineAtATime ();
				

			break;
		}
	}
	
	protected boolean readSingleByteAtATime ()  {
		boolean sendBuffer = false;
		int newData = 0;
		int prevData = -1;
		boolean lastCharacterEOL = false;
		int newDataCounter = 0;
		

		while (newData != -1 && newDataCounter < this.transmitOnBytes) {
			try { 
				newData = is.read();
				newDataCounter ++;
				//logger.log (Level.FINEST, "Received char " + Integer.toHexString(newData));


				if (newData == -1) {
				}
				else {
					if ('\r' == (char)newData ||'\n' == (char)newData) {
						sendBuffer = true;						
						// logger.log (Level.FINEST, "Received EOL");
					} else {
						if (newDataCounter == this.transmitOnBytes) {
							inputBuffer.append((char)newData);
							retBuff[transmitOnBytes-1] = (byte)newData;
							sendBuffer = true;
						} else {
							   
							if (newData > 255) {
								logger.log (Level.SEVERE,"Character received is greater than byte value newData="+newData);
								continue;
							}
							if (this.startVals[newData] && newDataCounter > 0) {
								sendBuffer = true;
							} 

							
							if (this.endVals[newData]) {
								if (!twoByteFinish){
									inputBuffer.append((char)newData);
									retBuff[newDataCounter-1] = (byte)newData;
									sendBuffer = true;
								} else {
									if (	prevData != -1 && this.penultimateVals[prevData]) {
										inputBuffer.append((char)newData);
										retBuff[newDataCounter-1] = (byte)newData;
										sendBuffer = true;
									} else {
										sendBuffer =false;
									}
								}
							}
							if (!sendBuffer) {
								inputBuffer.append((char)newData);
								retBuff[newDataCounter-1] = (byte)newData;
							}
						}
						prevData = newData;
						
					}
				}
			} catch (IOException ex) {
				sendBuffer = false;
				this.handleEvents=false;
				throw new CommsFail ("Error receiving information",ex);
			}
			if (sendBuffer){
				if (inputBuffer.length() > 0){
					String stringForm = inputBuffer.toString();
					if (logger.isLoggable(Level.FINEST)) {
						logger.log (Level.FINEST, debugName + "Received serial string " + Utility.allBytesToHex(stringForm.getBytes()));
					}
					CommsCommand command = new CommsCommand (stringForm,"RawText",null);
					command.setCommandBytes(retBuff);
					command.setTargetDeviceModel(this.targetDeviceModel);
					commandList.add (command);
					inputBuffer = new StringBuffer();
					retBuff = new byte[this.transmitOnBytes];
				}
				sendBuffer = false;
				newDataCounter = 0;

			}
		}
		return false;

	}
	
	protected boolean readLineAtATime ()  {
		boolean sendBuffer = false;
		int newData = 0;
		boolean lastCharacterEOL = false;
		int newDataCounter = 0;


		while (newData != -1) {
			try { 
				newData = is.read();
				newDataCounter ++;
				// logger.log (Level.FINEST, "Received char " + Integer.toHexString(newData));


				if (newData == -1) {
				}
				else {
					if ('\r' == (char)newData ||'\n' == (char)newData) {
						sendBuffer = true;						
						// logger.log (Level.FINEST, "Received EOL");
					} else {
						inputBuffer.append((char)newData);
						if (newDataCounter == this.transmitOnBytes) {
							sendBuffer = true;
						} else {
							if (this.hasETXArray) {
								for (int i = 0; i < this.numberCharsEtx; i ++) {
									if (newData == this.eTXArray[i]) {
										sendBuffer = true;
									}
									
								}
							}
						}
						
					}
				}
			} catch (IOException ex) {
				sendBuffer = false;
				this.handleEvents=false;
				throw new CommsFail ("Error receiving information",ex);
			}
			if (sendBuffer){
				if (inputBuffer.length() > 0){
					logger.log (Level.FINEST, debugName + "Received serial string " + inputBuffer.toString());
					CommsCommand command = new CommsCommand (inputBuffer.toString(),"RawText",null);
					command.setTargetDeviceModel(this.targetDeviceModel);
					commandList.add (command);
					inputBuffer = new StringBuffer();
				}
				sendBuffer = false;
				newDataCounter = 0;

			}
		}
		return false;

	}

}
