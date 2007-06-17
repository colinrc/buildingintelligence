package au.com.BI.MultiMedia;

import org.jdom.Element;

import au.com.BI.Util.StringUtils;

public class Track {
	private String playlistIndex;
	private String id;
	private String genre;
	private String genreId;
	private String artist;
	private String artistId;
	private String composer;
	private String band;
	private String conductor;
	private String album;
	private String albumId;
	private String duration;
	private String discNumber;
	private String discCount;
	private String trackNumber;
	private String year;
	private String bpm;
	private String comment;
	private String type;
	private String tagVersion;
	private String bitRate;
	private String fileSize;
	private String drm;
	private String coverArt;
	private String modificationTime;
	private String url;
	private String lyrics;
	private String remote;
	private String title;
	
	public Track() {
		
	}
	
	public String getPlaylistIndex() {
		return playlistIndex;
	}
	
	public void setPlaylistIndex(String playlistIndex) {
		this.playlistIndex = playlistIndex;
	}
	
	public String getId() {
		return id;
	}
	
	public void setId(String id) {
		this.id = id;
	}

	public String getAlbum() {
		return album;
	}

	public void setAlbum(String album) {
		this.album = album;
	}

	public String getAlbumId() {
		return albumId;
	}

	public void setAlbumId(String albumId) {
		this.albumId = albumId;
	}

	public String getArtist() {
		return artist;
	}

	public void setArtist(String artist) {
		this.artist = artist;
	}

	public String getArtistId() {
		return artistId;
	}

	public void setArtistId(String artistId) {
		this.artistId = artistId;
	}

	public String getBand() {
		return band;
	}

	public void setBand(String band) {
		this.band = band;
	}

	public String getBitRate() {
		return bitRate;
	}

	public void setBitRate(String bitRate) {
		this.bitRate = bitRate;
	}

	public String getBpm() {
		return bpm;
	}

	public void setBpm(String bpm) {
		this.bpm = bpm;
	}

	public String getComment() {
		return comment;
	}

	public void setComment(String comment) {
		this.comment = comment;
	}

	public String getComposer() {
		return composer;
	}

	public void setComposer(String composer) {
		this.composer = composer;
	}

	public String getConductor() {
		return conductor;
	}

	public void setConductor(String conductor) {
		this.conductor = conductor;
	}

	public String getCoverArt() {
		return coverArt;
	}

	public void setCoverArt(String coverArt) {
		this.coverArt = coverArt;
	}

	public String getDiscCount() {
		return discCount;
	}

	public void setDiscCount(String discCount) {
		this.discCount = discCount;
	}

	public String getDiscNumber() {
		return discNumber;
	}

	public void setDiscNumber(String discNumber) {
		this.discNumber = discNumber;
	}

	public String getDrm() {
		return drm;
	}

	public void setDrm(String drm) {
		this.drm = drm;
	}

	public String getDuration() {
		return duration;
	}

	public void setDuration(String duration) {
		this.duration = duration;
	}

	public String getFileSize() {
		return fileSize;
	}

	public void setFileSize(String fileSize) {
		this.fileSize = fileSize;
	}

	public String getGenre() {
		return genre;
	}

	public void setGenre(String genre) {
		this.genre = genre;
	}

	public String getGenreId() {
		return genreId;
	}

	public void setGenreId(String genreId) {
		this.genreId = genreId;
	}

	public String getLyrics() {
		return lyrics;
	}

	public void setLyrics(String lyrics) {
		this.lyrics = lyrics;
	}

	public String getModificationTime() {
		return modificationTime;
	}

	public void setModificationTime(String modificationTime) {
		this.modificationTime = modificationTime;
	}

	public String getRemote() {
		return remote;
	}

	public void setRemote(String remote) {
		this.remote = remote;
	}

	public String getTagVersion() {
		return tagVersion;
	}

	public void setTagVersion(String tagVersion) {
		this.tagVersion = tagVersion;
	}

	public String getTrackNumber() {
		return trackNumber;
	}

	public void setTrackNumber(String trackNumber) {
		this.trackNumber = trackNumber;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getYear() {
		return year;
	}

	public void setYear(String year) {
		this.year = year;
	}
	
	public void setTitle(String title) {
		this.title = title;
	}
	
	public String getTitle() {
		return title;
	}
	
	public Element getElement() {
		Element track = new Element("item");
		
		if (!StringUtils.isNullOrEmpty(getGenre())) {
			track.setAttribute("genre",getGenre());
		}
		if (!StringUtils.isNullOrEmpty(getGenreId())) {
			track.setAttribute("genre_id",getGenreId());
		}
		if (!StringUtils.isNullOrEmpty(getArtist())) {
			track.setAttribute("artist",getArtist());
		}
		if (!StringUtils.isNullOrEmpty(getArtistId())) {
			track.setAttribute("artist_id",getArtistId());
		}
		if (!StringUtils.isNullOrEmpty(getComposer())) {
			track.setAttribute("composer",getComposer());
		}
		if (!StringUtils.isNullOrEmpty(getBand())) {
			track.setAttribute("band",getBand());
		}
		if (!StringUtils.isNullOrEmpty(getConductor())) {
			track.setAttribute("conductor",getConductor());
		}
		if (!StringUtils.isNullOrEmpty(getAlbum())) {
			track.setAttribute("album",getAlbum());
		}
		if (!StringUtils.isNullOrEmpty(getAlbumId())) {
			track.setAttribute("album_id",getAlbumId());
		}
		if (!StringUtils.isNullOrEmpty(getDuration())) {
			track.setAttribute("duration",getDuration());
		}
		if (!StringUtils.isNullOrEmpty(getDiscNumber())) {
			track.setAttribute("disc_number",getDiscNumber());
		}
		if (!StringUtils.isNullOrEmpty(getDiscCount())) {
			track.setAttribute("disccount",getDiscCount());
		}
		if (!StringUtils.isNullOrEmpty(getTrackNumber())) {
			track.setAttribute("tracknum",getTrackNumber());
		}
		if (!StringUtils.isNullOrEmpty(getYear())) {
			track.setAttribute("year",getYear());
		}
		if (!StringUtils.isNullOrEmpty(getBpm())) {
			track.setAttribute("bpm",getBpm());
		}
		if (!StringUtils.isNullOrEmpty(getComment())) {
			track.setAttribute("comment",getComment());
		}
		if (!StringUtils.isNullOrEmpty(getType())) {
			track.setAttribute("type",getType());
		}
		if (!StringUtils.isNullOrEmpty(getTagVersion())) {
			track.setAttribute("tagversion",getTagVersion());
		}
		if (!StringUtils.isNullOrEmpty(getBitRate())) {
			track.setAttribute("bitrate",getBitRate());
		}
		if (!StringUtils.isNullOrEmpty(getFileSize())) {
			track.setAttribute("filesize",getFileSize());
		}
		if (!StringUtils.isNullOrEmpty(getDrm())) {
			track.setAttribute("drm",getDrm());
		}
		if (!StringUtils.isNullOrEmpty(getCoverArt())) {
			track.setAttribute("coverart",getCoverArt());
		}
		if (!StringUtils.isNullOrEmpty(getModificationTime())) {
			track.setAttribute("modificationTime",getModificationTime());
		}
		if (!StringUtils.isNullOrEmpty(getUrl())) {
			track.setAttribute("url",getUrl());
		}
		if (!StringUtils.isNullOrEmpty(getLyrics())) {
			track.setAttribute("lyrics",getLyrics());
		}
		if (!StringUtils.isNullOrEmpty(getRemote())) {
			track.setAttribute("remote",getRemote());
		}
		if (!StringUtils.isNullOrEmpty(getTitle())) {
			track.setAttribute("title",getTitle());
		}
		
		return(track);
	}
}
