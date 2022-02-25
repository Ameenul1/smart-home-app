#include <DHT.h>


#if defined(ESP32)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif
#include <Firebase_ESP_Client.h>

//Provide the token generation process info.
#include <addons/TokenHelper.h>

//Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

/* 1. Define the WiFi credentials */
#define WIFI_SSID "Poco x3 pro"
#define WIFI_PASSWORD "9500578058"

//For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino

/* 2. Define the API Key */
#define API_KEY "AIzaSyAjnvWzCn5QaKAmhpdZ3Le2h44mSLjvxHw"

/* 3. Define the RTDB URL */
#define DATABASE_URL "home-automation-a9d61-default-rtdb.firebaseio.com" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app

/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL "ameenul8808@gmail.com"
#define USER_PASSWORD "12345678"

//Define Firebase Data object
FirebaseData stream0;
FirebaseData fbdo0;

FirebaseData stream1;
FirebaseData fbdo1;

FirebaseData fbdo2;

FirebaseAuth auth;
FirebaseConfig config;

//temperature
#define DHTTYPE DHT11   // DHT 11

#define dht_dpin 0
DHT dht(dht_dpin, DHTTYPE);

//pins

const int D1 =5;

const int D2 =4;

unsigned long sendDataPrevMillis = 0;

int count = 0;

volatile bool dataChanged0 = false;
volatile bool dataChanged1 = false;



void streamCallback0(FirebaseStream data)
{
  Serial.printf("sream path, %s\nevent path, %s\ndata type, %s\nevent type, %s\n\n",
                data.streamPath().c_str(),
                data.dataPath().c_str(),
                data.dataType().c_str(),
                data.eventType().c_str());
  printResult(data); //see addons/RTDBHelper.h
  Serial.println();

  Serial.printf("Received stream payload size: %d (Max. %d)\n\n", data.payloadLength(), data.maxPayloadLength());

  dataChanged0 = true;
}

void streamTimeoutCallback0(bool timeout)
{
  if (timeout)
    Serial.println("stream timed out, resuming...\n");
  if (!stream0.httpConnected())
    Serial.printf("error code: %d, reason: %s\n\n", stream0.httpCode(), stream0.errorReason().c_str());
}

void streamCallback1(FirebaseStream data)
{
  Serial.printf("sream path, %s\nevent path, %s\ndata type, %s\nevent type, %s\n\n",
                data.streamPath().c_str(),
                data.dataPath().c_str(),
                data.dataType().c_str(),
                data.eventType().c_str());
  printResult(data); //see addons/RTDBHelper.h
  Serial.println();
  Serial.printf("Received stream payload size: %d (Max. %d)\n\n", data.payloadLength(), data.maxPayloadLength());
  dataChanged1 = true;
}

void streamTimeoutCallback1(bool timeout)
{
  if (timeout)
    Serial.println("stream timed out, resuming...\n");

  if (!stream1.httpConnected())
    Serial.printf("error code: %d, reason: %s\n\n", stream1.httpCode(), stream1.errorReason().c_str());
}

void setup()
{

  Serial.begin(115200);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h

  //Or use legacy authenticate method
  //config.database_url = DATABASE_URL;
  //config.signer.tokens.legacy_token = "<database secret>";

  Firebase.begin(&config, &auth);

  Firebase.reconnectWiFi(true);

//Recommend for ESP8266 stream, adjust the buffer size to match your stream data size
#if defined(ESP8266)
  stream0.setBSSLBufferSize(2048 /* Rx in bytes, 512 - 16384 */, 512 /* Tx in bytes, 512 - 16384 */);
  stream1.setBSSLBufferSize(2048 /* Rx in bytes, 512 - 16384 */, 512 /* Tx in bytes, 512 - 16384 */);
#endif

  if (!Firebase.RTDB.beginStream(&stream0, "/devices/0"))
    Serial.printf("sream begin error0, %s\n\n", stream0.errorReason().c_str());

  Firebase.RTDB.setStreamCallback(&stream0, streamCallback0, streamTimeoutCallback0);

  if (!Firebase.RTDB.beginStream(&stream1, "/devices/1"))
    Serial.printf("sream begin error1, %s\n\n", stream1.errorReason().c_str());

  Firebase.RTDB.setStreamCallback(&stream1, streamCallback1, streamTimeoutCallback1);

  pinMode(D1,OUTPUT);
  pinMode(D2,OUTPUT);
}

void loop()
{
  //Flash string (PROGMEM and FPSTR), Arduino String, C++ string, const char, char array, string literal are supported
  //in all Firebase and FirebaseJson functions, unless F() macro is not supported.

  if (Firebase.ready() && (millis() - sendDataPrevMillis > 15000 || sendDataPrevMillis == 0))
  {
    sendDataPrevMillis = millis();

    float t = dht.readTemperature();

    Firebase.RTDB.setFloat(&fbdo1, "/temperature", t) ? "ok" : fbdo1.errorReason().c_str();
  }

  if (dataChanged0)
  {
    dataChanged0 = false;
    //When stream data is available, do anything here...
    String val1 = Firebase.RTDB.getBool(&fbdo0, "/devices/0/status") ? fbdo0.to<bool>() ? "true" : "false" : fbdo0.errorReason().c_str();

    if(val1=="true"){
      int degree = Firebase.RTDB.getInt(&fbdo0, "/devices/0/degree") ? fbdo0.to<int>():0;
      analogWrite(D1,round(1023*((float)degree/100)));
    }
    else if(val1=="false"){
      digitalWrite(D1,LOW);
    }
  }

  if (dataChanged1)
  {
    dataChanged1 = false;
    //When stream data is available, do anything here...
    String val2 = Firebase.RTDB.getBool(&fbdo1, "/devices/1/status") ? fbdo1.to<bool>() ? "true" : "false" : fbdo1.errorReason().c_str();

    if(val2=="true"){
      int degree = Firebase.RTDB.getInt(&fbdo1, "/devices/1/degree") ? fbdo1.to<int>():0;
      analogWrite(D2,round(1023*((float)degree/100)));
    }
    else if(val2=="false"){
      digitalWrite(D2,LOW);
    }
  }
}
