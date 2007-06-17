package au.com.BI.MultiMedia.SlimServer.Commands;

import au.com.BI.Util.Type;

public class SongInfoTag extends Type {
	public static final SongInfoTag GENRE = new SongInfoTag("g","genre");
	public static final SongInfoTag GENRE_ID = new SongInfoTag("p","genre_id");
	public static final SongInfoTag ARTIST = new SongInfoTag("a","artist");
	public static final SongInfoTag ARTIST_ID = new SongInfoTag("s","artist_id");
	public static final SongInfoTag COMPOSER = new SongInfoTag("c","composer");
	public static final SongInfoTag BAND = new SongInfoTag("b","band");
	public static final SongInfoTag CONDUCTOR = new SongInfoTag("h","conductor");
	public static final SongInfoTag ALBUM = new SongInfoTag("l","album");
	public static final SongInfoTag ALBUM_ID = new SongInfoTag("e","album_id");
	public static final SongInfoTag DURATION = new SongInfoTag("d","duration");
	public static final SongInfoTag DISC_NUMBER = new SongInfoTag("i","disc_number");
	public static final SongInfoTag DISCCOUNT = new SongInfoTag("q","disccount");
	public static final SongInfoTag TRACK_NUMBER = new SongInfoTag("t","tracknum");
	public static final SongInfoTag YEAR = new SongInfoTag("y","year");
	public static final SongInfoTag BPM = new SongInfoTag("m","bpm");
	public static final SongInfoTag COMMENT = new SongInfoTag("k","comment");
	public static final SongInfoTag TYPE = new SongInfoTag("o","type");
	public static final SongInfoTag TAG_VERSION = new SongInfoTag("v","tagversion");
	public static final SongInfoTag BITRATE = new SongInfoTag("r","bitrate");
	public static final SongInfoTag FILESIZE = new SongInfoTag("f","filesize");
	public static final SongInfoTag DRM = new SongInfoTag("z","drm");
	public static final SongInfoTag COVERART = new SongInfoTag("j","coverart");
	public static final SongInfoTag MODIFICATION_TIME = new SongInfoTag("n","modificationTime");
	public static final SongInfoTag URL = new SongInfoTag("u","url");
	public static final SongInfoTag LYRICS = new SongInfoTag("w","lyrics");
	public static final SongInfoTag REMOTE = new SongInfoTag("x","remote");
	
	private SongInfoTag(String value, String desc) {
		super(value, desc);
	}
	
	public static SongInfoTag getByValue(String value) {
		return((SongInfoTag)SongInfoTag.getByValue(SongInfoTag.class,value));
	}
	
	public static SongInfoTag getByDescription(String description) {
		return((SongInfoTag)SongInfoTag.getByDescription(SongInfoTag.class, description));
	}
}
