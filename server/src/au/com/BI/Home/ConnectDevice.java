package au.com.BI.Home;

import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Comms.ConnectionFail;
import au.com.BI.User.User;
import au.com.BI.Config.Bootstrap;
import au.com.BI.GC100.IRCodeDB;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.SetupException;

public class ConnectDevice extends Thread {
	protected DeviceModel deviceModel;
	protected au.com.BI.Admin.Model adminModel;
	protected CommandQueue commandQueue;
	protected Logger logger;
	protected Bootstrap bootstrap;
	protected IRCodeDB irCodeDB;
	private boolean shownWarning = false;
	
	public ConnectDevice (DeviceModel deviceModel, au.com.BI.Admin.Model adminModel, CommandQueue commandQueue,IRCodeDB irCodeDB, Bootstrap bootstrap) {
		this.deviceModel = deviceModel;
		this.adminModel = adminModel;
		this.commandQueue = commandQueue;
		this.irCodeDB = irCodeDB;
		this.bootstrap = bootstrap;
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setName ("Connecting " + deviceModel.getName());
	}
	
	public void run() {
		
	deviceModel.setTryingToConnect(true);
	
	while (deviceModel.isTryingToConnect()) {
		try {

			deviceModel.prepareToAttatchComms();
			deviceModel.attatchComms();
			if (shownWarning){
				logger.log(Level.WARNING, "Connection restored to " + deviceModel.getName());
			}
			shownWarning = false ; // can be reset now ready for next disconnect
			User newUser = new User ((String)deviceModel.getParameterValue("Username",DeviceModel.MAIN_DEVICE_GROUP),
					(String)deviceModel.getParameterValue("Password",DeviceModel.MAIN_DEVICE_GROUP));
			if (deviceModel.login(newUser) == DeviceModel.SUCCESS ) {
					logger.log(Level.FINE, "Logged in to " + deviceModel.getName());
			}

			if (deviceModel.getName().equals("IR_LEARNER")) {
			    if (this.adminModel!=null) {
				    adminModel.setIrLearner(deviceModel);
			    }
			}
			if (deviceModel.doIControlIR()) {
			    deviceModel.setIrCodeDB(this.irCodeDB);
			}
			deviceModel.setBootstrap(bootstrap);
			deviceModel.setConnected(true);
			deviceModel.doStartup();
			deviceModel.setTryingToConnect(false);
		} catch (ConnectionFail fail) {
			if (!shownWarning) { 
				logger.log(Level.WARNING, "Connection failed to " + deviceModel.getName() +" please check cabling. " + fail.getMessage());
				shownWarning = true;
			}
			try {
				Thread.sleep(30000);
			} catch (InterruptedException ex) {
			} catch (IllegalMonitorStateException ex) {
				logger.log (Level.FINEST, "Wait before device restart was interrupted");
			}
		} catch (CommsFail fail) {
			try {
				Thread.sleep(30000);
			} catch (InterruptedException ex) {
			} catch (IllegalMonitorStateException ex) {
				logger.log (Level.FINEST, "Wait before device restart was interrupted");
			}
		} 
	}
	}
}
