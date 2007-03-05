package au.com.BI.MultiMedia.AutonomicHome.Commands;

public class GetStatus extends AutonomicHomeCommand {

	@Override
	public String buildCommandString() {
		return "GetMCEStatus";
	}
}
