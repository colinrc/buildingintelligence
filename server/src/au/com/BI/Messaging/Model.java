
package au.com.BI.Messaging;

import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;
import au.com.BI.Config.*;

import java.util.*;
import java.util.logging.*;

import au.com.BI.ToggleSwitch.*;
import au.com.BI.Flash.*;

import au.com.BI.Script.ScriptHandler;
import au.com.BI.User.User;
import org.jdom.Element;
import au.com.BI.JRobin.RRDValueObject;
import au.com.BI.Home.Controller;
import java.io.IOException;
import org.jrobin.core.RrdException;
import org.jrobin.core.*;
import java.io.*;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 * This module provides an interface to the messaging system.

 */
public class Model
  extends BaseModel implements DeviceModel {
	protected Logger logger;
	protected AddressBook addressBook =  null;


        public Model() {
            super();
            this.setName("MESSAGING");
        		logger = Logger.getLogger(this.getClass().getPackage().getName());
        }

        public boolean removeModelOnConfigReload() {
                return false;
        }


        public void doStartup(java.util.List commandQueue) {

        }


        /**
         * Main test point for the controller to request from this model if it controls a particular Command
         * <P>
         * For items sent by flash this would be determed by the DISPLAY_NAME field in the command.
         * <BR>
         * For items from a comms port the actual received string will be interpretted.
         * <P>
         * CustomInput types will trigger particular Command structures to be built based on the string, which
         * could be tested for instead of the raw string.
         * <P>
         * Currently there is no mechanism for control from a particular model to stop other models also receiving
         * the command. For scripts that wish to block and interpret commands themself, changes will be needed to
         * the main DeviceModel list processing in the au.com.BI.Controller class
         */
        public boolean doIControl(String keyName, boolean isCommand) {
                configHelper.wholeKeyChecked(keyName);

                if (keyName.equals("MESSAGE"))
                		return true;
                else
                		return false;

          }
        /* Test messages
         * 
         * 
         <MESSAGE TARGET="Lounge" TITLE="Test" HIDECLODE="TRUE" AUTOCLOSE="5" ICON="" CONTENT="Hello" />
		<MESSAGE TARGET="All" TITLE="Test" HIDECLODE="TRUE" AUTOCLOSE="5" ICON="" CONTENT="Hello" />
         */

        /**
         * After doIControl returns true doCommand will be called with the command in question.
         */
        public void doCommand(CommandInterface command) throws CommsFail {
 
                String theWholeKey = command.getKey();

				if (command.isClient()) {
					theWholeKey = command.getKey();
				} else {
					theWholeKey = command.getDisplayName();
				}

                if (theWholeKey.equals("MESSAGE")) {
                		if (command instanceof ClientCommand) {
                        doMessage((ClientCommand)command);
                		} else {
                			
                			logger.log( Level.WARNING,"A message was received but the command is not the correct type");
                		}
                }
        }

 
        public void doMessage (ClientCommand command){
        		MessageCommand theMessage = buildTheMessage (command);
        		if (theMessage != null){
					this.sendToFlash(theMessage);
        		}
        }
        
        public MessageCommand buildTheMessage (ClientCommand command){
        		MessageCommand message = null;
        		if (command.getMessageType() == ClientCommand.Message){
	        		
        			String target = command.getTarget();
        			String targetUser = command.getTargetUser();
        			long targetID = AddressBook.ALL_INT;
        			
        			
        			if (!targetUser.equals ("")) {
        				//@TODO Add target user code
        			} else {
        				targetID = addressBook.getIDFromName(target);
        			}


				boolean messageFound = false;
				
	       		if (!messageFound && targetID == AddressBook.NOT_FOUND) {
	       			messageFound = true;
      				message = new MessageCommand();
    					message.setTitle( "Not Found");
    					message.setIcon( "warning");
    					message.setAutoclose("15");
    					message.setHideclose( "TRUE");
    					message.setContent( "The message recipient is not currently connected to the system");
    					message.setOriginatingID(0);
    					message.setTargetDeviceID(command.getOriginatingID());
    					message.setKey("CLIENT_SEND");
    					logger.log (Level.INFO,"Received a message, but the recipient is not currently connected ");
        			}
	       		
	    			if (!messageFound && targetID != AddressBook.NOT_FOUND) {
	       			messageFound = true;
	    				message = new MessageCommand();
					message.setTitle( command.getTitle());
					message.setIcon( command.getIcon());
					message.setAutoclose( command.getAutoclose());
					message.setHideclose( command.getHideclose());
					message.setContent( command.getContent());
					message.setTargetDeviceID(targetID);
					message.setKey("CLIENT_SEND");
					if (targetID == AddressBook.ALL_INT){
		    					message.setOriginatingID(command.getOriginatingID());
					}
					if (targetID == AddressBook.ALL_INC_SRC_INT){
							message.setOriginatingID(0);
	        			}
       				logger.log (Level.INFO,"Received a message, sending it to " + target);
				}
	        		return message;

        		} else {
        			logger.log( Level.WARNING,"A message was received, however it is not the correct type");
        			return null;
        		}

        }
        
        public void sendToFlash(CommandInterface command) {

                cache.setCachedCommand(command.getDisplayName(), command);
                synchronized (commandQueue) {
                        commandQueue.add(command);
                }
        }
 
        public void attatchComms(List commandQueue) throws au.com.BI.Comms.
          ConnectionFail {};

 
        /**
         * @return Returns the name.
         */
        public String getName() {
                return name;
        }

        /**
         * @param name The name to set.
         */
        public void setName(String name) {
                this.name = name;
        }


        public boolean isConnected() {
                return true;
        }

		public AddressBook getAddressBook() {
			return addressBook;
		}

		public void setAddressBook(AddressBook addressBook) {
			this.addressBook = addressBook;
		}
}
