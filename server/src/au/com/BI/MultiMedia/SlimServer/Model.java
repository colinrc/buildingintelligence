package au.com.BI.MultiMedia.SlimServer;

import java.util.Collection;
import java.util.logging.Level;

import au.com.BI.Audio.Audio;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Device.DeviceType;
import au.com.BI.MultiMedia.MultiMediaInterface;
import au.com.BI.MultiMedia.SlimServer.Commands.Login;
import au.com.BI.MultiMedia.SlimServer.Commands.PlayerStatus;
import au.com.BI.MultiMedia.SlimServer.Commands.SlimServerCommandException;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.SimplifiedModel;
import au.com.BI.Util.StringUtils;

public class Model extends SimplifiedModel implements DeviceModel, MultiMediaInterface {
	
	private ControlledHelper controlledHelper;
	private OutputHelper outputHelper;
	private Audio currentPlayer;
	private String urlPath;
	
	/**
	 * Constructor for the model.
	 * Will add the following:
	 * <ul>
	 * 	<li>Windows Media Center device</li>
	 * </ul>
	 */
	public Model() {
		super();
		controlledHelper = new ControlledHelper();
		outputHelper = new OutputHelper();
	}
	
	/**
	 * Starts AutonomicHome model.
	 * <ul>
	 * 	<li>Start the MCE Media Center</li>
	 * </ul>
	 */
	public void doStartup() throws CommsFail {
		logger.log(Level.INFO,"Starting Slim Server");
		Login login = new Login();
		
		String user = (String)this.getParameterValue("USER", DeviceModel.MAIN_DEVICE_GROUP);
		if (!StringUtils.isNullOrEmpty(user)) {
			login.setUser(user);
			login.setPassword(this.getParameterValue("Password", DeviceModel.MAIN_DEVICE_GROUP));
		}
		
		int defaultSearchResults = 5;
		try {
			defaultSearchResults = Integer.parseInt((String)this.getParameterValue("DEFAULT_SEARCH_RESULTS", DeviceModel.MAIN_DEVICE_GROUP));
		} catch (NumberFormatException e) {
			logger.log(Level.WARNING, "Cannot parse the DEFAULT_SEARCH_RESULTS - using default value of " + defaultSearchResults);
		}
		outputHelper.setDefaultSearchResults(defaultSearchResults);
		
		comms.sendString(login.buildCommandString() + "\r\n");
		logger.log(Level.INFO,"Sent command " + login.buildCommandString());
		
		Collection<DeviceType> devices = this.getConfigHelper().getAllOutputDeviceObjects();
		for (DeviceType device: devices) {
			PlayerStatus status = new PlayerStatus();
			status.setPlayerId(device.getKey());
			comms.sendString(status.buildCommandString() + "\r\n");
			logger.log(Level.INFO,"Sent command " + status.buildCommandString());
		}
		
		urlPath = (String)this.getParameterValue("COVER_ART_URL", DeviceModel.MAIN_DEVICE_GROUP);
		
		// get current state of players
	}
	
	/**
	 * Handle output items.
	 */
	public void doOutputItem (CommandInterface command) throws CommsFail {
		logger.log(Level.INFO,"Output " + command.getKey());
		outputHelper.doOutputItem(command, configHelper, cache, comms, this);
	}
	
	/**
	 * Handle controlled items.
	 */
	public void doControlledItem (CommandInterface command) throws CommsFail
	{	
		logger.log(Level.INFO,"Controlled " + command.getKey());
		try {
			controlledHelper.doControlledItem(command, configHelper, cache, commandQueue, this);
		} catch (SlimServerCommandException e) {
			logger.log(Level.INFO, "Autonomic home command exception encountered " + e.getMessage());
		}
	}

	@Override
	public String formatKey(int key, DeviceType device) throws NumberFormatException {
		return Integer.toString(key);
	}

	@Override
	public String formatKey(String key, DeviceType device) throws NumberFormatException {
		return key;
	}

	public Audio getCurrentPlayer() {
		return currentPlayer;
	}

	public void setCurrentPlayer(Audio currentPlayer) {
		this.currentPlayer = currentPlayer;
	}
	
	public String getURLPath() {
		return this.urlPath;
	}
}
