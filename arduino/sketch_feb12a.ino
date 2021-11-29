#include <ESP8266WiFi.h>

WiFiServer wifiServer(80);

const char* ssid = "Poco x3 pro";
const char* pass = "9500578058";

const int REDLED = 5;
const int GREENLED = 4;

void setup() {
  Serial.begin(115200);
  pinMode(REDLED,OUTPUT);
  pinMode(GREENLED,OUTPUT);
  delay(100);
  WiFi.begin(ssid,pass);
  while(WiFi.status() != WL_CONNECTED){
    delay(1000);
    Serial.println("Connecting....");
  }
  Serial.print("Connected to WiFi. ip:");
  Serial.print(WiFi.localIP());
  wifiServer.begin();
}

void loop() {
  WiFiClient client = wifiServer.available();
  char c;
  if(client){
    while(client.connected()){
      while(client.available()>0){
        c = client.read();
        if(c=='r'){
          digitalWrite(REDLED,HIGH);
        }
        else if(c=='0'){
          digitalWrite(REDLED,LOW);
        }
        else if(c=='g'){
          digitalWrite(GREENLED,HIGH);
        }
        else if(c=='1'){
          digitalWrite(GREENLED,LOW);
        }
      }
      delay(10);
    }
    client.stop();
    Serial.println("disconnected");
  }
}
