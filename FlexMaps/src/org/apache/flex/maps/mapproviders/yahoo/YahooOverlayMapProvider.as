package org.apache.flex.maps.mapproviders.yahoo
{
	import org.apache.flex.maps.core.Coordinate;
	import org.apache.flex.maps.mapproviders.AbstractMapProvider;
	import org.apache.flex.maps.mapproviders.IMapProvider;
	
	/**
	 * @author darren
	 * $Id$
	 */
	public class YahooOverlayMapProvider 
		extends AbstractMapProvider
		implements IMapProvider
	{
	    public function YahooOverlayMapProvider(minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM)
        {
            super(minZoom, maxZoom);
        }
        
		public function toString():String
		{
			return "YAHOO_OVERLAY";
		}
		
		public function getTileUrls(coord:Coordinate):Array
		{		
	        return [ "http://us.maps3.yimg.com/aerial.maps.yimg.com/img?md=200608221700&v=2.0&t=h" + getZoomString(sourceCoordinate(coord)) ];
		}
		
		private function getZoomString( coord:Coordinate ):String
		{		
	        var row:Number = ( Math.pow( 2, coord.zoom ) /2 ) - coord.row - 1;	
			return "&x=" + coord.column + "&y=" + row + "&z=" + ( 18 - coord.zoom ); 
		}	
	
	}
}