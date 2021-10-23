#include <SPI.h>

// pin assignment(digital)
int DRDY = 3;
int START_pin = 9;
int CS_ads = 10;
int DIN =  11;
int DOUT = 12;
int RESET_pin = 8;

//system commands
byte WAKEUP = 0x02;
byte STANDBY = 0x04;
byte RESET = 0x06;
byte START = 0x08;
byte STOP = 0x0a;

//data read commands
byte RDATAC = 0x10;
byte SDATAC = 0x11;
byte RDATA = 0x12;

//register command
byte RREG = 0x20;
byte WREG = 0x40;

//register address

    // device settings
    byte ID = 0x00;

    // global settings
    byte CONFIG1 = 0x01;
    byte CONFIG2 = 0x02;
    byte CONFIG3 = 0x03;
    byte LOFF = 0x04;

    // channel specific settings
    byte CHnSET = 0x04;
    byte CH1SET = CHnSET + 1;
    byte CH2SET = CHnSET + 2;
    byte CH3SET = CHnSET + 3;
    byte CH4SET = CHnSET + 4;
    byte CH5SET = CHnSET + 5;
    byte CH6SET = CHnSET + 6;
    byte CH7SET = CHnSET + 7;
    byte CH8SET = CHnSET + 8;
    byte RLD_SENSP = 0x0d;
    byte RLD_SENSN = 0x0e;
    byte LOFF_SENSP = 0x0f;
    byte LOFF_SENSN = 0x10;
    byte LOFF_FLIP = 0x11;

    // lead off status
    byte LOFF_STATP = 0x12;
    byte LOFF_STATN = 0x13;

    // other
    byte GPIO = 0x14;
    byte PACE = 0x15;
    byte RESP = 0x16;
    byte CONFIG4 = 0x17;
    byte WCT1 = 0x18;
    byte WCT2 = 0x19;

//declare variable
byte id;
byte config1;
byte config2;
byte config3;
byte loff;
byte ch1;

//declare functions
void arduinoSetup();
void adsSendCommand(byte cmd );
void adsRreg();
void adsWreg();


// set up the speed 2MHz, data order and data mode(refer one note)
SPISettings settingsA(2000000, MSBFIRST, SPI_MODE1);

void setup()
  {
    Serial.begin(9600);
    SPI.begin();
    SPI.beginTransaction(settingsA);

    //power up the chip
    arduinoSetup(); 
    adsSendCommand(WAKEUP);
    adsSendCommand(RESET);
    adsSendCommand(START);
    
    
//write register    
    adsWreg();

// read register 
    adsRreg(4); // read 5 registers
  }

void loop(){
 adsRDATA(RDATA);
 delay(1000);
 
}

void adsSendCommand(byte cmd ) {
      digitalWrite(CS_ads, LOW);
      SPI.transfer(cmd);
      digitalWrite(CS_ads, HIGH);
}

void adsRreg(byte no_Reg) {
      digitalWrite(CS_ads, LOW);
 
      SPI.transfer(RREG);  // command read(opcode1)
      SPI.transfer(no_Reg);  // number of reg - 1(opcode2)
      
      id = SPI.transfer(0);  //  read ID reg 
      config1 = SPI.transfer(0);  //  read config1 reg 
      config2 = SPI.transfer(0);  //  read config2 reg 
      config3 = SPI.transfer(0);  //  read config3 reg
      loff = SPI.transfer(0);  //  read lead off reg
      ch1 = SPI.transfer(0);  //  read channel 1 reg
   
      digitalWrite(CS_ads, HIGH);
      
      //print register value
      Serial.print("ID value out: ");
      Serial.println(id,BIN);
      Serial.print("Config 1 value out: ");
      Serial.println(config1,BIN);
      Serial.print("Config 2 value out: ");
      Serial.println(config2,BIN);
      Serial.print("Config 3 value out: ");
      Serial.println(config3,BIN);
      Serial.print("lead off value out: ");
      Serial.println(loff,BIN);
      Serial.print("Channel 1 value out: ");
      Serial.println(ch1,BIN);
}

void adsWreg() {
      digitalWrite(CS_ads, LOW);
      
      SPI.transfer(0x30);  // command write (opcode1)
      SPI.transfer(0x1);  // number of reg-1 (opcode2)
   
      SPI.transfer(0b01000110); // config1 value
      SPI.transfer(0b00110000); // config2 value
      SPI.transfer(0b1000000); // config3 value
      SPI.transfer(0b00000000); // lead off value
      SPI.transfer(0x00010000); // channel 1 value
      
      digitalWrite(CS_ads, HIGH);

}

void adsRDATA(byte command){
  int dataIn;
      digitalWrite(START,HIGH);
      digitalWrite(CS_ads, LOW);
      adsSendCommand(RDATA);
      while (digitalRead(DRDY) == HIGH){
          dataIn = SPI.transfer(0);
          Serial.print("data recieved = "); 
          Serial.println(dataIn,BIN);
        };
        digitalWrite(CS_ads, HIGH);
}
  
void arduinoSetup(){
// prepare pins to be outputs or inputs
    pinMode(DRDY,INPUT);
    pinMode(START_pin,OUTPUT);
    pinMode(CS_ads, OUTPUT);
    pinMode(DIN,OUTPUT);
    pinMode(DOUT,INPUT);
    pinMode(RESET_pin ,OUTPUT);
    

//Start ADS1298
    
    delay(500); //wait for the ads129n to be ready - it can take a while to charge caps
    digitalWrite(RESET_pin, HIGH);
    delay(1000);
    digitalWrite(RESET_pin, LOW); // reset
    delay(1);
    digitalWrite(RESET_pin, HIGH);
    delay(1);  // *optional Wait for 18 tCLKs AKA 9 microseconds, we use 1 millisecond
    digitalWrite(START_pin,LOW);
}
