package au.com.BI.MultiMedia.SlimServer.Commands;

public class PowerReply extends SlimServerCommand {

	private String playerId;
	private boolean power;
	
	public PowerReply() {
		playerId = "";
		power = false;
	}

	public boolean isPower() {
		return power;
	}

	public void setPower(boolean power) {
		this.power = power;
	}

	public String getPlayerId() {
		return playerId;
	}

	public void setPlayerId(String playerId) {
		this.playerId = playerId;
	}
	
	public String getPowerString() {
		if (power) {
			return "ON";
		} else {
			return "OFF";
		}
	}
	
}
