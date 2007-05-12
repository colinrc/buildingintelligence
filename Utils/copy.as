
import flash.xml.XMLDocument;
	
Object.prototype.copy = function() {
	if (this.__proto__.constructor == XMLNode) {
		var ret = new XMLDocument(this.toString());
		trace (this.toString());
	}else{
		var ret = new this.__proto__.constructor();
		for(var n in this){
			if (this[n].__proto__.constructor == XMLNode){
				ret[n] = new XMLDocument(this[n].toString());
			}else if (typeof(this[n]) == 'object'){
				ret[n] = this[n].copy();
			}else {
				ret[n] = this[n];
			}
		}
	}
}
ASSetPropFlags(Object.prototype,"copy",1)