package au.com.BI.Dynalite;

import au.com.BI.Util.*;
import au.com.BI.Config.*;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.*;

public class AreaCodes {
	protected HashMap areaCodes = null;
	public final static int AreaCommand = 0;
	Logger logger = null;
	ConfigHelper configHelper = null;
	DynaliteHelper dynaliteHelper = null;
	
	public AreaCodes () {
		areaCodes = new HashMap(10);
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
		LinkedList keys;
		if (areaCodes.containsKey(areaCode)){
			keys = (LinkedList)areaCodes.get(areaCode);
		}else {
			keys = new LinkedList();
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
		LinkedList keys;
		if (!areaCodes.containsKey(areaCode)){
			return;
		}
		keys = (LinkedList)areaCodes.get(areaCode);
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

	List findDevicesInArea (String area, boolean includeAreaControl,int join) {
		LinkedList resultList = new LinkedList();
		LinkedList deviceList = (LinkedList)(areaCodes.get(area));
		Iterator eachLight = deviceList.iterator();
		while (eachLight.hasNext()){
			DynaliteDevice nextItem = (DynaliteDevice)eachLight.next();
			if (!includeAreaControl && nextItem.isAreaDevice()) continue;
			resultList.add(nextItem);
			
		}
		return resultList;
	}
	
	List findAllAreas () {
		LinkedList allAreas = new LinkedList();
		Iterator eachArea = areaCodes.keySet().iterator();
		while (eachArea.hasNext()){
			String nextArea = (String)eachArea.next();
			LinkedList deviceList = (LinkedList)(areaCodes.get(nextArea));
			Iterator eachLight = deviceList.iterator();
			while (eachLight.hasNext()){
				DynaliteDevice nextItem = (DynaliteDevice)eachLight.next();
				if (nextItem.isAreaDevice()) {
					allAreas.add (nextItem);
				}
			}
		}
		return allAreas;
	}
	
	List getAllEquivalentDevices (DynaliteDevice device) {
		
		if (device.isLinked()){
			List result = new LinkedList();
			Iterator eachArea = this.areaCodes.keySet().iterator();
			while (eachArea.hasNext()){
				String nextAreaCode = (String)eachArea.next();
				try {
					if (!nextAreaCode.equals(device.getAreaCode())){
						List devsInArea = (List)areaCodes.get(nextAreaCode);
						if (devsInArea.contains(device)){
							DeviceType linkedDevice = (DeviceType)configHelper.getControlledItem(dynaliteHelper.buildKey('L',nextAreaCode,device.getKey()));	
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
