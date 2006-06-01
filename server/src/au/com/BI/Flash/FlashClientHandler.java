/*
 * Created on Feb 16, 2004
 *
 */
package au.com.BI.Flash;

import java.net.*;
import java.io.*;
import java.util.logging.*;
import java.util.*;
import au.com.BI.Util.TEA;
import java.security.InvalidKeyException;
import org.jdom.*;
import org.jdom.input.SAXBuilder;

import au.com.BI.Calendar.EventCalendar;
import au.com.BI.Comms.*;
import au.com.BI.Macro.*;
import au.com.BI.Command.ClientCommandFactory;

/**
 * @author Colin Canfield
 * 
 */
public class FlashClientHandler extends Thread {
	protected Logger logger;
	protected Socket clientConnection;
	protected boolean thisThreadRunning;
	protected InputStream i;
	protected OutputStream o;
	protected List commandList;
	protected MacroHandler macroHandler = null;
	protected EventCalendar eventCalendar;
	protected long connectionTime;
	protected ClientCommandFactory clientCommandFactory;
	protected long serverID;
	protected long ID;
	protected List clientList; // used to remove this thread in case of
								// disaster

	protected BufferedReader rd;

	private TEA decrypter = null;

	public FlashClientHandler(Socket connection, List commandList,
			List clientList,ClientCommandFactory clientCommandFactory) throws ConnectionFail {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		clientConnection = connection;
		this.commandList = commandList;
		this.ID = clientCommandFactory.getID();
		this.clientCommandFactory = clientCommandFactory;
		this.setName("Flash Client Handler");

		byte[] key = new byte[] { 1, 2, 3, 4 };
		decrypter = new TEA();
		try {
			decrypter.engineInit(key, true);
		} catch (InvalidKeyException ex) {
			logger
					.log(Level.SEVERE,
							"An invalid key has been specified for Flash communitation");
		}

		// try {
		// clientConnection.setTcpNoDelay(true);
		// clientConnection.setSoTimeout(60000);
		// } catch (SocketException se) {
		// throw new ConnectionFail ("Connection failed",se);
		// }

		try {
			i = clientConnection.getInputStream();
			o = clientConnection.getOutputStream();
			rd = new BufferedReader(new InputStreamReader(connection
					.getInputStream()));
		} catch (IOException ioe) {
			throw new ConnectionFail("Could not get communication streams", ioe);
		}

		thisThreadRunning = false;
	}

	public void kill() {
		thisThreadRunning = false;
	}

	/**
	 * @param commandList
	 *            The synchronised fifo queue for ReceiveEvent objects
	 */
	public void setCommandList(List commandList) {
		this.commandList = commandList;
	}

	public void run() {
		logger.info("Client connection received. Handler started");
		thisThreadRunning = true;
		Document xmlDoc = null;

		SAXBuilder saxb = new SAXBuilder(false); // get a SAXBuilder

		while (thisThreadRunning) {

			try {
				String nextItem = rd.readLine();
				if (nextItem != null) {
					nextItem = nextItem.trim();
					if (!nextItem.equals("")) {
						InputStream xmlStream = new ByteArrayInputStream(
								nextItem.getBytes());

						try {
							xmlDoc = saxb.build(xmlStream);
							Element rootElement = xmlDoc.getRootElement();
							String name = rootElement.getName();
							ClientCommand clientCommand = null;
							if (name.equals("encrypted")) {
								logger
										.log(Level.FINER,
												"An encrypted packet has been received.");
								String data = rootElement.getText();
								byte[] decryptedPacket = null;
								byte[] srcBytes = data.getBytes();
								for (int i = 0; i < data.length(); i += decrypter.BLOCK_SIZE) {
									// byte[] decryptedPacket =
									// decrypter.engineCrypt
									// (data.substring(i * decrypter.BLOCK_SIZE,
									// (i + 1) * decrypter.BLOCK_SIZE
									// -1).getBytes(),i);
									decryptedPacket = decrypter.engineCrypt(
											srcBytes, i);

								}

								xmlDoc = saxb.build(data);
								rootElement = xmlDoc.getRootElement();
								clientCommand = clientCommandFactory.processXML(rootElement);
							} else {
								clientCommand = clientCommandFactory.processXML(rootElement);
							}
							if (clientCommand != null) {
								synchronized (commandList) {
									commandList.add(clientCommand);
									commandList.notifyAll();
								}
							}
						} catch (JDOMException ex) {
							logger.log(Level.WARNING,
									"XML message from Flash client was invalid "
											+ ex.getMessage());
						} catch (ArrayIndexOutOfBoundsException ex) {
							logger.log(Level.WARNING,
									"Flash sent an invalid encrypted message");
						}

					}
				} else {
					try {
						Thread.sleep(500); // hang around for a short time
					} catch (InterruptedException e) {

					}

				}
			} catch (IOException ex) {
				thisThreadRunning = false;
				logger.log(Level.FINER,
						"IO Exception communicating with client");
			}

			Thread.yield(); // ensure another process always has a chance
		}

	}

	/**
	 * @TODO properly return a message block
	 */

	public void processBuffer(String readBuffer)

	{
		SAXBuilder saxb = new SAXBuilder(false); // get a SAXBuilder
		Document xmlDoc; // xml document object to work with

		logger.log(Level.FINEST, "Received string from client, processing");
		// the array sent to the XML builder cannot have any extra space at the
		// end
		// so we create a new array and copy everything accumulated in
		// "readBuffer"

		try {
			xmlDoc = saxb.build(new StringReader(readBuffer));
			Element rootElement = xmlDoc.getRootElement();
			ClientCommand clientCommand = clientCommandFactory.processXML(rootElement);
			if (clientCommand != null) {
				synchronized (commandList) {
					commandList.add(clientCommand);
					commandList.notifyAll();
				}
			}
		} catch (JDOMException ex) {
			logger.log(Level.WARNING, "XML ERROR " + ex.getMessage());
			/*
			 * Element error = new Element("error"); error.setAttribute("msg",
			 * "JDOM parsing error"); Document replyDoc = new Document(error);
			 * sendXML (replyDoc);
			 */
		} catch (IOException io) {
			logger.log(Level.SEVERE, "IO failed communicating with client "
					+ io.getMessage());
			this.clientList.remove(this);
		}
	}

	/**
	 * @TODO properly return a message block
	 */

	public void processBuffer(byte[] readBuffer, int count)

	{
		SAXBuilder saxb = new SAXBuilder(false); // get a SAXBuilder
		Document xmlDoc; // xml document object to work with

		logger.log(Level.FINEST, "Received string from client, processing");
		// the array sent to the XML builder cannot have any extra space at the
		// end
		// so we create a new array and copy everything accumulated in
		// "readBuffer"

		byte[] xmlByte = new byte[count];
		System.arraycopy(readBuffer, 0, xmlByte, 0, count);

		// build a Stream from the array
		ByteArrayInputStream bais = new ByteArrayInputStream(xmlByte);

		try {
			xmlDoc = saxb.build(bais);
			Element rootElement = xmlDoc.getRootElement();
			clientCommandFactory.processXML(rootElement);
		} catch (JDOMException ex) {
			logger.log(Level.WARNING, "XML ERROR " + ex.getMessage());
			/*
			 * String badElement = new String(xmlByte);
			 * System.out.println(badElement); Element error = new
			 * Element("error"); error.setAttribute("msg", "JDOM parsing error,
			 * illegal message from the Client"); Document replyDoc = new
			 * Document(error); sendXML (replyDoc);
			 */
		} catch (IOException io) {
			logger.log(Level.SEVERE, "IO failed communicating with client");
			this.clientList.remove(this);
		}
	}

	public void setMacroHandler(MacroHandler macroHandler) {
		this.macroHandler = macroHandler;
	}


	public long getConnectionTime() {
		return connectionTime;
	}

	public void setConnectionTime(long connectionTime) {
		this.connectionTime = connectionTime;
	}

	public long getServerID() {
		return serverID;
	}

	public void setServerID(long serverID) {
		this.serverID = serverID;
	}

	public boolean isThisThreadRunning() {
		return thisThreadRunning;
	}

	public void setThisThreadRunning(boolean thisThreadRunning) {
		this.thisThreadRunning = thisThreadRunning;
	}

	public long getID() {
		return ID;
	}

	public void setID(long id) {
		ID = id;
	}

}
