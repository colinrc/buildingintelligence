package au.com.BI.MultiMedia.AutonomicHome.Device;

import au.com.BI.Device.DeviceType;
import au.com.BI.Util.BaseDevice;

/**
 * Represents a Windows Media Extender such as an XBOX.
 * @author dcummins
 *
 */
public class WindowsMediaExtender extends BaseDevice implements DeviceType {
	private boolean running;
	private boolean shuffle;
	private boolean repeat;
	private int totalTracks;
	private int trackTime;
	private int volume;
	private String sessionStart;
	
	public WindowsMediaExtender() {
		super();
	}
	
	public WindowsMediaExtender(String name, int deviceType, String outputKey) {
		super(name, deviceType, outputKey);
	}
	
	public WindowsMediaExtender(String name, int deviceType) {
		super(name, deviceType);
	}
	
	public boolean isRepeat() {
		return repeat;
	}
	
	public void setRepeat(boolean repeat) {
		this.repeat = repeat;
	}
	
	public boolean isRunning() {
		return running;
	}
	
	public void setRunning(boolean running) {
		this.running = running;
	}
	
	public boolean isShuffle() {
		return shuffle;
	}
	
	public void setShuffle(boolean shuffle) {
		this.shuffle = shuffle;
	}
	
	public int getTotalTracks() {
		return totalTracks;
	}
	
	public void setTotalTracks(int totalTracks) {
		this.totalTracks = totalTracks;
	}
	
	public int getTrackTime() {
		return trackTime;
	}
	
	public void setTrackTime(int trackTime) {
		this.trackTime = trackTime;
	}
	
	public int getVolume() {
		return volume;
	}

	public void setVolume(int volume) {
		this.volume = volume;
	}

	public boolean keepStateForStartup() {
		return false;
	}

	public String getSessionStart() {
		return sessionStart;
	}

	public void setSessionStart(String sessionStart) {
		this.sessionStart = sessionStart;
	}
	
	
}
