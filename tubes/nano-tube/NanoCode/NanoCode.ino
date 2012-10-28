#include <SPI.h>
#include <Ethernet.h>
#include <PusherClient.h>

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
PusherClient client;

void setup() {
  
  Serial.begin(9600);
  if (Ethernet.begin(mac) == 0) {
    Serial.println("Init Ethernet failed");
    for(;;)
      ;
  }
  
  if(client.connect("afefd11a8f69dd2a425d")) {
    client.bind("input", msgInput);
    client.bind("output", msgOutput);
    client.bind("processing", msgProcessing);
    client.subscribe("messages");
  }
  else {
    while(1) {}
  }
}

void loop() {
  if (client.connected()) {
    client.monitor();
  }
}

void msgInput(String data) {
  Serial.println(data);
}

void msgOutput(String data) {
  Serial.println(data);
}

void msgProcessing(String data) {
  Serial.println(data);
}
