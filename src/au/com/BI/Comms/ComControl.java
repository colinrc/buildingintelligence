/*
 * Created on 28/08/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.Comms;
/**
 * @author David
 *
 * 
 * 
 */
import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;
import gnu.io.UnsupportedCommOperationException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.TooManyListenersException;
public class ComControl implements Runnable, SerialPortEventListener {
	static CommPortIdentifier portId1;
	InputStream inputStream;
	OutputStream outputStream;
	SerialPort serialPort1;
	Thread readThread;
	protected String divertCode = "10";
	static String TimeStamp;
	static IntegralControls controls;
	/**
	 * 
	 */
	public static void main(String[] args) {
		try {
			ComControl reader = new ComControl();
			PortSelector port = new PortSelector(reader);
		} catch (Exception e) {
			e.printStackTrace();
		}
	};
	public ComControl() {
	}
	public void start(String PortName, int baudRate, int dataBits, int stopBits, int parity) {
		try {
			portId1 = CommPortIdentifier.getPortIdentifier(PortName);
			TimeStamp = new java.util.Date().toString();
			serialPort1 = (SerialPort) portId1.open("ComControl", 2000);
			System.out.println(TimeStamp + ": " + portId1.getName() + " opened for scanner input");
		} catch (Exception e) {
		}
		try {
			inputStream = serialPort1.getInputStream();
		} catch (IOException e) {
		}
		try {
			serialPort1.addEventListener(this);
		} catch (TooManyListenersException e) {
		}
		serialPort1.notifyOnDataAvailable(true);
		try {
			serialPort1.setSerialPortParams(baudRate ,dataBits,	stopBits,parity);
			serialPort1.setFlowControlMode(SerialPort.FLOWCONTROL_NONE);
		} catch (UnsupportedCommOperationException e) {
		}
		readThread = new Thread(this);
		readThread.start();
		controls = new IntegralControls();
		controls.setVisible(true);
		controls.setSerialHandler(this);
	}
	public void run() {
		try {
			Thread.sleep(100);
		} catch (InterruptedException e) {
		}
	}
	public void sendMessage(String outMessage) {
		try {
			outputStream = serialPort1.getOutputStream();
			outMessage += (char) 13;
			outputStream.write(outMessage.getBytes());
			//System.out.println(TimeStamp + ": diverter fired");
			outputStream.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	public void serialEvent(SerialPortEvent event) {
		switch (event.getEventType()) {
			case SerialPortEvent.BI :
			case SerialPortEvent.OE :
			case SerialPortEvent.FE :
			case SerialPortEvent.PE :
			case SerialPortEvent.CD :
			case SerialPortEvent.CTS :
			case SerialPortEvent.DSR :
			case SerialPortEvent.RI :
			case SerialPortEvent.OUTPUT_BUFFER_EMPTY :
				break;
			case SerialPortEvent.DATA_AVAILABLE :
				StringBuffer readBuffer = new StringBuffer();
				int c;
				try {
					c = inputStream.read();
					while ((c != 10) && (c != 13)) {
						readBuffer.append((char) c);
						c = inputStream.read();
					}
					String scannedInput = readBuffer.toString();
					controls.incomingSerial(scannedInput);
					inputStream.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
				break;
		}
	}
}
