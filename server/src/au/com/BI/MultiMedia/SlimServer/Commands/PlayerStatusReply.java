package au.com.BI.MultiMedia.SlimServer.Commands;

import java.util.LinkedList;

import org.jdom.Element;

import au.com.BI.MultiMedia.Track;
import au.com.BI.Util.StringUtils;

public class PlayerStatusReply extends SlimServerCommand {
	private String playerId;
	private String playerKey;
	private boolean rescan;
	private String playerName;
	private String playerConnected;
	private String power;
	private String signalStrength;
	private String mode;
	private String rate;
	private String remote;
	private String currentTitle;
	private String time;
	private String duration;
	private String sleep;
	private String willSleepIn;
	private String syncMaster;
	private String syncSlaves;
	private String subscribe;
	private String mixerVolume;
	private String mixerTreble;
	private String mixerBass;
	private String mixerPitch;
	private String playlistRepeat;
	private String playlistShuffle;
	private String playlistId;
	private String playlistName;
	private String playlistModified;
	private String playlistCurrentIndex;
	private String playlistTracks;
	private LinkedList<Track> tracks;
	
	public PlayerStatusReply() {
		tracks = new LinkedList<Track>();
	}

	public String getRate() {
		return rate;
	}

	public void setRate(String rate) {
		this.rate = rate;
	}


	public String getSubscribe() {
		return subscribe;
	}

	public void setSubscribe(String subscribe) {
		this.subscribe = subscribe;
	}
	
	public String getPlayerKey() {
		return playerKey;
	}

	public void setPlayerKey(String playerKey) {
		this.playerKey = playerKey;
	}

	public String getCurrentTitle() {
		return currentTitle;
	}

	public void setCurrentTitle(String currentTitle) {
		this.currentTitle = currentTitle;
	}

	public String getDuration() {
		return duration;
	}

	public void setDuration(String duration) {
		this.duration = duration;
	}

	public String getMixerBass() {
		return mixerBass;
	}

	public void setMixerBass(String mixerBass) {
		this.mixerBass = mixerBass;
	}

	public String getMixerPitch() {
		return mixerPitch;
	}

	public void setMixerPitch(String mixerPitch) {
		this.mixerPitch = mixerPitch;
	}

	public String getMixerTreble() {
		return mixerTreble;
	}

	public void setMixerTreble(String mixerTreble) {
		this.mixerTreble = mixerTreble;
	}

	public String getMixerVolume() {
		return mixerVolume;
	}

	public void setMixerVolume(String mixerVolume) {
		this.mixerVolume = mixerVolume;
	}

	public String getMode() {
		return mode;
	}

	public void setMode(String mode) {
		this.mode = mode;
	}

	public String getPlayerConnected() {
		return playerConnected;
	}

	public void setPlayerConnected(String playerConnected) {
		this.playerConnected = playerConnected;
	}

	public String getPlayerId() {
		return playerId;
	}

	public void setPlayerId(String playerId) {
		this.playerId = playerId;
	}

	public String getPlayerName() {
		return playerName;
	}

	public void setPlayerName(String playerName) {
		this.playerName = playerName;
	}

	public String getPlaylistCurrentIndex() {
		return playlistCurrentIndex;
	}

	public void setPlaylistCurrentIndex(String playlistCurrentIndex) {
		this.playlistCurrentIndex = playlistCurrentIndex;
	}

	public String getPlaylistId() {
		return playlistId;
	}

	public void setPlaylistId(String playlistId) {
		this.playlistId = playlistId;
	}

	public String getPlaylistModified() {
		return playlistModified;
	}

	public void setPlaylistModified(String playlistModified) {
		this.playlistModified = playlistModified;
	}

	public String getPlaylistName() {
		return playlistName;
	}

	public void setPlaylistName(String playlistName) {
		this.playlistName = playlistName;
	}

	public String getPlaylistRepeat() {
		return playlistRepeat;
	}

	public void setPlaylistRepeat(String playlistRepeat) {
		this.playlistRepeat = playlistRepeat;
	}

	public String getPlaylistShuffle() {
		return playlistShuffle;
	}

	public void setPlaylistShuffle(String playlistShuffle) {
		this.playlistShuffle = playlistShuffle;
	}

	public String getPlaylistTracks() {
		return playlistTracks;
	}

	public void setPlaylistTracks(String playlistTracks) {
		this.playlistTracks = playlistTracks;
	}

	public String getPower() {
		return power;
	}

	public void setPower(String power) {
		this.power = power;
	}

	public String getRemote() {
		return remote;
	}

	public void setRemote(String remote) {
		this.remote = remote;
	}

	public boolean isRescan() {
		return rescan;
	}

	public void setRescan(boolean rescan) {
		this.rescan = rescan;
	}

	public String getSignalStrength() {
		return signalStrength;
	}

	public void setSignalStrength(String signalStrength) {
		this.signalStrength = signalStrength;
	}

	public String getSleep() {
		return sleep;
	}

	public void setSleep(String sleep) {
		this.sleep = sleep;
	}

	public String getSyncMaster() {
		return syncMaster;
	}

	public void setSyncMaster(String syncMaster) {
		this.syncMaster = syncMaster;
	}

	public String getSyncSlaves() {
		return syncSlaves;
	}

	public void setSyncSlaves(String syncSlaves) {
		this.syncSlaves = syncSlaves;
	}

	public String getTime() {
		return time;
	}

	public void setTime(String time) {
		this.time = time;
	}

	public LinkedList<Track> getTracks() {
		return tracks;
	}

	public void setTracks(LinkedList<Track> tracks) {
		this.tracks = tracks;
	}

	public String getWillSleepIn() {
		return willSleepIn;
	}

	public void setWillSleepIn(String willSleepIn) {
		this.willSleepIn = willSleepIn;
	}
	
	public Element getElement() {
		Element statusElement = new Element("playerstatus");
		
		/*if (!StringUtils.isNullOrEmpty(getPlayerKey())) {
			statusElement.setAttribute("key",this.getPlayerKey());
		}*/
		
		statusElement.setAttribute("id",getPlayerId());
		
		if (!StringUtils.isNullOrEmpty(getPlayerName())) {
			statusElement.setAttribute("player_name",getPlayerName());
		}
		if (!StringUtils.isNullOrEmpty(getPlayerConnected())) {
			statusElement.setAttribute("connected",getPlayerConnected());
		}
		if (!StringUtils.isNullOrEmpty(getPower())) {
			statusElement.setAttribute("power",getPower());
		}
		if (!StringUtils.isNullOrEmpty(getSignalStrength())) {
			statusElement.setAttribute("signal_strength",getSignalStrength());
		}
		if (!StringUtils.isNullOrEmpty(getMode())) {
			statusElement.setAttribute("mode",getMode());
		}
		if (!StringUtils.isNullOrEmpty(getRate())) {
			statusElement.setAttribute("rate",getRate());
		}
		if (!StringUtils.isNullOrEmpty(getRemote())) {
			statusElement.setAttribute("remote",getRemote());
		}
		if (!StringUtils.isNullOrEmpty(getCurrentTitle())) {
			statusElement.setAttribute("current_title",getCurrentTitle());
		}
		if (!StringUtils.isNullOrEmpty(getTime())) {
			statusElement.setAttribute("time",getTime());
		}
		if (!StringUtils.isNullOrEmpty(getDuration())) {
			statusElement.setAttribute("duration",getDuration());
		}
		if (!StringUtils.isNullOrEmpty(getSleep())) {
			statusElement.setAttribute("sleep",getSleep());
		}
		if (!StringUtils.isNullOrEmpty(getWillSleepIn())) {
			statusElement.setAttribute("will_sleep_in",getWillSleepIn());
		}
		if (!StringUtils.isNullOrEmpty(getSyncMaster())) {
			statusElement.setAttribute("sync_master",getSyncMaster());
		}
		if (!StringUtils.isNullOrEmpty(getSyncSlaves())) {
			statusElement.setAttribute("sync_slaves",getSyncSlaves());
		}
		if (!StringUtils.isNullOrEmpty(getSubscribe())) {
			statusElement.setAttribute("subscribe",getSubscribe());
		}
		if (!StringUtils.isNullOrEmpty(getMixerVolume())) {
			statusElement.setAttribute("mixer_volume",getMixerVolume());
		}
		if (!StringUtils.isNullOrEmpty(getMixerTreble())) {
			statusElement.setAttribute("mixer_treble",getMixerTreble());
		}
		if (!StringUtils.isNullOrEmpty(getMixerBass())) {
			statusElement.setAttribute("mixer_bass",getMixerBass());
		}
		if (!StringUtils.isNullOrEmpty(getMixerPitch())) {
			statusElement.setAttribute("mixer_pitch",getMixerPitch());
		}
		if (!StringUtils.isNullOrEmpty(getPlaylistRepeat())) {
			statusElement.setAttribute("playlist_repeat",getPlaylistRepeat());
		}
		if (!StringUtils.isNullOrEmpty(getPlaylistShuffle())) {
			statusElement.setAttribute("playlist_shuffle",getPlaylistShuffle());
		}
		if (!StringUtils.isNullOrEmpty(getPlaylistId())) {
			statusElement.setAttribute("playlist_id",getPlaylistId());
		}
		if (!StringUtils.isNullOrEmpty(getPlaylistName())) {
			statusElement.setAttribute("playlist_name",getPlaylistName());
		}
		if (!StringUtils.isNullOrEmpty(getPlaylistModified())) {
			statusElement.setAttribute("playlist_modified",getPlaylistModified());
		}
		if (!StringUtils.isNullOrEmpty(getPlaylistCurrentIndex())) {
			statusElement.setAttribute("playlist_current_index",getPlaylistCurrentIndex());
		}
		if (!StringUtils.isNullOrEmpty(getPlaylistTracks())) {
			statusElement.setAttribute("playlist_tracks",getPlaylistTracks());
		}
		
		Element tracksElement = new Element("tracks");

		LinkedList trackElements = new LinkedList();
		
		for (Track track: this.getTracks()) {
			trackElements.add(track.getElement());
		}
		
		tracksElement.addContent(trackElements);
		statusElement.addContent(tracksElement);
		
		return statusElement;
	}
	
}
