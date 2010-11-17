/*
 * Created on Aug 18, 2004
 *
 */
package au.com.BI.GC100;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;
import java.util.Map.Entry;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;

/**
 * @author colin Canfield
 *
 *This class provides the main interface for the IR database
 */
public class IRCodeDB {
	protected Map <String,Map<String,String>> devices;
	protected Map <String,Map<String,String>> deviceItemFreqs;

	protected Logger logger;
	protected String fileName = "";

	public IRCodeDB() {
	    devices = new LinkedHashMap<String,Map<String,String>> (100);
	    deviceItemFreqs = new LinkedHashMap <String,Map<String,String>>(100);

		logger = Logger.getLogger(this.getClass().getPackage().getName());
		readIRCodesFile("datafiles" + File.separator + "ircodes.xml");
	}
	
	private String previousDevice = "";
	private Map <String,String> dbItems;
	private Map <String,String>dbFrequencies;
	
	public Set <String>getDevices () {
		return devices.keySet();
	}
	
	public Set <String> getActions (String device) {
		if (devices.containsKey( device)) {
		    LinkedHashMap<String,String> dbItems = (LinkedHashMap<String,String>)devices.get(device);
		    if (dbItems != null) {
			    return dbItems.keySet();		    	
		    } else {
		    		return null;
		    }
		} else  {
			return null;
		}
	}
	
	public boolean add (String deviceName, String key, String frq, String vals) {

	    if (!deviceName.equals(previousDevice)) { 
			if (devices.containsKey( deviceName)) {
			    dbItems = devices.get(deviceName);
			    dbFrequencies = deviceItemFreqs.get(deviceName);		    
			}
			else {
			    dbItems = new LinkedHashMap<String,String> (10);
			    dbFrequencies = new LinkedHashMap<String,String> (10);
			}
	    }
		dbItems.put(key, vals);
		dbFrequencies.put(key, frq);

		devices.put (deviceName,dbItems);
	    deviceItemFreqs.put(deviceName,dbFrequencies);		    

	    return true;
	}

	public boolean writeIRCodesFile(String fileName)  {
		try	 {
		    Document irCodeDb = buildIRXMLFile ();
		    
		    if (irCodeDb != null ) {
				        
				XMLOutputter xmlOut = new XMLOutputter (Format.getPrettyFormat());
				File outputFile = new File (fileName+".new");
				FileWriter out = new FileWriter(outputFile);
				xmlOut.output(irCodeDb,out) ;
				out.flush();
				out.close();
				logger.log (Level.INFO,"IR DB write succeeded." + fileName + ".xml");
				
				File oldFile = new File (fileName+".xml");
				File newName = new File (fileName+".old");
				
				
				if (oldFile.exists()) {
				    if (newName.exists() && !newName.delete()) {
					    logger.log (Level.SEVERE, "Could not delete old backup ir codes file "+oldFile.getName());
					    return false;
				    }
					if (!oldFile.renameTo (newName)) { 
					    logger.log (Level.SEVERE, "Could not rename old file "+oldFile.getName()+" to " + newName.getName());
					    return false;
					}
				}

				if (!outputFile.renameTo(oldFile)) {
				    logger.log (Level.SEVERE, "Could not rename new file "+outputFile.getName()+" to " + oldFile.getName());
				    return false;
				} else {
					logger.log (Level.FINE,"IR DB file updated.");
					return true;
				}
		    }else {
		        logger.log (Level.SEVERE,"XML representation of IR codes failed.");
		        return false;
		    }
		}
		catch (IOException ex)
		{
			logger.log (Level.FINER, "IO error saving IR Codes file " + ex.getMessage());
			return false;
		}
	}

	public void addIRElements (Element topElement) {

		for (String device:devices.keySet()){
				
//			Map <String,String>dbItems = (LinkedHashMap<String,String>)devices.get(device);

			Element deviceElement = new Element ("IR_DEVICE");
	        deviceElement.setAttribute ("NAME",device);
	        deviceElement.setAttribute ("DESCRIPTION","");
	        topElement.addContent(deviceElement);
			    
			for(Entry<String, String> e :  devices.get(device).entrySet())
			{
				String nextKey = e.getKey();
//			for (String nextKey: dbItems.keySet()){

			    Element nextCode = new Element ("IR_CODE");
			    nextCode.setAttribute("KEY",nextKey);
			    if (deviceElement != null) deviceElement.addContent(e.getValue());
			}
		}		
	}

	public Document buildIRXMLFile () {

		Document doc = new Document();
		Element topElement = new Element ("IRCODES"); 
		doc.addContent(topElement);
		
		for (String device:devices.keySet()){
		    
//			Map <String,String>dbItems = (LinkedHashMap<String,String>)devices.get(device);
			Map <String,String>dbFrequencies = (LinkedHashMap<String,String>)deviceItemFreqs.get(device);		

			Element deviceElement = new Element ("DEVICE");
	        deviceElement.setAttribute ("NAME",device);
	        deviceElement.setAttribute ("DESCRIPTION","");
	        topElement.addContent(deviceElement);

		    
			for(Entry<String, String> e :  devices.get(device).entrySet())
			{
				String nextKey = e.getKey();
//			for (String nextKey: dbItems.keySet()){

			    Element nextCode = new Element ("CODE");
			    nextCode.setAttribute("KEY",nextKey);
			    nextCode.setAttribute("VALS",(String)e.getValue());
			    nextCode.setAttribute("FRQ",(String)dbFrequencies.get(nextKey));
			    if (deviceElement != null) deviceElement.addContent(nextCode);
			}
		}
		
		return doc;

	}

	@SuppressWarnings("unchecked")
	public boolean readIRCodesFile(String fileName)  {
		SAXBuilder builder = null;
		Element macrosElement;
		
		builder = new SAXBuilder();
		Document doc;

		devices.clear();
	    deviceItemFreqs.clear();
	    previousDevice = "";
		
		try {
			doc = builder.build(fileName);
			macrosElement = doc.getRootElement();
			for (Element device:(List<Element>)macrosElement.getChildren()){
				String deviceName = device.getAttributeValue("NAME");
				
				if (deviceName != null && !deviceName.equals("")) {
					for (Element code:(List<Element>)device.getChildren()){
						String irCodeKey = code.getAttributeValue("KEY");
						String irCodeFreq = code.getAttributeValue("FRQ");
						String irCodeVal = code.getAttributeValue("VALS");
				
						this.add( deviceName,irCodeKey,irCodeFreq,irCodeVal);
					}
				}
				else{
				    logger.log (Level.WARNING,"Device specificiation in the IR Code file does include a name");
				}
			}
		} catch (JDOMException e) {
			logger.log(Level.WARNING,"Error in parsing IR Codes file "+ e.getLocalizedMessage());
			return false;
		} catch (IOException e) {
			logger.log(Level.WARNING,"IO error in reading IR Codes file "+ e.getLocalizedMessage());
			return false;
		}
		logger.log (Level.FINE,"Read IR codes file: " + fileName);
		return true;
	}
	
	
	/**
	 * On being passed a Device.Action string this method will return the appropriate IR codes if known 
	 * @param codeName
	 * @return
	 */
	public String getCode (String codeName) {
	    String codeNameBits[] = codeName.split("\\.",2);
	    String code = "";
	    try {
		    String deviceName = codeNameBits [0];
		    String codeKey = codeNameBits [1];
		    if (deviceName == null || deviceName.equals (""))
		        return "";
		    if (codeKey == null || codeKey.equals (""))
		        return "";

			if (devices.containsKey( deviceName)) {
			    Map<String,String> dbItems = (LinkedHashMap<String,String>)devices.get(deviceName);
			    if (dbItems == null) {
			        logger.log(Level.INFO,"GC100 IR code DB inconsistent.");
			        return "";
			    }
			    if (dbItems.containsKey(codeKey))
					code = (String)dbItems.get(codeKey);
				else
					return "";
			}
			else 
			    return "";
			
			String newCode = code.substring(code.indexOf(",")+1);
			return newCode;
		    
	    } catch (ArrayIndexOutOfBoundsException ex) {
	        logger.log (Level.SEVERE,"Code " + codeName + " should be in DEVICE.KEY format");
	        return "";
	    }
	}
	
	public String getFrequency (String codeName) {
	    String codeNameBits[] = codeName.split("\\.",2);
	    
	    try {
		    String deviceName = codeNameBits [0];
		    String codeKey = codeNameBits [1];
		    if (deviceName == null || deviceName.equals (""))
		        return "";
		    if (codeKey == null || codeKey.equals (""))
		        return "";
		    
			if (devices.containsKey( deviceName)) {
			    Map <String,String>dbFrequencies = (LinkedHashMap<String,String>)deviceItemFreqs.get(deviceName);
			    if (dbFrequencies == null) {
			        logger.log(Level.INFO,"GC100 IR code DB inconsistent.");
			        return "";
			    }
			    if (dbFrequencies.containsKey(codeKey))
					return (String)dbFrequencies.get(codeKey);
				else
					return "";
			}
			else 
			    return "";
		    
	    } catch (ArrayIndexOutOfBoundsException ex) {
	        logger.log (Level.SEVERE,"Code " + codeName + " should be in DEVICE.KEY format");
	        return "";
	    }
	}
}
