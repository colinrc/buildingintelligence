/*
 * Created on Dec 28, 2003
 *
*/
package au.com.BI.Comms;

//import javax.comm.*;
import gnu.io.*;

import java.io.*;
import java.util.logging.*;
import java.util.TooManyListenersException;

import au.com.BI.Command.CommandQueue;


/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 * Implements a multithreaded serial listener.
 * Serial events are received on a seperate thread.
 * Command line seperated strings are placed on the queue.
 * The main controller can be notified to process this.
 */
public class Serial extends BaseComms implements CommDevice
{
	
	protected CommPortIdentifier portId;
	protected SerialPort serialPort;
	protected SerialListener serialListener;
	protected int etxArray[] = null;
	protected int penultimateVals[] = null;
	protected int stxArray[] = null;
	String deviceName = "";


	public Serial ()  {
		super();
		
		commsGroup = new CommsGroup ("Comms group: " + deviceName);

		
		serialListener = new SerialListener(commsGroup);
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public void setETXArray (int etxArray[]){
		if (serialListener != null){
			this.etxArray = etxArray;
			serialListener.setEndBytes(etxArray);
		}
	}
	
	public void setPenultimateArray(int penultimateVals[]) {
		if (serialListener != null){
			this.penultimateVals = penultimateVals;
			serialListener.setPenultimateVals(penultimateVals);
		}
	}

	public void setSTXArray (int stxArray[]){
		if (serialListener != null) {
			this.stxArray = stxArray;
			serialListener.setStartBytes(stxArray);
		}
	}
	
	public void setTransmitMessageOnBytes (int transmitMessageOnBytes) {
		this.transmitMessageOnBytes = transmitMessageOnBytes;
	}
	/**
	 * 
	 * @param portName The serial com port
	 * @param parameters A paramers object describing serial settings
	 * @see au.com.BI.Comms.SerialParameters
	 * @throws au.com.BI.comms.ConnectionFail
	 */
	public void connect (String portName, SerialParameters parameters, CommandQueue commandList, int targetDeviceModel,String deviceName)
		throws ConnectionFail 
		{
		   commsGroup.setModelNumber(targetDeviceModel);
		   commsGroup.setCommandQueue(commandList);
			this.clearCommandQueue(); // if this is a reconnect make sure nothing is left over from the previous connection.

			this.deviceName = deviceName;
			try
			{
				portId = 
				   CommPortIdentifier.getPortIdentifier(portName);

				logger.log (Level.FINEST,"Openning port " + portName);
	
				if (portId.getPortType()
				 	!= CommPortIdentifier.PORT_SERIAL)
				{
					throw new ConnectionFail ("Port "
								+ portName 
								+ " is not a serial port!");				 		
				}
						//  Is the port in use?	

				if (portId.isCurrentlyOwned())
				{
					throw new ConnectionFail (portId.getName()
							+ " in use by "
							+ portId.getCurrentOwner());				 		
				}
				
				close ();
				try {
					serialPort = (SerialPort)portId.open("eLife", 30000);
					if (serialPort == null) {
						throw new ConnectionFail ("Could not open serial port " +portId.getName());
					}
					else {
						if (parameters.isSupportsCD()) {
							if ( !serialPort.isCD()) {
								logger.log (Level.FINE,"No Carrier Detect on serial port");
								throw new ConnectionFail ("Carrier detect not present " +portId.getName());
							}
							try {
								serialPort.enableReceiveTimeout(10000);
							} catch (UnsupportedCommOperationException e1) {
								logger.log (Level.FINE,"Could not set timeout on serial port");

							}
						}
						setConnectionParameters(parameters);
						if (this.transmitMessageOnBytes > 0)
						    serialListener.setTransmitMessageOnBytes(this.transmitMessageOnBytes);
						os = serialPort.getOutputStream();
						is = serialPort.getInputStream();
						serialListener.setInputStream (is);
						serialListener.setDeviceName(deviceName);
						if (commsSend != null){
							commsSend.setHandleEvents(false);
							commsSend.notify();
						}
						commsSend = new CommsSend(commsGroup,deviceName);
						commsSend.setInterCommandInterval(interCommandInterval);
						commsSend.setOs(os);
						commsSend. start();
						
						// Add this object as an event listener for the serial port.
						serialListener.setTargetDeviceModel(targetDeviceModel);
						try {
							serialPort.addEventListener(serialListener);
						} catch (TooManyListenersException e) {
							serialPort.close();
							throw new ConnectionFail("too many listeners added");
						}

						// Set notifyOnDataAvailable to true to allow event driven input.
						serialPort.notifyOnDataAvailable(true);
						

						// Set notifyOnBreakInterrup to allow event driven break handling.
						serialPort.notifyOnBreakInterrupt(true);
						
						serialPort.notifyOnParityError(true);
						serialPort.notifyOnFramingError(true);

						// Set receive timeout to allow breaking out of polling loop during
						// input handling.
						try {
							serialPort.enableReceiveTimeout(30);
						} catch (UnsupportedCommOperationException e) {
						}
						serialListener.setCommandList(commandList);
						serialListener.start();
					}
				} catch (PortInUseException e) {
					throw new ConnectionFail ("Serial port in use by another application",e);
				} catch (IOException e) {
					serialPort.close();
					throw new ConnectionFail ("IOError in sending information",e);
				} catch (NullPointerException e) {
					serialPort.close();
					throw new ConnectionFail ("Error in setting serial streams",e);
				}
				
				portOpen=true;
			}
	
			catch (NoSuchPortException e)
			{
				throw new ConnectionFail ("Port "
						  + portName + " not found!");

			}catch (UnsatisfiedLinkError e) {
				// serialPort.close();
				throw new ConnectionFail ("Cannot load serial library",e);
			}
		}

	public  boolean isConnected () {
		return portOpen;
	}

	/**
		Sets the serial parameters
	*/
	public void setConnectionParameters(SerialParameters parameters) throws ConnectionFail 
		{


			try {
				int baudRate =parameters.getBaudRate(); 
				serialPort.setSerialPortParams(
						baudRate,
						parameters.getDatabits(),
						parameters.getStopbits(),
						parameters.getParity());
						  
				serialPort.setFlowControlMode(
					parameters.getFlowControlIn() 
							| parameters.getFlowControlOut());
			} catch (UnsupportedCommOperationException e) {
				serialPort.close();
				throw new ConnectionFail("Unsupported parameter:"+e.getMessage(),e);
			}
		}


	public void close () throws ConnectionFail 
	{

		if (serialPort != null) {
			try {
			// close the i/o streams.
				if (os != null) os.close();
				if (serialListener != null) {
					serialListener.setHandleEvents(false);
				}
				if (is != null) is.close();
			} catch (IOException e) {
				serialPort.close();
				portOpen = false;
				throw new ConnectionFail ("Failure closing port",e);
			}
			
			// Close the port.
			serialPort.close();
			portOpen = false;
		}

	}
	public void setNaturalPackets(boolean naturalPackets) {
		super.setNaturalPackets(naturalPackets);
		if (serialListener != null) serialListener.setNaturalPackets(naturalPackets);
	}

	
}
