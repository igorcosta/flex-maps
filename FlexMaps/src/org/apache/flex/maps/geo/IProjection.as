/*
 * $Id$
 */

package org.apache.flex.maps.geo
{ 
	import flash.geom.Point;
	import org.apache.flex.maps.core.Coordinate;
	import org.apache.flex.maps.geo.Location;

	public interface IProjection
	{
	   /*
	    * Return projected and transformed point.
	    */
	    function project(point:Point):Point;
	    
	   /*
	    * Return untransformed and unprojected point.
	    */
	    function unproject(point:Point):Point;
	    
	   /*
	    * Return projected and transformed coordinate for a location.
	    */
	    function locationCoordinate(location:Location):Coordinate;
	    
	   /*
	    * Return untransformed and unprojected location for a coordinate.
	    */
	    function coordinateLocation(coordinate:Coordinate):Location;
	    
	    function toString():String;
	}
}