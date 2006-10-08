/**
 * 
 */
package au.com.BI.LabelMgr;

import java.util.HashMap;

/**
 * @author colin
 *
 */
public class LabelMgr {
	HashMap <String,String>labels;
	HashMap <String,String>labelState;
	
	public LabelMgr () {
		labels = new HashMap <String,String>();
		labelState = new HashMap <String,String>();		
	}
	
	public void clearLabels () {
		
	}
	
	public void readLabelFile (String baseDir, String fileName){
		
	}
	
	public void setLabelState (String displayName, String labelKey){
		labelState.put(displayName, labelKey);
	}
	

	public String getLabelState (String displayName){
		return labelState.get(displayName);
	}

	
	public String getLabelText (String labelKey) {
		if (labels.containsKey(labelKey))
			return labels.get(labelKey);
		else
			return "";
	}
	
	
}
