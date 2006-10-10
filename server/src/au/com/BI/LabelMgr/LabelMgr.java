/**
 * 
 */
package au.com.BI.LabelMgr;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;

import au.com.BI.Config.ConfigError;

/**
 * @author colin
 *
 */
public class LabelMgr {
    Logger logger;
	HashMap <String,String>labels;
	ConcurrentHashMap <String,String>labelState;
	
	public LabelMgr () {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
		labels = new HashMap <String,String>();
		labelState = new ConcurrentHashMap <String,String>();		
	}
	
	public void clearLabels () {
		labels.clear();
		labelState.clear();
	}
	
	public void readLabelFile (String baseDir, String fileName) throws LabelError {
		clearLabels();
		
	      try {
	            SAXBuilder builder = null;
	            
	            builder = new SAXBuilder();
	            Document doc = builder.build(baseDir + File.separator + fileName);
	            Element theLabels= doc.getRootElement();
	            List <Element> textLabelCatalogues = theLabels.getChildren ("TEXT");
	            for (Element i: textLabelCatalogues){
			        for (Element eachLabel: (List<Element>)i.getChildren()){
		            	String key = eachLabel.getAttributeValue("KEY");
		            	String value = eachLabel.getAttributeValue("VALUE");
		            	this.addLabel(key, value);
			        }
	            }
		            
		    } catch (JDOMException e) {
		        throw new LabelError(e);
		    } catch (IOException e) {
		        logger.log(Level.FINE,"An IO error occured reading the labels file " + e.getMessage() );
		    }		  
	}
	
	public void setLabelState (String displayName, String labelKey){
		labelState.put(displayName, labelKey);
	}
	

	public String getLabelState (String displayName){
		return labelState.get(displayName);
	}

	public void addLabel (String key, String value){
    	if (key != null && !key.equals("") && value != null && !value.equals("")){
    		this.labels.put(key, value);
    	} else {
    		logger.log (Level.WARNING,"There is an error in the label configuration file");
    	}
	}
	
	public String getLabelText (String labelKey) {
		if (labels.containsKey(labelKey))
			return labels.get(labelKey);
		else
			return "";
	}
	
	
}
