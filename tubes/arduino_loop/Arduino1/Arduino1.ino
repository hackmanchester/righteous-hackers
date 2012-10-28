
#include <Wire.h>
#include <SPI.h>
#define LED_PIN 13

int serIn;

void setup()
{
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);
  
  pinMode(MISO, OUTPUT);
  SPCR |= _BV(SPE);
  SPCR |= _BV(SPIE);
  SPI.attachInterrupt();
  Wire.begin();
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
}

void loop()
{
  // if we get a valid byte, read analog ins:
  if (Serial.available() > 0) {
    // get incoming byte:
    serIn = Serial.read();
    Wire.beginTransmission(9); // transmit to device #9
    Wire.write(serIn);              // sends x 
    Wire.endTransmission();    // stop transmitting
  }
}

ISR (SPI_STC_vect)
{
  char c = SPDR;
  Serial.print(c);
}
