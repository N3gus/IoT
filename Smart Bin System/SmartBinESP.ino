#include <WiFi.h>
const char* ssid     = "MUKUBA-UNIPOD"; // WiFi name
const char* password = "undp@20243"; // WiFi password
WiFiServer server(80);
String yazi;

#include <Wire.h>

// serial communication pins (arduino)
#define RX0 3
#define TX0 1


void setup()
{
    Serial.begin(115200);
    Serial2.begin(9600, SERIAL_8N1, RX0, TX0);

    Serial.print("Connecting to ");
    Serial.println(ssid);

WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("");
    Serial.println("WiFi connected");
    Serial.println("IP address: ");    // this is the address to use for viewing the map
    Serial.println(WiFi.localIP());
    server.begin();
}

void loop(){
 WiFiClient client = server.available();    // listen for incoming clients
   String WasteLevel = Serial2.readString();
  
  if (client) {                             
    Serial.println("new client");          
    String currentLine = "";                // make a String to hold incoming data from the client
    while (client.connected()) {            
      if (client.available()) {             // if there's client data
        char c = client.read();          // read a byte
          if (c == '\n') {                      // check for newline character,
          if (currentLine.length() == 0) {  // if line is blank it means its the end of the client HTTP request
      
yazi="<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'><meta http-equiv='X-UA-Compatible' content='ie=edge'><title>My Google Map</title><style>#map{height:400px;width:100%;}</style></head> <body><h1>My Google Map</h1><div id='map'></div><script>function initMap(){var options = {zoom:8,center:{lat:";
    yazi+="<li>Waste Level: ";
    yazi+= WasteLevel;
    yazi+= "&deg;C</li>";
    yazi+="}};var map = new google.maps.Map(document.getElementById('map'), options);google.maps.event.addListener(map, 'click', function(event){addMarker({coords:event.latLng});});var markers = [{coords:{lat:";
yazi+=",lng:";
yazi+="}}];for(var i = 0;i < markers.length;i++){addMarker(markers[i]);}function addMarker(props){var marker = new google.maps.Marker({position:props.coords,map:map,});if(props.iconImage){marker.setIcon(props.iconImage);}if(props.content){var infoWindow = new google.maps.InfoWindow({content:props.content});marker.addListener('click', function(){infoWindow.open(map, marker);});}}}</script><script async defer src='https://maps.googleapis.com/maps/api/js?key=AIzaSyDHNUG9E870MPZ38LzijxoPyPgtiUFYjTM&callback=initMap'></script></body></html>";
 
 
 client.print(yazi);

            // The HTTP response ends with another blank line:
            client.println();
            // break out of the while loop:
            break;
          } else {   currentLine = ""; }
        } else if (c != '\r') {  // if you got anything else but a carriage return character,
          currentLine += c; // add it to the end of the currentLine
        }
      }
    }
    // close the connection:
    client.stop();
    Serial.println("client disconnected");
    }
}
