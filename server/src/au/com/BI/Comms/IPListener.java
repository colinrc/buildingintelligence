/*
 * Created on Feb 8, 2004
 *
 */
package au.com.BI.Comms;

import java.io.*;
import java.util.List;
import java.util.logging.*;
import java.net.*;

/**
 * @author Colin Canfield
 * The main serial listener thread
 *
 **/


public class IPListener extends Thread implements CommsListener
{
	protected InputStream is;
	protected volatile boolean handleEvents = false;
	protected List commandList;
	protected Logger logger;
	protected int targetDeviceModel = -1;
	protected int defaultTransmitOnBytes = 400; 
	protected int transmitOnBytes = defaultTransmitOnBytes; 
	protected int bufferHandle = CommDevice.FullLine;
	protected boolean startVals[];
	protected boolean endVals[];
	protected boolean penultimateVals[];
	protected boolean twoByteFinish = false;

	protected BufferedReader rd = null;
	
	/**
	 * The main constructor
	 */
	public IPListener ( ) {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		startVals = new boolean[256];
		endVals = new boolean [256];
		penultimateVals = new boolean [256];
		this.setName("IP Listener");
	}
	
	public void setTargetDeviceModel (int targetDeviceModel) {
		this.targetDeviceModel = targetDeviceModel;
	}

	/**
	* @param commandList The synchronised fifo queue for ReceiveEvent objects
	*/
	public void setCommandList (List commandList){
		this.commandList = commandList;
	}
	
	
	/**
	 * start or stop handling events, eg. if closing down
	 * @param flag
	 */
	public   void setHandleEvents (boolean flag) {
		this.handleEvents = flag;
	}


	
	/**
	 * Set the current input stream
	 * @param is The input stream to read items from
	 */
	public void setInputStream (InputStream  is){
		this.is = is;
	}
	
	
	public void setTransmitMessageOnBytes(int numberBytes) {
		transmitOnBytes = numberBytes;
		this.bufferHandle = CommDevice.BufferLength;
	}
	
	public void setEndBytes(byte endVals[]) {
		for (int i = 0; i < endVals.length; i ++) {
			this.endVals[endVals[i]] = true;
		}
		this.bufferHandle = CommDevice.KnownChars;
	}
	
	
	public void setPenultimateVals(byte[] penultimateVals) {
		for (int i = 0; i < penultimateVals.length; i ++) {
			this.penultimateVals[penultimateVals[i]] = true;
		}

		twoByteFinish = true;
	}
	
	public void setStartBytes(byte startVals[]) {
		for (int i = 0; i < startVals.length; i ++) {
			this.startVals[startVals[i]] = true;
		}
		this.bufferHandle = CommDevice.KnownChars;
	}
	

	/**
	 * Main run method for the class
	 */
	public void run () {
		handleEvents = true;
        int bytesRead = 0;
		byte readArray[] =  new byte [transmitOnBytes + 1];

		if (is == null) return;
		
		switch (bufferHandle) {
		case CommDevice.BufferLength :					
			break;

			case CommDevice.KnownChars :					
				break;

			default :
		        rd = new BufferedReader(new InputStreamReader(is));			
		}
		int startPos = 0;
		int curPos = 0;
		int endPrev = 0;
		int endPos = 0;
		int avail = 0;
		int bytesToRead = 0;

		while (handleEvents)
		{
			 try {
		    
		        String str = new String();
		        
				if (bufferHandle == CommDevice.BufferLength) {
					startPos = 0;
					curPos = 0;
			        while ((avail = is.available()) > 0) {
						if (avail < (transmitOnBytes - startPos)) {
							bytesToRead = avail;
						} else {
							bytesToRead = transmitOnBytes - startPos;
						}
						bytesRead = is.read(readArray, startPos,bytesToRead );
							if (bytesRead >= 0) {
								startPos += bytesRead;
							} else {
								break;
							}
							if (startPos + bytesRead >=  transmitOnBytes) break;
				   }
				   if (startPos != 0) {
					   str = new String (readArray);
						logger.log (Level.FINEST,"Received ip packet : " + str);

						CommsCommand command = new CommsCommand (str,"RawText",null);
						command.setCommandBytes(readArray);
						command.setTargetDeviceModel(this.targetDeviceModel);
						synchronized (commandList){
							commandList.add (command);
						commandList.notifyAll (); 
						}
			        }
	
				}
					

				if (this.bufferHandle == CommDevice.KnownChars  ) {

					boolean reading = true;
					boolean sendBuffer;
					while (reading) {
						sendBuffer = false;
				        while (!sendBuffer && (avail = is.available()) > 0) {
							if (avail < (transmitOnBytes - startPos)) {
								bytesToRead = avail;
							} else {
								bytesToRead = transmitOnBytes - startPos;
							}
							bytesRead = is.read(readArray, startPos,bytesToRead );
							int oldStartPos = startPos;
							if (bytesRead >= 0) {
										
								startPos += bytesRead;
								endPos = startPos;
								//logger.log (Level.FINEST,"buff oldstart="+oldStartPos+" start ="+ startPos + " endPos=" + endPos + " endPrev=" + endPrev + " rcvd=" + bytesRead + " buff="+new String(readArray,0,endPos));
							} else {
								endPos = startPos;
								//logger.log (Level.FINEST,"buff oldstart="+oldStartPos+" start ="+ startPos + " endPos=" + endPos + " endPrev=" + endPrev + " rcvd=" + bytesRead + " buff="+new String(readArray,0,endPos));
								sendBuffer = true;
							}
							if (startPos  >=  transmitOnBytes) {
								endPos = transmitOnBytes ;
								sendBuffer = true;
							}
					   }
						if (endPrev > endPos) {
							logger.log (Level.SEVERE,"Error in IP receiving. endPos=" + endPos + " endPrev="+endPrev + " buf="+new String(readArray));
						}
					   for (curPos = endPrev; curPos < endPos ; curPos ++) {
						   if (readArray[curPos] == '\r' || readArray[curPos] == '\n' ) {
							   byte retArray [] = new byte[curPos - endPrev];
							   System.arraycopy (readArray,endPrev,retArray,0,curPos-endPrev);
							   while (curPos < endPos && (readArray[curPos] == '\r' || readArray[curPos] == '\n' )) {
								   curPos ++;
							   }
							   endPrev = curPos;
							   //logger.log (Level.INFO,"Found a newline setting endPrev = " + endPrev);
							   str = new String (retArray);
							   logger.log (Level.FINEST,"Received ip packet : " + str);
				
							   CommsCommand command = new CommsCommand (str,"RawText",null);
								command.setCommandBytes(retArray);
								command.setTargetDeviceModel(this.targetDeviceModel);
						
								synchronized (commandList){
									commandList.add (command);
									commandList.notifyAll (); 
							   }
						   }
						   int arrayOffset = 0;
						   int prevOffset = -1;
						   if (readArray[curPos] < 0) {
							   arrayOffset = 128 + readArray[curPos] & 127;
						   } else {
							   arrayOffset = readArray[curPos];
							   if (curPos > 0){ 
								   prevOffset = readArray[curPos-1];
							   } else {
								   prevOffset = -1;
							   }
						   }
						   
						   if (this.startVals[arrayOffset] && curPos > 0) {

								   byte retArray [] = new byte[curPos - endPrev];
									   System.arraycopy (readArray,endPrev,retArray,0,curPos-endPrev);
									   // copy from 1 place before curPos
									   endPrev = curPos;
										str = new String (retArray);
										logger.log (Level.FINEST,"Received ip packet : " + str);
				
										CommsCommand command = new CommsCommand (str,"RawText",null);
										command.setCommandBytes(retArray);
										command.setTargetDeviceModel(this.targetDeviceModel);
						
										synchronized (commandList){
											commandList.add (command);
											commandList.notifyAll (); 
										}
									   
						   }
						   if (this.endVals[arrayOffset]) {
								if (twoByteFinish && prevOffset != -1 && !this.penultimateVals[prevOffset]) {
									continue;
								}
									byte retArray [] = new byte[curPos - endPrev + 1];
									System.arraycopy (readArray,endPrev,retArray,0,curPos-endPrev+1);
									endPrev = curPos + 1;
									str = new String (retArray);
										logger.log (Level.FINEST,"Received ip packet : " + str);
										
										CommsCommand command = new CommsCommand (str,"RawText",null);
										command.setCommandBytes(retArray);
										command.setTargetDeviceModel(this.targetDeviceModel);
						
										synchronized (commandList){
											commandList.add (command);
											commandList.notifyAll (); 
										}
									   
						   }

					   }
					   if (endPrev == endPos && endPos >= this.transmitOnBytes) {
						   endPrev =0;
						   startPos = 0;
						   endPos = 0;
					   }

					   if (endPrev < endPos) {
						   if (endPrev == 0 && endPos >= this.transmitOnBytes) {
							   // special case , the entire buffer
							   startPos = 0;
							   endPos = 0;
								
								CommsCommand command = new CommsCommand (str,"RawText",null);
								command.setCommandBytes(readArray);
								command.setTargetDeviceModel(this.targetDeviceModel);
				
								synchronized (commandList){
									commandList.add (command);
									commandList.notifyAll (); 
								}
						   } else {
							   // some left over characters
							   int numBytes = endPos - endPrev;
							   byte tempBuffer[] = new byte[numBytes];
							   System.arraycopy (readArray,endPrev,tempBuffer,0,numBytes);
							  // logger.log (Level.FINEST,"Rotated , endPos = " + endPos + " endPrev = " + endPrev + " bytes=" + numBytes + " new read array is " + new String(tempBuffer) + " old read : " + new String(readArray));
							   System.arraycopy (tempBuffer,0,readArray,0,numBytes);
							   endPrev =0;
							   startPos = numBytes;
							   endPos = numBytes;
						   }
						   
					   } else {
						   reading = false;
					   }
					}
				}

				
				if (this.bufferHandle == CommDevice.FullLine ) {
			        while (rd.ready() && ((str = rd.readLine()) != null )) {
			        		if (str.trim().length() != 0) {
							logger.log (Level.FINEST,"Received ip packet : " + str);
							CommsCommand command = new CommsCommand (str,"RawText",null);
							command.setTargetDeviceModel(this.targetDeviceModel);
		
							synchronized (commandList){
								commandList.add (command);
								commandList.notifyAll (); 
							}
			        		}
			        }
				}
		    } catch (SocketException e) {
				logger.log (Level.FINE,"Received socket exception on IP stream " + e.getMessage());
				handleEvents = false;				
		    } catch (IOException e) {
				logger.log (Level.FINE,"Received IO exception on IP stream " + e.getMessage());
				handleEvents = false;
		    }
	
			try {
				Thread.sleep(500);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			Thread.yield(); // give other clients a chance
		}
		try {
			if (rd != null) {
				rd.close();
			}
		} catch (IOException io){}
	}


}
