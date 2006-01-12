/*
 * Created on Feb 8, 2004
 *
 */
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
		if (name.equals("SELECT")) {
			String resultsString = rootElement.getText();
			synchronized (eLife) {
				eLife.setConfigResult (resultsString);
			}
		}
		if (name.equals("FILE")) {
			String sourceDir = rootElement.getAttributeValue("DIR");
			String sourceName = rootElement.getAttributeValue ("NAME");
			String base64 = rootElement.getAttributeValue ("BASE64");
			String theFile = rootElement.getText();
			if (base64 != null && base64.equals("Y")) {
				theFile = Base64Coder.decode(theFile);
			}
			synchronized (eLife) {
				eLife.createFileBuffer (theFile,sourceDir,sourceName,true);
			}
		}
		if (name.equals("FILE_TRANSFER")) {
			String sourceDir = rootElement.getAttributeValue("DIR");
			String sourceName = rootElement.getAttributeValue ("NAME");
			String base64 = rootElement.getAttributeValue ("BASE64");
			String theFile = rootElement.getText();
			if (base64 != null && base64.equals("Y")) {
				theFile = Base64Coder.decode(theFile);
			}
			synchronized (eLife) {
				eLife.createFileBuffer (theFile,sourceDir,sourceName,false);
			}
		}
		if (name.equals("STARTUP_FILE")) {
			String startupFile = rootElement.getAttributeValue ("NAME");
			synchronized (eLife) {
				eLife.setStartupFile(startupFile);
			}
		}		
		if (name.equals("DELETE")) {
			String resultsString = rootElement.getText();
			String dir = rootElement.getAttributeValue ("DIR");
			synchronized (eLife) {
				setResults (dir,resultsString);
				eLife.readFiles(dir);
			}	
		}
		if (name.equals("UPLOAD")) {
			String result = rootElement.getAttributeValue ("RESULT");
			String dir = rootElement.getAttributeValue ("DIR");
			if (result.equals ("SUCCESS")) {
				synchronized (eLife) {
					setResults (dir,"Buffer uploaded succesfully");
					eLife.readFiles(dir);
				}				
			} else {
				String resultsString = rootElement.getText();
				setResults (dir,resultsString);
			}
		}	
		if (name.equals("FILES")) {
			String dir = rootElement.getAttributeValue("DIR");
			if (dir != null && !dir.equals ("")) {
				FileList fileList = new FileList (dir);
				List eachFile = rootElement.getChildren("FILE");
				Iterator eachFileIter = eachFile.iterator();
				while (eachFileIter.hasNext()) {
					Element file = (Element)eachFileIter.next();
					String fileName = file.getAttributeValue ("NAME");
					String timestamp = file.getAttributeValue ("MOD");
					String desc = file.getAttributeValue ("DESC");
					fileList.addItem(fileName,desc,timestamp);	
				}
				if (dir.endsWith("config")) {
					eLife.getConfigsPanel ().setFileList (fileList);
				}
				if (dir.endsWith("script")) {
					eLife.getScriptsPanel ().setFileList (fileList);
				}			
				if (dir.endsWith("datafiles")) {
					eLife.getDataFilesPanel ().setFileList (fileList);
				}
				if (dir.endsWith("client-core")) {
					eLife.getClientCorePanel ().setFileList (fileList);
				}
				if (dir.endsWith("client")) {
					eLife.getClientPanel ().setFileList (fileList);
				}
				if (dir.endsWith("RRDDefinition")) {
					eLife.getJRobinRRDPanel ().setFileList (fileList);
				}
				if (dir.endsWith("GraphDefinition")) {
					eLife.getJRobinGraphPanel ().setFileList (fileList);
				}		
				if (dir.endsWith("log")) {
					eLife.getServerLogPanel ().setFileList (fileList);
				}	
			}
		}
	}

	public void setResults (String dir, String resultsString) {
		synchronized (eLife) {

			if (dir.endsWith("config")) {
				eLife.setConfigResult (resultsString);
			}
			if (dir.endsWith("script")) {
				eLife.setScriptsResult (resultsString);
			}			
			if (dir.endsWith("datafiles")) {
				eLife.setDataFilesResult (resultsString);
			}
			if (dir.endsWith("client-core")) {
				eLife.setClientCoreResult (resultsString);
			}
			if (dir.endsWith("client")) {
				eLife.setClientResult (resultsString);
			}
			if (dir.endsWith("RRDDefinition")) {
				eLife.setJRobinRRDResult (resultsString);
			}
			if (dir.endsWith("GraphDefinition")) {
				eLife.setJRobinGraphResult (resultsString);
			}
			if (dir.equals(logDir)) {
				eLife.setServerLogResult (resultsString);
			}
		}
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
