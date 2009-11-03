/**
 * 
 */
package au.com.BI.CustomConnect;

import java.util.LinkedList;
import java.util.List;


/**
 * @author colin
 *
 */
public class CustomConnectInput {
	List <CustomConnectInputDetails> customConnectInputDetailsList = null;
	List <CustomConnect> customConnectList = null;
	
	public CustomConnectInput() {
		customConnectInputDetailsList = new LinkedList<CustomConnectInputDetails>();
	}

	public void addCustomConnectInputDetails (CustomConnectInputDetails customConnectInputDetails) {
		customConnectInputDetailsList.add (customConnectInputDetails);
	}
	
	public List<CustomConnectInputDetails> getCustomConnectInputDetails() {
		return customConnectInputDetailsList;
	}

	public List<CustomConnect> getCustomConnectList() {
		return customConnectList;
	}

	public void setCustomConnectList(List<CustomConnect> customConnectList) {
		this.customConnectList = customConnectList;
	}
	
}
