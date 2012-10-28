#include <Wire.h>
#include <SPI.h>
#include <LiquidCrystal.h>

/*
* LCD RS pin to digital pin 12 (8)
 * LCD Enable pin to digital pin 11 (7)
 * LCD D4 pin to digital pin 5 (6) 
 * LCD D5 pin to digital pin 4 (5)
 * LCD D6 pin to digital pin 3 (4)
 * LCD D7 pin to digital pin 2 (3)
 * LCD R/W pin to ground
 */
LiquidCrystal lcd(8, 7, 6, 5, 4, 3);

const int slaveSelectPin = 10;
char x;

void setup() {
  pinMode (slaveSelectPin, OUTPUT);
  digitalWrite(slaveSelectPin,HIGH); 
  SPI.begin();
  SPI.setClockDivider(SPI_CLOCK_DIV8);
  SPI.setBitOrder(MSBFIRST);
  //Serial.begin(9600);
  Wire.begin(9);                // Start I2C Bus as a Slave (Device Number 9)
  Wire.onReceive(receiveEvent);
  lcd.begin(20, 4); // register event
  lcd.autoscroll();
  lcd.print("Go!");
}

void loop() {
}

void receiveEvent(int howMany) {
  x = Wire.read();
  lcd.print(x);
  //bring slave select low,
  //send byte, bring high again.
  digitalWrite(slaveSelectPin,LOW);
  //  send in the address and value via SPI:
  SPI.transfer(x);
  // take the SS pin high to de-select the chip:
  digitalWrite(slaveSelectPin,HIGH); 
}
