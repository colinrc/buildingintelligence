package au.com.BI.Dynalite;

import au.com.BI.Util.*;
import au.com.BI.Config.*;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.*;

public class AreaCodes {
	protected HashMap <String,LinkedList <DynaliteDevice>> areaCodes = null;
	public final static int AreaCommand = 0;
	Logger logger = null;
	ConfigHelper configHelper = null;
	DynaliteHelper dynaliteHelper = null;
	
	public AreaCodes () {
		areaCodes = new HashMap<String,LinkedList <DynaliteDevice>>(10);
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	void clear (){
		areaCodes.clear();
	}
	
	// @TODO fix
	void addJoin ( String areaCode,String toAreaOffsetStr){
		int toAreaOffset = Integer.parseInt(toAreaOffsetStr);
		addJoin (areaCode,toAreaOffset);
	}
	

	void addJoin ( String areaCode,int toAreaOffset){
		
		String paddedKey = Utility.padString (areaCode,2);
		
		if (areaCodes.containsKey(paddedKey)){
			LinkedList devs = (LinkedList)areaCodes.get (paddedKey);
			Iterator devsIter = devs.iterator();
			while (devsIter.hasNext()){
				try {
					DynaliteDevice dev = (DynaliteDevice)devsIter.next();
					int newArea = dev.listensToLinkArea(toAreaOffset);
					if (newArea < 255){
						String paddedToKey = Utility.padStringTohex(newArea);
						this.add(paddedToKey, dev);
					}
				} catch (ClassCastException ex){}
			}
		}
	}

	void removeJoin ( String areaCode,String toArea){
		int toAreaInt = Integer.parseInt(toArea);
		removeJoin (areaCode,toAreaInt);
	}

	void removeJoin ( String areaCode,int toAreaOffset){
		String paddedKey = Utility.padString (areaCode,2);
		if (areaCodes.containsKey(paddedKey)){
			LinkedList devs = (LinkedList)areaCodes.get (paddedKey);
			Iterator devsIter = devs.iterator();
			while (devsIter.hasNext()){
				try {
					DynaliteDevice dev = (DynaliteDevice)devsIter.next();
					int newArea = dev.listensToLinkArea(toAreaOffset);
					if (newArea < 255){
						String paddedToKey = Utility.padStringTohex(newArea);
						this.remove(paddedToKey, dev);
					}
				} catch (ClassCastException ex){}
			}
		}		
		
	}

	void add (String areaCode, DynaliteDevice device){
		LinkedList <DynaliteDevice>keys;
		if (areaCodes.containsKey(areaCode)){
			keys =areaCodes.get(areaCode);
		}else {
			keys = new LinkedList<DynaliteDevice>();
		}
		synchronized (device){
			device.incLinkCount();
		}
		synchronized (keys){
			keys.add(device);
			areaCodes.put(areaCode,keys);
		}
	}
	
	void remove (String areaCode, DynaliteDevice device){
		LinkedList<DynaliteDevice> keys;
		if (!areaCodes.containsKey(areaCode)){
			return;
		}
		keys = areaCodes.get(areaCode);
		synchronized (device){
			device.decLinkCount();
		}
		synchronized (keys){
			if (keys.contains(keys)) areaCodes.remove(device);
			areaCodes.put(areaCode,keys);
		}
	}
	

	List findDevicesInArea (int areaInt, boolean includeAreaControl,int join) {
		String area = Utility.padStringTohex(areaInt);
		return findDevicesInArea (area,includeAreaControl,join);
	}

	List <DynaliteDevice> findDevicesInArea (String area, boolean includeAreaControl,int join) {
		LinkedList <DynaliteDevice>resultList = new LinkedList<DynaliteDevice>();
		for (DynaliteDevice nextItem : areaCodes.get(area)) {

			if (!includeAreaControl && nextItem.isAreaDevice()) continue;
			resultList.add(nextItem);
			
		}
		return resultList;
	}
	
	List <DynaliteDevice>findAllAreas () {
		LinkedList <DynaliteDevice>allAreas = new LinkedList<DynaliteDevice>();
		for (String nextArea:areaCodes.keySet()){
			LinkedList <DynaliteDevice>deviceList = areaCodes.get(nextArea);
			for (DynaliteDevice nextItem: areaCodes.get(nextArea)){
				if (nextItem.isAreaDevice()) {
					allAreas.add (nextItem);
				}
			}
		}
		return allAreas;
	}
	
	List <DynaliteDevice> getAllEquivalentDevices (DynaliteDevice device) {
		
		if (device.isLinked()){
			List<DynaliteDevice>  result = new LinkedList<DynaliteDevice> ();
			
			for (String nextAreaCode:areaCodes.keySet()){
				try {
					if (!nextAreaCode.equals(device.getAreaCode())){
						List <DynaliteDevice>devsInArea = areaCodes.get(nextAreaCode);
						if (devsInArea.contains(device)){
							DynaliteDevice linkedDevice = (DynaliteDevice)configHelper.getControlledItem(dynaliteHelper.buildKey('L',nextAreaCode,device.getKey()));	
							if (linkedDevice != null) {
								result.add (linkedDevice);
							}
							
						}
					}
				} catch (ClassCastException ex){
					logger.log (Level.WARNING,"A non dynalite device was recorded in the area link map");
				}
			}
			return result;
		} else {
			return null;
		}
	}

	public ConfigHelper getConfigHelper() {
		return configHelper;
	}

	public void setConfigHelper(ConfigHelper configHelper) {
		this.configHelper = configHelper;
	}

	public DynaliteHelper getDynaliteHelper() {
		return dynaliteHelper;
	}

	public void setDynaliteHelper(DynaliteHelper dynaliteHelper) {
		this.dynaliteHelper = dynaliteHelper;
	}


}
