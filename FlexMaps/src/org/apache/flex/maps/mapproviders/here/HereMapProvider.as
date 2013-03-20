package org.apache.flex.maps.mapproviders.here
{
	import org.apache.flex.maps.core.Coordinate;
	import org.apache.flex.maps.mapproviders.AbstractMapProvider;
	import org.apache.flex.maps.mapproviders.IMapProvider;	
	
	/**
	 * @author Igor Costa
 	 * $Id:$
	 */
	
	public class HereMapProvider extends AbstractMapProvider implements IMapProvider
	{
		public static const NORMAL:String = "NORMAL";
		public static const HYBRID:String = "HYBRID";
		public static const TERRAIN:String = "TERRAIN";

		protected static var serverSalt:int = Math.round(Math.random() * (4 - 1) + 1);
		
	
		
		protected var type:String;
		protected var hillShading:Boolean;
		
		public function HereMapProvider(type:String=NORMAL, hillShading:Boolean=true, minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM)
		{
		    super(minZoom, maxZoom);
		    
			this.type = type;
			this.hillShading = hillShading;
		}
		
		protected function getZoomString(coord:Coordinate):String
		{
			return "/" + coord.zoom + "/" + coord.column + "/" + coord.row;	
			
		}
	
		public function toString():String
		{
			return "HERE_MAP_"+type;
		}
		protected const mapType:Object = {
			NORMAL: "normal.day",
			HYBRID: "hybrid.day",
			TERRAIN:"terrain.day"
		}
		public function getTileUrls(coord:Coordinate):Array
		{
			if (coord.row < 0 || coord.row >= Math.pow(2, coord.zoom)) {
				return null;
			}
			return [ 'http://'+serverSalt + '.maps.nlp.nokia.com/maptile/2.1/maptile/d3617790e3/'+ mapType[type] + getZoomString(coord) + '/256/png8?app_id=SqE1xcSngCd3m4a1zEGb&token=r0sR1DzqDkS6sDnh902FWQ'];
		}
	
	}
}