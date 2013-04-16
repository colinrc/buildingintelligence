/**
 * @Author Colin Canfield  Useful for setting up serial ports
 * @version 1.0
 * @updated 18-Jan-2004 08:54:54 PM
 */
package au.com.BI.Comms;
//import javax.comm.*;
import gnu.io.*;
import au.com.BI.Util.DeviceModel;
import java.util.logging.*;


public class SerialParameters{

	private int baudRate;
	private int flowControlIn;
	private int flowControlOut;
	private int databits;
	private int stopbits;
	private boolean supportsCD = true;
	private int parity;
	protected Logger logger;

	/**
	 * Default = 9600 , 8, 1, N
	 */
	public SerialParameters(){
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public void buildFromDevice (DeviceModel device) {

		boolean flowControl = false;
		String flow = (String)device.getParameterValue("Flow_Control",DeviceModel.MAIN_DEVICE_GROUP);
		if (flow != null && !flow.equals("NONE")) {
			flowControl = true;
		}
		else {
			flowControl = false;
		}
		
		if (flowControl){
			this.setFlowControlIn(SerialPort.FLOWCONTROL_RTSCTS_IN);
			this.setFlowControlOut(SerialPort.FLOWCONTROL_RTSCTS_OUT);
		}
		else {
			this.setFlowControlIn(SerialPort.FLOWCONTROL_NONE);
			this.setFlowControlOut(SerialPort.FLOWCONTROL_NONE);			
		}
		String baudRate = (String)device.getParameterValue("Baud_Rate",DeviceModel.MAIN_DEVICE_GROUP);
		String dataBits = (String)device.getParameterValue("Data_Bits",DeviceModel.MAIN_DEVICE_GROUP);
		String stopBits = (String)device.getParameterValue("Stop_Bits",DeviceModel.MAIN_DEVICE_GROUP); 
		String parity = (String)device.getParameterValue("Parity",DeviceModel.MAIN_DEVICE_GROUP);
		
		if (baudRate == null || dataBits == null || stopBits == null || parity == null) {
			logger.log (Level.SEVERE,"Serial parameters not specified for "  + device.getName());
		}
		else
		{
			this.setBaudRate(Integer.parseInt(baudRate));
			this.setDatabits(dataBits);
			this.setStopbits(stopBits); 
			this.setParity(parity);
		}
		String supportsCD = (String)device.getParameterValue("Supports_CD",DeviceModel.MAIN_DEVICE_GROUP); 
		if (supportsCD != null && supportsCD.equals("N")){
			this.supportsCD = false;
		} else {
			this.supportsCD = true;
		}
	}
	
    public void setParity(String parity) {
    	if (parity == null){
    		this.parity = SerialPort.PARITY_NONE;
    		return;
    	}
    	if (parity.equals("N")) {
    	    this.parity = SerialPort.PARITY_NONE;
    	}
    	if (parity.equals("E")) {
    	    this.parity = SerialPort.PARITY_EVEN;
    	}
    	if (parity.equals("O")) {
    	    this.parity = SerialPort.PARITY_ODD;
    	}
        }

	/**
	 * @param portName The name of the port.
	 * @param baudRate    The baud rate.
	 * @param flowControlIn    Type of flow control for receiving.
	 * @param flowControlOut    Type of flow control for sending.
	 * @param databits    The number of data bits.
	 * @param stopbits    The number of stop bits.
	 * @param parity    The type of parity.
	 * 
	 */
	public SerialParameters(int baudRate, int flowControlIn, int flowControlOut, int databits, int stopbits, int parity){
		this.baudRate = baudRate;
		this.flowControlIn = flowControlIn;
		this.flowControlOut = flowControlOut;
		this.databits = databits;
		this.stopbits = stopbits;
		this.parity = parity;
	}

	/**
	 * @param portName The name of the port.
	 * @param baudRate    The baud rate.
	 * @param flowControlIn    Type of flow control for receiving.
	 * @param flowControlOut    Type of flow control for sending.
	 * @param databits    The number of data bits.
	 * @param stopbits    The number of stop bits.
	 * @param parity    The type of parity.
	 * 
	 */
	public SerialParameters(String baudRate, int flowControlIn, int flowControlOut, int databits, int stopbits, int parity){

		this.baudRate = Integer.parseInt(baudRate);
		this.flowControlIn = flowControlIn;
		this.flowControlOut = flowControlOut;
		this.databits = databits;
		this.stopbits = stopbits;
		this.parity = parity;
	}

	
	/**
	 * @param baudRate    New baud rate.
	 * 
	 */
	public void setBaudRate(int baudRate){
		this.baudRate = baudRate;

	}

	/**
	 * Gets baud rate as an <code>int</code>.
	 * @return Current baud rate.
	 */
	public int getBaudRate(){
		return baudRate;
	}


	/**
	 * Sets flow control for reading.
	 * @param flowControlIn    New flow control for reading type.
	 * 
	 */
	public void setFlowControlIn(int flowControlIn){
		this.flowControlIn = flowControlIn;

	}

    public void setStopbits(String stopbits) {
    	if (stopbits == null) {
    		this.stopbits =  SerialPort.STOPBITS_1;
    		return;
    	}
    	if (stopbits.equals("1")) {
    	    this.stopbits = SerialPort.STOPBITS_1;
    	}
    	if (stopbits.equals("1.5")) {
    	    this.stopbits = SerialPort.STOPBITS_1_5;
    	}
    	if (stopbits.equals("2")) {
    	    this.stopbits = SerialPort.STOPBITS_2;
    	}
        }

	/**
	 * Gets flow control for reading as an <code>int</code>.
	 * @return Current flow control type.
	 */
	public int getFlowControlIn(){
		return flowControlIn;
	}


	/**
	 * Sets flow control for writing.
	 * @param flowControlIn New flow control for writing type.
	 * @param flowControlOut
	 * 
	 */
	public void setFlowControlOut(int flowControlOut){
		this.flowControlOut = flowControlOut;

	}


	/**
	 * Gets flow control for writing as an <code>int</code>.
	 * @return Current flow control type.
	 */
	public int getFlowControlOut(){
		return flowControlOut;
	}
    /** 
    Sets data bits.
    @param databits New data bits setting.
    */
    public void setDatabits(String databits) {
    	if (databits == null) {
    		this.databits = SerialPort.DATABITS_8;
    		return;
    	}
	if (databits.equals("5")) {
	    this.databits = SerialPort.DATABITS_5;
	}
	if (databits.equals("6")) {
	    this.databits = SerialPort.DATABITS_6;
	}
	if (databits.equals("7")) {
	    this.databits = SerialPort.DATABITS_7;
	}
	if (databits.equals("8")) {
	    this.databits = SerialPort.DATABITS_8;
	}
    }


	/**
	 * Sets data bits.
	 * @param databits    New data bits setting.
	 * 
	 */
	public void setDatabits(int databits){
		this.databits = databits;

	}


	/**
	 * Gets data bits as an <code>int</code>.
	 * @return Current data bits setting.
	 */
	public int getDatabits(){
		return databits;
	}

	/**
	 * Sets stop bits.
	 * @param stopbits    New stop bits setting.
	 * 
	 */
	public void setStopbits(int stopbits){
		this.stopbits = stopbits;

	}

	/**
	 * Gets stop bits setting as an <code>int</code>.
	 * @return Current stop bits setting.
	 */
	public int getStopbits(){
		return stopbits;
	}


	/**
	 * Sets parity setting.
	 * @param parity    New parity setting.
	 * 
	 */
	public void setParity(int parity){
		this.parity = parity;

	}


	/**
	 * Gets parity setting as an <code>int</code>.
	 * @return Current parity setting.
	 */
	public int getParity(){
		return parity;
	}

	public boolean isSupportsCD() {
		return supportsCD;
	}
	

	public void setSupportsCD(boolean supportsCD) {
		this.supportsCD = supportsCD;
	}
	

}