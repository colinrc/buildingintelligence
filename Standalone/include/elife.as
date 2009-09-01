import mx.transitions.Tween;
import mx.transitions.easing.*;
import flash.filters.DropShadowFilter;
import flash.display.BitmapData;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;

_global.clientVersion = "5.5.0b82";
_global.serverVersion = "0.0.0"; 
_global.clientStartTime = getTimer();

XML.prototype.ignoreWhite = true;

#include "include/dateTime.as"
#include "include/drawRect.as"
#include "include/parseXML.as"
#include "include/debug.as"
#include "include/sockets.as"

#include "include/defaults.as"
#include "include/client.as"
#include "include/core.as"