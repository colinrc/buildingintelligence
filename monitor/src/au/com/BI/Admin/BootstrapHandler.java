package au.com.BI.Admin;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;

import au.com.BI.Servlets.CommandFail;

public class BootstrapHandler {
	
    protected Logger logger;
    
	public BootstrapHandler () {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	
	public String getBootstrapParameter (String datafiles, String parameter) throws CommandFail {

	    String startupFile = null;
	
	    try {
			String fileName = datafiles + "/bootstrap.xml";
			File theFile = new File (fileName);
			
			SAXBuilder saxb = new SAXBuilder(false); 
			Document bootstrap = saxb.build (theFile);
			
			Element topBoot = bootstrap.getRootElement();
			Element bootup = topBoot.getChild(parameter);
			if (bootup == null){
				return null;
			} else {
				startupFile = bootup.getAttributeValue("NAME");
			}
			return startupFile;
	
				
		} catch (IOException e) {
				throw new CommandFail ("IO_ERROR","IO Error writing the file " + e.getMessage());
		
		} catch (JDOMException e1) {
				throw new CommandFail ("BOOTSTRAP_FAIL","XML parse error on the bootstrap file " + e1.getMessage());
		}
	}


	  public void setBootstrapParameter (String datafiles, String parameter, String extra) throws CommandFail {
		try {
			String fileName = datafiles+ "/bootstrap.xml";
			File theFile = new File (fileName);
			
			SAXBuilder saxb = new SAXBuilder(false); 
			Document bootstrap = saxb.build (theFile);
			
			Element topBoot = bootstrap.getRootElement();
			Element bootup = topBoot.getChild(parameter);
			if (bootup == null){
				bootup = new Element(parameter);
				topBoot.addContent(bootup);
			}
			bootup.setAttribute("NAME",extra);
			
			File fileToUpload = new File (fileName+".new");
			Document doc = new Document ();
			topBoot.detach();
			doc.setRootElement(topBoot);

			XMLOutputter xmlOut = new XMLOutputter (Format.getPrettyFormat());
			FileWriter out = new FileWriter(fileToUpload);
			xmlOut.output(doc, out) ;
			out.flush();
			out.close();
			logger.log (Level.FINE,"File write succeeded.");
			
			File oldFile = new File (fileName);
			File newName = new File (fileName+".old");
			
			if (oldFile.exists()) {
			    if (newName.exists() && !newName.delete()) {
				    logger.log (Level.SEVERE, "Could not delete old file "+oldFile.getName());
			    	throw new CommandFail("IO_ERROR","Could not delete old file "+oldFile.getName());
			    }
				if (!oldFile.renameTo (newName)) { 
				    logger.log (Level.SEVERE, "Could not rename old file "+oldFile.getName()+" to " + newName.getName());
					throw new CommandFail("IO_ERROR","Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName());
				}
			}

			if (!fileToUpload.renameTo(oldFile)) {
			    logger.log (Level.SEVERE, "Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName());
				throw new CommandFail("IO_ERROR","Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName());
			}
				    
			File finalName = new File (fileName+".old");
		    if (finalName.exists() && !finalName.delete()) {
			    logger.log (Level.SEVERE, "Could not delete old file "+finalName.getName());
			    throw new CommandFail("IO_ERROR","Could not delete old file "+finalName.getName());
		    }

				
		} catch (IOException e) {
			throw new CommandFail("IO_ERROR","IO Error writing the file " + e.getMessage());
		} catch (JDOMException e1) {
			throw new CommandFail("BOOTSTRAP_FAIL","XML parse error on the bootstrap file " + e1.getMessage());
		} catch (NullPointerException e2){
			throw new CommandFail("NULL_POINTER","Error in updating the bootstrap file");
		}
    }
	

}
