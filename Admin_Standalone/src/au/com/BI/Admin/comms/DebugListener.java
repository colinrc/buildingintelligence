package au.com.BI.Admin.comms;
/*
 * Created on Feb 8, 2004
 *
 */
import au.com.BI.Admin.Home.Admin;
import java.io.*;
import java.util.logging.*;
import org.xml.sax.*;
import org.xml.sax.helpers.DefaultHandler;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;

/**
 * @author Colin Canfield
 *
 **/


public class DebugListener extends Thread
{
	protected InputStream is;
	protected volatile boolean handleEvents = false;
	protected Admin eLife;
	protected BufferedReader rd = null;
	protected Logger logger;
	protected SAXParser debugReader;
	protected ConnectionManager manager;
	private String lastStr = "";

	
	/**
	 * The main constructor
	 */
	public DebugListener ( ) {
		this.setName("Debug Listener");
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

	public void seteLife (Admin eLife){
		this.eLife = eLife;
	}

	
	public void run () {
		handleEvents = true;
		String str;

		//InputSource inSrc = new InputSource (rd);
		DebugContentHandler debugContentHandler = new DebugContentHandler ();
		debugContentHandler.setELife(eLife);
		
		while (handleEvents)
		{
			try {
				
				String nextStr = rd.readLine();
				lastStr = nextStr;
				if (nextStr != null ) {
					nextStr = nextStr.trim();
					if (!nextStr.startsWith("<?xml")) {
						StringReader newSrc = new StringReader (nextStr);
						debugReader.parse (new InputSource(newSrc),debugContentHandler);
					}
				}else {
			    		try {
							rd.close();
						} catch (IOException e2) {
						}
			    		setHandleEvents (false);
	    				synchronized (manager) {
    						manager.disconnectMonitor();
	    				}
	    				synchronized (eLife){
	    					eLife.setELifeConnectionStatus(false);
	    				}
				}
				
				// debugReader.parse (inSrc,debugContentHandler);
	
		    } catch (IOException e) {
		    		logger.log (Level.FINE,"Lost connection closing " + e.getMessage());
		    		try {
						rd.close();
					} catch (IOException e2) {}
		    		setHandleEvents (false);
    				synchronized (manager) {
						manager.disconnectMonitor();
        				/* try {
							manager.closeDebug(false);
						} catch (ConnectionFail e1) {
						} */
    				}
		   } catch (SAXException ex)
        		{
		   		logger.log (Level.INFO,"Received an error parsing " + lastStr);
        			logger.log (Level.WARNING,"XML ERROR " + ex.getMessage());
        		}
			Thread.yield(); // give other clients a chance
		}

	} 

	/**
	 * @param manager The manager to set.
	 */
	public void setManager(ConnectionManager manager) {
		this.manager = manager;
	}
}
