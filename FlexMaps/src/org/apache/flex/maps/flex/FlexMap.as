/**
 * $Id$
 * Copyright 2013 Allens and Igor Costa
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 *	you may not use this file except in compliance with the License.
 *	You may obtain a copy of the License at
 *	
 *  http://www.apache.org/licenses/LICENSE-2.0
 *	
 *	Unless required by applicable law or agreed to in writing, software
 *	distributed under the License is distributed on an "AS IS" BASIS,
 *	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *	See the License for the specific language governing permissions and
 *	limitations under the License.
 *
 * GeoMap class is an ActionScript UI component. To use it in your application,
 * simply specify a new namespace in the root node of your application. As long as the
 * org.apache.flex namespace is in your path, Flex Builder should find the class
 * and auto-complete the element name once you've opened a new tag and typed the namespace.
 * 
 * The MXML component doesn't currently support the full org.apache.flex.Map API, but the
 * instance of that class is accessible via the (read-only) "map" getter if you need to
 * call any of its methods.
 * 
 */
package org.apache.flex.maps.flex
{

	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import org.apache.flex.maps.GeoMap;
	import org.apache.flex.maps.core.*;
	import org.apache.flex.maps.events.MapEvent;
	import org.apache.flex.maps.extras.MapControls;
	import org.apache.flex.maps.extras.MapCopyright;
	import org.apache.flex.maps.extras.MapScale;
	import org.apache.flex.maps.extras.NavigatorWindow;
	import org.apache.flex.maps.extras.ZoomBox;
	import org.apache.flex.maps.extras.ZoomSlider;
	import org.apache.flex.maps.geo.*;
	import org.apache.flex.maps.mapproviders.*;
	import org.apache.flex.maps.mapproviders.here.*;
	import org.apache.flex.maps.mapproviders.microsoft.*;
	import org.apache.flex.maps.mapproviders.yahoo.*;

    [Event(name="startZooming",      type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="stopZooming",       type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="zoomedBy",          type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="startPanning",      type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="stopPanning",       type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="panned",            type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="resized",           type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="mapProviderChanged",type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="beginExtentChange", type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="extentChanged",     type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="beginTileLoading",  type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="allTilesLoaded",    type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="rendered",          type="org.apache.flex.maps.events.MapEvent")]
    [Event(name="markerRollOver",    type="org.apache.flex.maps.events.MarkerEvent")]
    [Event(name="markerRollOut",     type="org.apache.flex.maps.events.MarkerEvent")]
    [Event(name="markerClick",       type="org.apache.flex.maps.events.MarkerEvent")]
    public class FlexMap extends UIComponent
	{
		public static const DEFAULT_MEASURED_WIDTH:Number = 400;
	    public static const DEFAULT_MEASURED_MIN_WIDTH:Number = 100;
	    public static const DEFAULT_MEASURED_HEIGHT:Number = 400;
	    public static const DEFAULT_MEASURED_MIN_HEIGHT:Number = 100;
	    public static const DEFAULT_MAX_WIDTH:Number = 10000;
	    public static const DEFAULT_MAX_HEIGHT:Number = 10000;

	    public static const DEFAULT_MAP_PROVIDER:IMapProvider = new BlueMarbleMapProvider();
		
		protected var _map:GeoMap;
		protected var mapInitDirty:Boolean = true;
		protected var _showControls:Boolean = false;

		public function FlexMap()
		{
			super();
		}

		public function get showControls():Boolean
		{
			return _showControls;
		}

		public function set showControls(value:Boolean):void
		{
			_showControls = value;
		}

		/**
		 * Since we're not yet supporting the full Map interface,
		 * make the instance gettable, read-only.
		 */
		public function get map():org.apache.flex.maps.GeoMap
		{
			return _map;
		}
		
		override protected function createChildren():void
		{			
			super.createChildren();
			if (mapInitDirty && _map == null)
			{
				// TODO: implement draggable switch?
				//trace(' * initializing map: ' + w + 'x' + h + ', ' + _draggable + ', provider: ' + _mapProvider.toString());
				//_map.init(w, h, _draggable, _mapProvider || DEFAULT_MAP_PROVIDER);
				_map = new GeoMap(unscaledWidth, unscaledHeight, _draggable, _mapProvider || DEFAULT_MAP_PROVIDER);
				_map.addEventListener(MouseEvent.MOUSE_WHEEL,_map.onMouseWheel);
				addChild(_map);
				mapProviderDirty = false;
				mapInitDirty = false;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (_map.getWidth() != unscaledWidth || _map.getHeight() != unscaledHeight)
			{
				_map.setSize(unscaledWidth, unscaledHeight);
			}
			
			// save extent setting until the map has a valid size
	        if (mapExtentDirty && _map.getWidth() > 0 && _map.getHeight() > 0)
	        {
				trace(' * extent is dirty, setting to: ' + _extent);
	            _map.setExtent(_extent);
	            mapExtentDirty = false;
	        }
		}

		protected var mapExtentDirty:Boolean = false;
		protected var _extent:MapExtent;
		protected var _mapExtentString:String;
		
		protected var mapCenterDirty:Boolean = true;
		protected var _centerLocation:Location = new Location(0, 0);
		protected var mapZoomDirty:Boolean = true;
		protected var _zoom:int = 1;

		/**
		 * The "extent" setter accepts either a MapExtent instance or a String;
		 * the latter is converted into a MapExtent using the static fromString()
		 * method. This allows the extent to be defined as a string in MXML
		 * attributes, a la "north, south, east, west".
		 */
		[Inspectable(category="MapComponent")]
		public function set extent(mapExtent:*):void
		{
			if (mapExtent is String)
			{
				// TODO: try/catch MapExtent.fromString()
				mapExtent = MapExtent.fromString(mapExtent);
			}
			
			if (!(mapExtent is MapExtent))
			{
				throw new Error("Invalid extent supplied");
			}
			trace("got extent: " + mapExtent);
			
			_extent = mapExtent;
			mapExtentDirty = true;
			mapCenterDirty = false;
			mapZoomDirty = false;
			invalidateProperties();
		}

		public function get extent():MapExtent
		{
			return _map ? _map.getExtent() : _extent;
		}

		/**
		 * Like the "extent" setter, the "center" setter accepts a String in addition to
		 * a Location object, so that locations can be specified in MXML attributes as
		 * strings ("lat, lon").
		 */
		[Inspectable(category="Map", defaultValue="0,0")]		
		public function set center(location:*):void
		{
			if (location is String)
			{
				location = Location.fromString(location);
			}

			if (!(location is Location))
			{
				throw new Error("Invalid location supplied");
			}
			
			_centerLocation = location;
			mapCenterDirty = true;
			mapExtentDirty = false;
			invalidateProperties();
		}

		public function get center():Location
		{
			return _map ? _map.getCenter() : _centerLocation;
		}
		
		public function set zoom(zoomLevel:int):void
		{
			_zoom = zoomLevel;
			mapZoomDirty = true;
			mapExtentDirty = false;
			invalidateProperties();
		}

		protected var mapProviderDirty:Boolean = true;
		protected var _mapProvider:IMapProvider = DEFAULT_MAP_PROVIDER;

		/**
		 * The "provider" setter accepts either a String (Flex Builder should provide
		 * a list of valid values per the Inspectable() metadata tag) or an IMapProvider
		 * instance. You can specify the latter in MXML by wrapping the constructor in
		 * braces:
		 * 
		 * @example
		 *  <pre> GeoMap provider="{new FancyCustomMapProvider()}" ...</pre>
		 */
		[Inspectable(category="Map",
					 enumeration="BLUE_MARBLE,HERE_MAP_HYBRID,HERE_MAP_TERRAIN,HERE_MAP_NORMAL,MICROSOFT_AERIAL,MICROSOFT_ROAD,MICROSOFT_HYBRID,YAHOO_ROAD,YAHOO_AERIAL,YAHOO_HYBRID,OPEN_STREET_MAP",
					 defaultValue="BLUE_MARBLE")]
		public function set provider(provider:*):void
		{
			if(provider is IMapProvider) {
				_mapProvider = provider;

			} else {
				switch(provider) {
					case "BLUE_MARBLE":
						_mapProvider = new BlueMarbleMapProvider();
						break;
					case  "HERE_MAP_NORMAL":
						_mapProvider = new HereMapProvider(HereMapProvider.NORMAL);
						break;
					case "HERE_MAP_HYBRID":
						_mapProvider = new HereMapProvider(HereMapProvider.HYBRID);
						break;
					case "HERE_MAP_TERRAIN":
						_mapProvider = new HereMapProvider(HereMapProvider.TERRAIN);
						break;
					case "OPEN_STREET_MAP":
						_mapProvider = new OpenStreetMapProvider();
						break;
					case "MICROSOFT_AERIAL":
						_mapProvider = new MicrosoftAerialMapProvider();
						break;
					case "MICROSOFT_HYBRID":
						_mapProvider = new MicrosoftHybridMapProvider();
						break;
					case "MICROSOFT_ROAD":
						_mapProvider = new MicrosoftRoadMapProvider();
						break;
					case "YAHOO_AERIAL":
						_mapProvider = new YahooAerialMapProvider();
						break;
					case "YAHOO_HYBRID":
						_mapProvider = new YahooHybridMapProvider();
						break;
					case "YAHOO_ROAD":
						_mapProvider = new YahooRoadMapProvider();
						break;
				}
			}
			mapProviderDirty = true;
			invalidateProperties();
		}

		public function get provider():IMapProvider
		{
			if (_map)
			{
				var provider:IMapProvider = _map.getMapProvider();
				return provider ? provider : _mapProvider;
			}
			else
			{
				return _mapProvider;
			}
		}

		protected var _draggable:Boolean = true;

		/**
		 * Currently the "draggable" setter will only work pre-initialization.
		 * In other words, setting draggable after the component has been
		 * initialized will have no effect; it's provided merely as a means for
		 * setting the property in MXML.
		 */
		[Inspectable(category="Map")]
		public function set draggable(isDraggable:Boolean):void
		{
			trace('draggable', isDraggable);
			if (initialized)
			{
				throw new Error("'draggable' is not settable post initialization");
			}
			else
			{
				_draggable = isDraggable;
			}
		}
		
		public function get draggable():Boolean
		{
			return _draggable;
		}

		/**
		 * Updates the map's provider, extent or center/zoom, and size. This is called
		 * by the Flex framework when necessary. There's probably some more optimization that
		 * could be done in the whole invalidation/validation/update process; for instance,
		 * a flag set in invalidateSize() could be used to determine whether or not we should
		 * call _map.setSize(), rather than just comparing the size.
		 */

		override protected function commitProperties():void
		{
			
		    if (_map!=null)
		    {
		        if (mapZoomDirty)
		        {
		            _map.setZoom(_zoom);
		            mapZoomDirty = false;
		        }
		
		        if (mapCenterDirty)
		        {
		            _map.setCenter(_centerLocation);
		            mapCenterDirty = false;
		        }
		
		        if (mapExtentDirty && _map.getWidth() > 0 && _map.getHeight() > 0)
		        {
		            _map.setExtent(_extent);
		            mapExtentDirty = false;
		        }

				if (mapProviderDirty)
				{
					_map.setMapProvider(_mapProvider);
					mapProviderDirty = false;
				}
				if(_showControls)
				{
					map.addChild(new MapCopyright(map, 143, 10));
					map.addChild(new ZoomBox(map));
					map.addChild(new ZoomSlider(map));
					map.addChild(new NavigatorWindow(map));
					map.addChild(new MapControls(map, true, true));
					map.addChild(new MapScale(map, 140));
				}
				
		    }

		    super.commitProperties();		

		}

	}	
}
