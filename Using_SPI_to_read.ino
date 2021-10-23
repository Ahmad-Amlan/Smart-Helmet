#include <Arduino.h>
#include <SPI.h>

//system commands
byte WAKEUP = 0x02;
byte STANDBY = 0x04;
byte RESET = 0x06;
byte START = 0x08;
byte STOP = 0x0a;

// pin assignment(digital)
//int DRDY = 3;
//int START_pin = 9;
int CS_ads = 10;
//int RESET_PIN = 8;
//int DIN =  11;
//int DOUT = 12;
//int RESET_pin = 7;
//int PIN_CLKSEL = 13;

byte op1 = 0b00100000;
byte op2 = 0b00000001;
byte inByte1 = 0;           // incoming byte from the SPI
byte inByte2 = 0;           // incoming byte from the SPI
int result;
//declare function

void writeRegister(byte thisRegister, byte thisValue);

void setup() {
  Serial.begin(9600);
  // start the SPI library:
  SPI.begin();
  //SPI.beginTransaction(SPISettings(14000000, MSBFIRST, SPI_MODE1));
//  arduinoSetup();

  //write to register
  //adsWreg();

}

void loop() {

  // read register value

   writeRegister(op1,op2);
   delay(1000);
   Serial.print("Delay 1 second");
   Serial.println();
 
}




void writeRegister(byte thisRegister, byte thisValue) {
  digitalWrite(CS_ads, LOW); 
  SPI.transfer(thisRegister); //opcode 1
  SPI.transfer(thisValue);  //opcode 2
  inByte1 = SPI.transfer(0x00); //read SPI line
  inByte2 = SPI.transfer(0x00); //read SPI line
  Serial.print("Register1(ID) int =  ");
  Serial.println(inByte1);
  Serial.print("Register2(config1) int =  ");
  Serial.println(inByte2 );
  digitalWrite(CS_ads, HIGH);
}

/*
void arduinoSetup() {


    pinMode(START_pin, OUTPUT);
    pinMode(DRDY, INPUT);
    pinMode(CS_ads, OUTPUT);// *optional
    pinMode(RESET_PIN, OUTPUT);// *optional
    
    //Start ADS1298

    delay(10); // wait for oscillator to wake up
    digitalWrite(RESET_PIN, HIGH);
    delay(1000);
    digitalWrite(RESET_PIN, LOW);
    delay(1);
    digitalWrite(RESET_PIN, HIGH);
    delay(1);  // *optional Wait for 18 tCLKs AKA 9 microseconds, we use 1 millisecond
} 
*/

void adsWreg() {
  
      //adsSendCommand(STOP);
      digitalWrite(CS_ads, LOW);
      
      SPI.transfer(0b01000001);  // command write 
      SPI.transfer(0b00000001);  // number of reg-1
      
      SPI.transfer(0b01000000); // reg1 value
      SPI.transfer(0b00110000); // reg2 value
      
      digitalWrite(CS_ads, HIGH);
      //adsSendCommand(STOP);
}

void adsSendCommand(byte cmd ) {
     
      digitalWrite(CS_ads, LOW);
      SPI.transfer(cmd);
      digitalWrite(CS_ads, HIGH);
}
