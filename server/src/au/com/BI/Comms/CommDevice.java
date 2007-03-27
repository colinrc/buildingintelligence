/*
 * Created on Apr 3, 2004
 *
 */
package au.com.BI.Comms;

/**
 * @author colinc
 * A general interface for comm devices.
 */
public interface CommDevice {
	
	// Types of comms commands I want to keep around
	
	public static final int UnkownCommand = -11;
	public static final int MailboxQuery = 1;
	public static final int AnalogueQuery = 2;	
	public static final int TutondoState = 3;	
	public static final int TutondoPrograms = 4;
	public static final int TutondoVolume = 9;	
	public static final int DynaliteLevel = 10;	
	public static final int HalState = 5;	
	public static final int HalStartup = 6;	
	public static final int GC100_IRCommand = 7;	
	public static final int RawPoll = 8;	
	public static final int PelcoSend = 9;	
	public static final int CBUSTemperature = 10;
	
	public static final int FullLine = 0;
	public static final int BufferLength = 1;
	public static final int KnownChars = 2;
	public static final int NaturalPacket = 3;
	
	

	
	// Time in milliseconds to wait for a command response from a handshake type device until the next command
	// is sent
	public static final int DelayUntilCommandRepeat = 5000;

	public void close () throws ConnectionFail ;
	
	public void sendString (String message) throws CommsFail; 
	public void sendString (byte[] message) throws CommsFail; 
	
	public  boolean isConnected ();

	/** 
	 * Send a comms received command to the controller after x bytes rather than waiting for new line.
	 * @param numberBytes number bytes to receive
	 */
	public void setTransmitMessageOnBytes(int numberBytes);
	public void sendCommandAndKeepInSentQueue (CommsCommand command) throws CommsFail;
	
	public void clearCommandQueue ();
	
	public boolean isCommandQueueEmpty ();
	
	public CommsCommand getFirstCommandInQueue ();
	
	public CommsCommand getLastCommandSent ();

	public void removeFirstCommandInQueue ();
	
	public CommsCommand getLastCommandInQueue ();
	
	public void removeFirstCommandInSentQueue ();
	
	public boolean isCommandSentQueueEmpty ();
	
	public void addCommandToQueue (CommsCommand command) throws CommsFail;

	public boolean sendNextCommand () throws CommsFail;
	
	public boolean sendNextCommand(int actionType, String key) throws CommsFail;	
	
	public boolean sendNextCommand(int actionType) throws CommsFail;	
	
	public boolean repeatLastCommand () throws CommsFail;
	
	public boolean resendAllSentCommands () throws CommsFail;
	
	public boolean repeatCommand (String key) throws CommsFail;
	
	public void gotFeedback();

	public boolean isWaitingForFeedback ();
	
	public boolean sentQueueContainsCommand (int actionType);

	public boolean sentQueueContainsCommand (int actionType, String key);
	
	public void removeAllCommands (int actionType);
	
	/**
	 * Clears a command from the sent queue
	 * @param key If empty or null the last command sent is removed else the key is searched for in the sent queue
	 * @return success if the key is found or not specified
	 */
	public boolean acknowlegeCommand(int actionType);
	public boolean acknowlegeCommand(String key);
	public boolean acknowlegeCommand(int actionType,String key);

	/**
	 * The ETX array is the set of possible values to indicate the end of the data string
	 * @param etxArray
	 */
	public void setETXArray (int etxArray[]);
	
	/**
	 * The STX array is the set of possible values to indicate the start of the data string
	 * @param stxArray. 
	 */
	public void setSTXArray (int stxArray[]);
	
	/**
	 * If the device uses 2 characters to specify end of data string the set can be specified here.
	 * @param penultimateArray
	 */
	public void setPenultimateArray (int penultimateArray[]);
	
	/**
	 * The Intercommand interval allows you to specify a guaranteed minimum time interval between commands issued to a device.
	 * This is used to prevent buffer overrun.
	 * @return The interval in milliseconds
	 */
	public int getInterCommandInterval();

	/**
	 * The Intercommand interval allows you to specify a guaranteed minimum time interval between commands issued to a device.
	 * This is used to prevent buffer overrun.
	 * @param interCommandInterval The interval in milliseconds
	 */
	public void setInterCommandInterval(int interCommandInterval);

	
	/**
	 * The model name is used to assist debugging.
	 * @param modelName The name
	 */
	public void setModelName(String modelName);
	
	/**
	 * The model name is used to assist debugging.
	 * @return The name
	 */
	public String getModelName();
	

	/**
	 * Data packets will be transmitted to models in exactly the format they have arived at the communications port.
	 */
	public void setNaturalPackets(boolean b) ;
}
