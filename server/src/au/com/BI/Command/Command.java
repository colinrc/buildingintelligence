/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Command;
import java.util.logging.Logger;

import au.com.BI.User.*;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.JRobin.JRobinData;
import org.jdom.*;

/**
 * @author Colin Canfield
 *
 * Encapsulates a command to a physical device
 *
 */
public class Command implements CommandInterface {
        public String key = "";
        protected String commandCode = "";
        protected String displayName = "";
        protected String extraInfo = "";
        protected String extra2Info = "";
        protected String extra3Info = "";
        protected String extra4Info = "";
        protected String extra5Info = "";
        protected int targetDeviceModel = -1;
        protected long targetDeviceID = 0;
        protected long creationDate = 0;
        protected Object rrdValueObject;
        protected JRobinData jRobinData;
		protected boolean adminCommand = false;
        protected Logger logger;
        protected boolean scriptCommand = false;

        public User user;


        public CommandInterface clone() throws CloneNotSupportedException {
        	
        	CommandInterface newCopy;
			try {
				newCopy = this.getClass().newInstance();
        		//Command newCopy = new  Command ();
        		newCopy.setKey(this.getKey());
        		newCopy.setCommand(this.getCommandCode());
        		newCopy.setUser(this.getUser());
        		newCopy.setExtraInfo(this.getExtraInfo());
        		newCopy.setExtra2Info(this.getExtra2Info());
        		newCopy.setExtra3Info(this.getExtra3Info());
        		newCopy.setExtra4Info(this.getExtra4Info());
        		newCopy.setExtra5Info(this.getExtra5Info());
        		newCopy.setScriptCommand(this.isScriptCommand());
        		
        		newCopy.setDisplayName(this.getDisplayName());
        		newCopy.setTargetDeviceID(this.getTargetDeviceID());
        		newCopy.setTargetDeviceModel(this.getTargetDeviceModel());
        		return newCopy;			
        		} 
			catch (InstantiationException e) {
				throw new CloneNotSupportedException ("Cannot create new instance");
			} catch (IllegalAccessException e) {
				throw new CloneNotSupportedException ("Cannot create new instance");
			}

        }
        
        public boolean equals(Object toTest) {
        		if (toTest instanceof au.com.BI.Command.CommandInterface ){
        			CommandInterface toTestCommand = (CommandInterface)toTest;
        			if (!key.equals(toTestCommand.getKey())) return false;
	           	if (!extraInfo.equals(toTestCommand.getExtraInfo())) return false;
	           	if (!extra2Info.equals(toTestCommand.getExtra2Info())) return false;
	           	if (!extra3Info.equals(toTestCommand.getExtra3Info())) return false;
	           	if (!extra4Info.equals(toTestCommand.getExtra4Info())) return false;
	          	if (!extra5Info.equals(toTestCommand.getExtra5Info())) return false;
	          	if (!displayName.equals(toTestCommand.getDisplayName())) return false;
	         	if (!commandCode.equals(toTestCommand.getCommandCode())) return false;
	         	          	           	        		
	         	return true;
        		} else {
        			return super.equals (toTest);
        		}
        }
        
        public void setJRobinData(au.com.BI.JRobin.JRobinData jRobinData) {
                this.jRobinData = jRobinData;
        }

        public JRobinData getJRobinData() {
                return this.jRobinData;
        }

        public Command ()
        {
            creationDate = System.currentTimeMillis();
        }

        public Command (String key,String commandCode,User user)
        {
            creationDate = System.currentTimeMillis();
                setKey (key);
                setCommand (commandCode);
                setUser (user);
        }

        public Command (String key,String commandCode, User user,String extraInfo)
        {
            creationDate = System.currentTimeMillis();
            this.extraInfo = extraInfo;
            setExtraInfo (extraInfo);
            setKey (key);
            setCommand (commandCode);
            setUser (user);
        }

        /**
         * Returns any of the fields from the command object
         * @return The requested field
         */
        public String getValue (Fields commandField) {
        		switch (commandField){
        			case COMMAND:
        				return this.getCommandCode();
        				
           			case KEY:
        				return this.getKey();
 
          			case EXTRA:
        				return this.getExtraInfo();
 
          			case EXTRA2:
        				return this.getExtra2Info();

          			case EXTRA3:
        				return this.getExtra3Info();

          			case EXTRA4:
        				return this.getExtra4Info();

          			case EXTRA5:
        				return this.getExtra5Info();
        				
        			default: 
        				return "Unknown Field Requested";
        		}
        }
        
		public boolean isCommsCommand () {
			return false;
		}

		/**
         * By default client is false.
         * Override if the command is generated by the AWT client.
         */
        public boolean isClient() {
                return false;
        }

        /**
         * Used to populate a command from an XML element.
         * @param element
         */
        public void setFromElement (Element element){
                this.setKey(element.getAttributeValue("KEY"));
                this.setCommand(element.getAttributeValue("COMMAND"));
                this.setExtraInfo(element.getAttributeValue("EXTRA"));
                this.setExtra2Info(element.getAttributeValue("EXTRA2"));
                this.setExtra3Info(element.getAttributeValue("EXTRA3"));
                this.setExtra4Info(element.getAttributeValue("EXTRA4"));
                this.setExtra5Info(element.getAttributeValue("EXTRA5"));
        }

        /**
         * By default client is false.
         * Override if the command is generated by the flash client.
         */
        public boolean isUserControllerCommand() {
                return false;
        }

        public final void setKey (String key) {
                if (key == null)
                        this.key = "";
                else
                        this.key = key;
        }

        public final String getKey (){
                return key;
        }

        public String getCommandCode () {
                return commandCode;
        }

        public final String getExtraInfo () {
                if (extraInfo == null)
                        return "";
                else
                        return extraInfo;

        }

        public final void setExtraInfo (String extraInfo) {
                this.extraInfo = extraInfo;
        }

        public final User getUser () {
                return user;
        }

        public final void setUser (User user){
                this.user = user;
        }

        public void setCommand (String command){
                if (command == null)
                        this.commandCode = "";
                else
                        this.commandCode = command;
        }


        public Element getXMLCommand () {
                Element element = new Element ("CONTROL");

                element.setAttribute ("KEY", key);
                element.setAttribute ("COMMAND", commandCode);

                if (extraInfo != null) {
                        element.setAttribute ("EXTRA", extraInfo.toString());
                }
                else {
                        element.setAttribute ("EXTRA", "");
                }

                if (extra2Info != null) {
                        element.setAttribute ("EXTRA2", extra2Info.toString());
                }
                else {
                        element.setAttribute ("EXTRA2", "");
                }
                if (extra3Info != null) {
                        element.setAttribute ("EXTRA3", extra3Info.toString());
                }
                else {
                        element.setAttribute ("EXTRA3", "");
                }
                if (extra4Info != null) {
                        element.setAttribute ("EXTRA4", extra4Info.toString());
                }
                else {
                        element.setAttribute ("EXTRA4", "");
                }
                if (extra5Info != null) {
                        element.setAttribute ("EXTRA5", extra5Info.toString());
                }
                else {
                        element.setAttribute ("EXTRA5", "");
                }

                return element;
        }


        /**
         * @return Returns the displayName.
         */
        public String getDisplayName() {
                return displayName;
        }
        /**
         * @param displayName The displayName to set.
         */
        public void setDisplayName(String displayName) {
                this.displayName = displayName;
        }


        /**
         * @param rrdValueObject The value to be added to the rrd.
         */
        public final void setRrdValueObject(Object rrdValueObject) {
                this.rrdValueObject = rrdValueObject;
        }

        /**
         * @return Returns the rrdValueObject.
         */
        public final Object getRrdValueObject() {
          return rrdValueObject;
        }

        /**
         * @return Returns the targetDeviceModel.
         */
        public int getTargetDeviceModel() {
                return targetDeviceModel;
        }
        /**
         * @param targetDeviceModel The targetDeviceModel to set.
         */
        public void setTargetDeviceModel(int targetDeviceModel) {
                this.targetDeviceModel = targetDeviceModel;
        }

        public long getTargetDeviceID () {
                return targetDeviceID;
        }

        public void setTargetDeviceID (long ID) {
                this.targetDeviceID = ID;
        }

        public boolean cacheAllCommands () {
                return false;
        }

        public long getCreationDate() {
            return this.creationDate;
        }
        /**
         * @return Returns the extra2Info.
         */
        public String getExtra2Info() {
                if (extra2Info == null)
                        return "";
                else
                        return extra2Info;
        }
        /**
         * @param extra2Info The extra2Info to set.
         */
        public void setExtra2Info(String extra2Info) {
                this.extra2Info = extra2Info;
        }
        /**
         * @return Returns the extra3Info.
         */
        public String getExtra3Info() {
                if (extra3Info == null)
                        return "";
                else
                        return extra3Info;
        }
        /**
         * @param extra3Info The extra3Info to set.
         */
        public void setExtra3Info(String extra3Info) {
                this.extra3Info = extra3Info;
        }
        /**
         * @return Returns the extra4Info.
         */
        public String getExtra4Info() {
                if (extra4Info == null)
                        return "";
                else
                        return extra4Info;
        }
        /**
         * @param extra4Info The extra4Info to set.
         */
        public void setExtra4Info(String extra4Info) {
                this.extra4Info = extra4Info;
        }
        /**
         * @return Returns the extra5Info.
         */
        public String getExtra5Info() {
                if (extra5Info == null)
                        return "";
                else
                        return extra5Info;
        }
        /**
         * @param extra5Info The extra5Info to set.
         */
        public void setExtra5Info(String extra5Info) {
                this.extra5Info = extra5Info;
        }

		public boolean isAdminCommand() {
			return adminCommand;
		}
		

		public void setAdminCommand(boolean adminCommand) {
			this.adminCommand = adminCommand;
		}

		public boolean isScriptCommand() {
			return scriptCommand;
		}

		public void setScriptCommand(boolean scriptCommand) {
			this.scriptCommand = scriptCommand;
		}
		
}
