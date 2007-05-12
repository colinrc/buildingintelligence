package Utils {
	/*
	************************************************************
	Developed by R.Arul Kumaran [arul@shockwave-india.com]     *
	for more code keep visiting [www.shockwave-india.com/blog] *
	************************************************************
	version 1.0 Last updated on 19 July, 2004
	*/
	/*
	XMLHighlighter generates color highlighted pretty printed HTML code
	*/
	import flash.xml.*;
	import Forms.XMLDrawer;
	public class XMLHighlighter {
		public static var useCDATA:Boolean = true;
		//_c: color string list
		private static var _c:Object = {tag:'0000FF', att:'FF0000', txt:'000000', tgt:'990000'};
		//_fTag: get font begin tag
		private static function _fTag(clr:String, content:String) {
			return "<font color='#"+clr+"'>"+content;
		}
		// _tf: font tag close string
		private static var _tf:String = "</font>";
		// public function
		public  function highlight(y:XML):String {
			var x:XMLDocument = new XMLDocument(y.toXMLString());
			var ignoreWhite = x.ignoreWhite;
			var s:String = _fTag(_c.tag, '');
			x.ignoreWhite = true;
			if (x.nodeName == undefined) {
				if (x.xmlDecl != undefined) {
					s += x.createTextNode(x.xmlDecl)+'\r';
				}
				if (x.docTypeDecl != undefined) {
					s += x.createTextNode(x.docTypeDecl)+'\r';
				}
				s += _getHStr(x.firstChild, '', '');
			} else {
				s += _getHStr(x, '', '');
			}
			x.ignoreWhite = ignoreWhite;
			return "<pre>"+s+_tf+"</pre>";
		}
		private static function _getHStr(x:XMLNode, tab, r):String {
			var s:String = '';
			switch (x.nodeType) {
				//TEXT_NODE
			case 3 :
				//Is it a CDATA Node?
				var xt:String = x.toString();
				if (useCDATA && (x.nodeValue.indexOf('<') != -1 || x.nodeValue.indexOf('>') != -1)) {
					s = "&lt;![CDATA["+_fTag(_c.txt, '<b>'+xt+'</b>')+_tf+"]]&gt;";
				} else {
					s = _fTag(_c.txt, '<b>'+xt.split('&').join('&amp;')+'</b>')+_tf;
				}
				break;
				//ELEMENT_NODE
			case 1 :
			default :
				s = r+tab+'&lt;'+_fTag(_c.tgt, x.nodeName)+_tf;
				for (var v in x.attributes) {
					s += _fTag(_c.tgt, " "+v)+_tf+"=&quot;"+_fTag(_c.att, x.attributes[v])+_tf+"&quot;";
				}
				if (x.firstChild == null) {
					s += "/&gt;";
				} else {
					s += "&gt;"+_getHStr(x.firstChild, tab+"\t", "");  //\r removed from 3rd 
					if (x.lastChild.nodeType == 3) {
						s += tab+"&lt;/"; //tab added
					} else {
						s += '\r'+tab+"&lt;/";
					}
					s += _fTag(_c.tgt, x.nodeName)+_tf+"&gt;";
				}
			}
			if (x.nextSibling != null) {
				s += _getHStr(x.nextSibling, tab, r);
			}
			return s;
		}
	}
}