package au.com.BI.MultiMedia.AutonomicHome;

import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommDevice;
import au.com.BI.Comms.CommsCommand;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Device.DeviceType;
import au.com.BI.MultiMedia.AutonomicHome.Commands.BrowseAlbums;
import au.com.BI.MultiMedia.AutonomicHome.Commands.SetInstance;
import au.com.BI.MultiMedia.AutonomicHome.Device.WindowsMediaExtender;

/**
 * Helper class with outputs from the Autonomic Home to the MCE.
 * @author David Cummins
 *
 */
public class OutputHelper {

	protected Logger logger;
	private CommandInterface currentCommand;

	public OutputHelper() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public void doOutputItem(CommandInterface command,
			ConfigHelper configHelper, 
			Cache cache, 
			CommDevice comms,
			au.com.BI.MultiMedia.AutonomicHome.Model model) throws CommsFail {
		
		String key = command.getKey();
		String retCode = "";
		
		DeviceType device = configHelper.getControlledItem(key);
		
		if (device != null) {
			if (device.getDeviceType() == DeviceType.WINDOWS_MEDIA_EXTENDER) {
				WindowsMediaExtender extender = (WindowsMediaExtender)device;
				
				if (model.getCurrentInstance() == null || !model.getCurrentInstance().getName().equals(extender.getName())) {
					// set the instance
					SetInstance setInstance = new SetInstance();
					setInstance.setInstance(extender.getKey());
					logger.log(Level.FINER, "Sending command to Autonomic Home: " + setInstance.buildCommandString());
					CommsCommand _commsCommand = new CommsCommand(key,setInstance.buildCommandString() + "\r\n",null);
					comms.addCommandToQueue(_commsCommand);
					
					if (!comms.sendNextCommand()) {
						throw new CommsFail("Failed to send command:" + setInstance.buildCommandString());
					}
				}
				
				if (command.getCommandCode().equalsIgnoreCase("BROWSE")) {
					// <CONTROL KEY="<extender>" COMMAND="BROWSE" EXTRA="<type>" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
					// type can be
					// ALBUMS
					// ARTISTS
					// GENRES
					// NOWPLAYING
					// PLAYLISTS
					// FIXME the following is wrong, need to make the ret string command specific 
					if (command.getExtraInfo().equalsIgnoreCase("ALBUMS")) {
						BrowseAlbums browseAlbums = new BrowseAlbums();
						retCode = browseAlbums.buildCommandString() + "\r\n";
					} else if (command.getExtraInfo().equalsIgnoreCase("ARTISTS")) {
						BrowseAlbums browseAlbums = new BrowseAlbums();
						retCode = browseAlbums.buildCommandString() + "\r\n";						
					} else if (command.getExtraInfo().equalsIgnoreCase("GENRES")) {
						BrowseAlbums browseAlbums = new BrowseAlbums();
						retCode = browseAlbums.buildCommandString() + "\r\n";
					} else if (command.getExtraInfo().equalsIgnoreCase("NOWPLAYING")) {
						BrowseAlbums browseAlbums = new BrowseAlbums();
						retCode = browseAlbums.buildCommandString() + "\r\n";
					} else if (command.getExtraInfo().equalsIgnoreCase("PLAYLISTS")) {
						BrowseAlbums browseAlbums = new BrowseAlbums();
						retCode = browseAlbums.buildCommandString() + "\r\n";
					}
					else {
					// what are we browsing?
						retCode = "";
					}
					// 
				} else if (command.getCommandCode().equalsIgnoreCase("PLAY")) {
					// FIXME the following is wrong, need to make the ret string command specific 
					retCode = "Play\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase("TRANSPORT")) {
					// transport commands
					// play, pause, stop, fast forward, rewind
					// FIXME the following is wrong, need to make the ret string command specific 
					retCode = "Play|Pause|Stop|FF|Rew\r\n";
				} else {
					retCode ="";
				}
			}
		}
		
		if (!retCode.equals("")) { 
			logger.log(Level.FINER, "Sending command to Autonomic Home: " + retCode);
			CommsCommand _commsCommand = new CommsCommand(key,retCode,null);
			comms.addCommandToQueue(_commsCommand);
			
			if (!comms.sendNextCommand()) {
				throw new CommsFail("Failed to send command:" + retCode);
			}
		}
	}

	public CommandInterface getCurrentCommand() {
		return currentCommand;
	}

	public void setCurrentCommand(CommandInterface currentCommand) {
		this.currentCommand = currentCommand;
	}
	
	
}
