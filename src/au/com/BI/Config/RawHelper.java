package au.com.BI.Config;

import au.com.BI.Device.DeviceType;
import au.com.BI.Util.Utility;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import org.jdom.Element;


public class RawHelper {

	public void checkForRaw(Element element, DeviceType destDevice){
		List<Element> rawLists = element.getChildren("RAW_ITEMS");
		if (rawLists.isEmpty()){
			destDevice.setRawCodes(null);
			return;
		}
		HashMap<String, RawItemDetails> rawItemDefs = new HashMap<String, RawItemDetails> (DeviceType.PROBABLE_NUMBER_RAW);
		Iterator<Element> eachRawList = rawLists.iterator();
		while (eachRawList.hasNext()){
			Element rawItemList = (Element)eachRawList.next();
			String catalogue = rawItemList.getAttributeValue("CATALOGUE");
			List<Element> rawItemDefList = rawItemList.getChildren("RAW");
	
			Iterator<Element> eachRawItem = rawItemDefList.iterator();
			while (eachRawItem.hasNext()){
				Element rawItem = (Element)eachRawItem.next();
				String code = rawItem.getAttributeValue("CODE");
				String extra = rawItem.getAttributeValue("EXTRA");
	
				List<Element> variables = rawItem.getChildren("VARS");
	
				RawItemDetails rawItemDetails;
	
				if (variables.isEmpty()) {
					rawItemDetails = new RawItemDetails (catalogue, code, null);
				}
				else {
					HashMap<String, String> variableMap = new HashMap<String, String> (10); // random number
					Iterator<Element> eachVariable = variables.iterator();
					while (eachVariable.hasNext()){
						Element nextVariable = (Element)eachVariable.next();
						String varName = nextVariable.getAttributeValue("NAME");
						String varValue = Utility.unEscape(nextVariable.getAttributeValue("VALUE"));
						variableMap.put(varName,varValue);
					}
					rawItemDetails = new RawItemDetails (catalogue, code,variableMap);
				}
	
				String theKey = rawItem.getAttributeValue("COMMAND");
				if (extra != null && !extra.equals(""))
					theKey += ":" + extra;
				rawItemDefs.put(theKey,rawItemDetails);
			}
	
		}
		destDevice.setRawCodes(rawItemDefs);
	}

}
