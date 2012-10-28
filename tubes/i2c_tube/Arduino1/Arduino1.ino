
int serIn;

void setup()
{
  // start serial port at 9600 bps:
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
    if(serIn > 64 && serIn < 91){
      Serial.print('Caps!');
    }      
  }
}
