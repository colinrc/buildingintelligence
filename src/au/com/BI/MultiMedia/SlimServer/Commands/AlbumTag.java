package au.com.BI.MultiMedia.SlimServer.Commands;

import au.com.BI.Util.Type;

public class AlbumTag extends Type {
	public static final AlbumTag ALBUM = new AlbumTag("l","album");
	public static final AlbumTag YEAR = new AlbumTag("y","year");
	public static final AlbumTag ARTWORK_TRACK_ID = new AlbumTag("j","artwork track ID");
	public static final AlbumTag TITLE = new AlbumTag("t","title");
	public static final AlbumTag DISC = new AlbumTag("i","disc");
	public static final AlbumTag DISCCOUNT = new AlbumTag("q","discount");
	public static final AlbumTag COMPILATION = new AlbumTag("w","compilation");
	
	private AlbumTag(String value, String desc) {
		super(value, desc);
	}
	
	public static AlbumTag getByValue(String value) {
		return((AlbumTag)AlbumTag.getByValue(AlbumTag.class,value));
	}
	
	public static AlbumTag getByDescription(String description) {
		return((AlbumTag)AlbumTag.getByDescription(AlbumTag.class, description));
	}
}
