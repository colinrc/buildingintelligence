package au.com.BI.Admin.comms;
/*
 * Created on Feb 8, 2004
 *
 */
import au.com.BI.Admin.util.FileList;
import au.com.BI.Admin.Home.Admin;
import java.io.*;
import java.util.logging.*;
import java.util.List;
import java.util.Iterator;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.xml.sax.*;
import javax.swing.JOptionPane;

import javax.xml.parsers.SAXParserFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;

/**
 * @author Colin Canfield
 *
 **/


public class AdminListener extends Thread
{
	protected InputStream is;
	protected OutputStream os;
	protected volatile boolean handleEvents = false;
	protected Admin eLife;
	protected String logDir = "";
	protected BufferedReader rd = null;
	protected Logger logger;
	protected SAXParser debugReader;
	protected ConnectionManager manager;
	private int cnt = 0;
	
	/**
	 * The main constructor
	 */
	public AdminListener ( ) {
		this.setName("Admin Listener");
		logger = Logger.getLogger("Log");
		 try {
		 	SAXParserFactory factory = SAXParserFactory.newInstance();
		 	
		 	debugReader = factory.newSAXParser();
		 	//debugReader.setFeature();
		  } catch (SAXException e) {
		    logger.log (Level.SEVERE ,"Could not create debug parser " + e.getMessage());
		  } catch (ParserConfigurationException e) {
		    logger.log (Level.SEVERE ,"Parser configuration error " + e.getMessage());
		  }
	}
	
	/**
	 * start or stop handling events, eg. if closing down
	 * @param flag
	 */
	public   void setHandleEvents (boolean flag) {
		this.handleEvents = flag;
	}

	
	public void setInputStream (InputStream  is){
		if (is != null) {
			this.is = is;
	        rd = new BufferedReader(new InputStreamReader(is));
		}
	}

	
	public void setOutputStream (OutputStream  os){
		if (os != null) {
			this.os = os;
		}
	}
	
	public void seteLife (Admin eLife){
		this.eLife = eLife;
	}

	private String lastStr;


	public void run () {

		StringBuffer soFar = new StringBuffer();
		int lenBuf = 1024;
		byte[] buf = new byte[lenBuf];
		boolean isConnected = true;
		handleEvents = true;

		while(isConnected && handleEvents) {
		    try {
				// play nice with the other threads and surrender the CPU
				Thread.sleep(20);
			} catch (InterruptedException e) {}
			
		    // collect all the bytes waiting on the input stream
		    int avail;
			try {
				avail = is.available();

				while (avail > 0) {
					int amt = avail;
					if (amt > lenBuf) {
						amt = lenBuf;
					}
					amt = is.read(buf, 0, amt);
	
			        int marker = 0;
			        for (int i=0; i<amt; i++) {
			            // scan for the zero-byte EOM delimiter
			            if (buf[i] == (byte)0) {
			                String tmp = new String(buf, marker, i - marker);
			                soFar.append(tmp);
			                int length = soFar.length();
			                if (length > 0) {
			                		processBuffer ( soFar.toString().getBytes(),soFar.length());
			                }
			                soFar.setLength(0);
			                marker = i + 1;
			            }
			        }
			        if (marker < amt) {
			            // save all so far, still waiting for the final EOM
			            soFar.append( new String(buf, marker, amt-marker) );
			        }
				avail = is.available();
				}
			} catch (IOException e) {
				isConnected = false;
		    		logger.log (Level.FINE,"Lost connection closing " + e.getMessage());
		    		try {
						rd.close();
					} catch (IOException e2) {}
					setHandleEvents (false);
					synchronized (manager) {
						manager.disconnectAdmin();
					}
					synchronized (eLife){
						eLife.setAdminConnectionStatus(false);
					}
				}
		}
	}
	
	public void processBuffer (byte [] readBuffer, int count)
	
	{
		SAXBuilder saxb = new SAXBuilder(false); //get a SAXBuilder
		Document xmlDoc;           // xml document object to work with

		logger.log(Level.FINEST,"Received string from client, processing");
		// the array sent to the XML builder cannot have any extra space at the end
		// so we create a new array and copy everything accumulated in "readBuffer"
		
		byte[] xmlByte = new byte[count];
		System.arraycopy(readBuffer,0,xmlByte,0,count);

		//build a Stream from the array
		ByteArrayInputStream bais = new ByteArrayInputStream(xmlByte);
		
		try
		{
			xmlDoc = saxb.build(bais); 
			processXML(xmlDoc);
		}
		catch (JDOMException ex)
		{
			String errorXML = new String (xmlByte);
			logger.log (Level.WARNING,"XML ERROR " + ex.getMessage());
			eLife.showMessage(ex.getMessage(),JOptionPane.ERROR_MESSAGE);
			logger.log (Level.WARNING,"XML " + errorXML);			
		}
		catch (IOException io){
			logger.log(Level.WARNING, "IO failed communicating with client");
			// Work out how to close the connection!
		}
	}
	
	protected void processXML (Document xmlDoc){

		String name = ""; // the name of the node
		String key = "";
		boolean commandBuilt = false;
		
		Element rootElement = xmlDoc.getRootElement(); 
		name = rootElement.getName();
		logger.log (Level.FINER,"ELEMENT "+ name);
		
		if (name.equals("EXEC")) {
			String execString = "";
			execString += rootElement.getChildText("EXEC_OUTPUT");
			execString += rootElement.getChildText("EXEC_ERROR");
			synchronized (eLife) {
				eLife.setExecResult (execString);
			}
		}
		if (name.equals("ERROR")) {
			String errorString = rootElement.getText();
			logger.log (Level.WARNING,"Error " + errorString);
			eLife.showMessage (errorString,JOptionPane.ERROR_MESSAGE);
		}
		if (name.equals("ALREADY_IN_USE")) {
			String errorString = rootElement.getText();
			this.setHandleEvents(false);
			eLife.disconnectAdmin(false);
			logger.log (Level.WARNING,"Error " + errorString);
			eLife.alreadyInUse (errorString,JOptionPane.ERROR_MESSAGE);
		}
	
	}

	public void setResults (String dir, String resultsString) {
	}

	
	/**
	 * @param manager The manager to set.
	 */
	public void setManager(ConnectionManager manager) {
		this.manager = manager;
	}

	public String getLogDir() {
		return logDir;
	}

	public void setLogDir(String logDir) {
		this.logDir = logDir;
	}
}
