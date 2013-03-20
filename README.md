Open source Flex-Maps for Apache Flex

This is a open-source solution to enable Flex developers incorporate
Maps on their very own apps.

Goal is simple, great a great user experience inside Flex environment
loading tiles, maps providers from all exposed api out there.


<h2>Current Maps providers</h2>

Microsoft Bing
OpenStreet
Nokia Here
Yahoo Maps
Nasa Blue Marble

feature releases to support Google Maps

<h2>Using it's pretty simple:</h2>

<code>
<?xml version="1.0" encoding="utf-8"?>
<s:Application xmlns:fx="http://ns.adobe.com/mxml/2009" 
			   xmlns:s="library://ns.adobe.com/flex/spark" 
			   xmlns:mx="library://ns.adobe.com/flex/mx" minWidth="955" minHeight="600" xmlns:flex="org.apache.flex.maps.flex.*">
		<s:layout>
			<s:VerticalLayout/>
		</s:layout>	 

		<fx:Script>
			<![CDATA[
				import spark.events.IndexChangeEvent;
				
				protected function onProviderChanged(event:IndexChangeEvent):void
				{
					myMap.provider = provider.selectedItem.value;
				}
				
			]]>
		</fx:Script>
		<s:HGroup>
			<s:Button width="82" height="22" label="Zoom In" click="myMap.map.zoomIn(event)"/>
			<s:Button label="Zoom Out" click="myMap.map.zoomOut(event)"/>
				<s:ComboBox id="provider" change="onProviderChanged(event)">
						<s:dataProvider>
							<s:ArrayList>
								<fx:Object label="NASA BLUE MARBLE" value="BLUE_MARBLE"/>
								<fx:Object label="Open Street Map" value="OPEN_STREET_MAP"/>
								<fx:Object label="Nokia HERE Normal" value="HERE_MAP_NORMAL"/>
								<fx:Object label="Nokia HERE Hybrid" value="HERE_MAP_HYBRID"/>
								<fx:Object label="Yahoo Aerial" value="YAHOO_AERIAL"/>
								<fx:Object label="Yahoo Hybrid" value="YAHOO_HYBRID"/>
								<fx:Object label="Yahoo Road" value="YAHOO_ROAD"/>								
								<fx:Object label="Nokia HERE TERRAIN" value="HERE_MAP_TERRAIN"/>
								<fx:Object label="Microsoft Hybrid" value="MICROSOFT_HYBRID"/>
								<fx:Object label="Microsoft Hybrid" value="MICROSOFT_HYBRID"/>
								<fx:Object label="Microsoft Aerial" value="MICROSOFT_AERIAL"/>
								<fx:Object label="Microsoft ROAD" value="MICROSOFT_ROAD"/>
							</s:ArrayList>
						</s:dataProvider>
				</s:ComboBox>
		</s:HGroup>

				
				<flex:FlexMap showControls="true" id="myMap"
									 width="100%" extent="-9.4384955,-40.3835929,12,0,0" height="100%" 
									 draggable="true" provider="HERE_MAP_HYBRID" 
									 zoom="12" center="-9.4384955,-40.3835929,12,0,0"
									 doubleClick="myMap.map.onDoubleClick(event)" />
</s:Application>
</code>


This project is a based on ModestMap technology.


