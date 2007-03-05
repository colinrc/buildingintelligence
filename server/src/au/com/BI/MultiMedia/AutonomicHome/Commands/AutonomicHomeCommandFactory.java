package au.com.BI.MultiMedia.AutonomicHome.Commands;

import java.util.logging.Logger;

public class AutonomicHomeCommandFactory {

	private static AutonomicHomeCommandFactory _singleton = null;
	private Logger logger;

	private AutonomicHomeCommandFactory() {
		super();
		logger = Logger.getLogger(AutonomicHomeCommandFactory.class.getPackage().getName());
	}
	
	public static AutonomicHomeCommandFactory getInstance() {
		if (_singleton == null) {
			_singleton = new AutonomicHomeCommandFactory();
		}
		return (_singleton);
	}
}
