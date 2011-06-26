#include "NeSynth08mk2.h"

const unsigned char seq[][3] = {
  // index,  note,  gate
#if(1)
  {      0,     1,    16 },
  {      0,     5,    16 },
  {      0,     8,    16 },
  {      0,    12,    16 },
  {      0,    13,    16 },
  {      4,    10,     4 },
  {      5,    12,     4 },
  {      6,    13,     4 },
  {      7,     0,     4 },
#else
  {      0,     1,     6 },
  {      1,     3,     6 },
  {      2,     5,     6 },
  {      3,     6,     6 },
  {      4,     8,     6 },
  {      5,    10,     6 },
  {      6,    12,     6 },
  {      7,    13,     6 },
  {      8,     0,     6 },
#endif
  {   0xFF,     0,     0 } // End Mark 
};

unsigned char seqIdx = 0;
unsigned char beatIdx = 0;
unsigned char pastBeat = (unsigned char)0xFF;

ISR ( TIMER0_COMPA_vect ) {
  short outVol = NeSynth08mk2::main();
   
  // PWM Output
  if ( 0 < outVol ) {
    OCR2A = (unsigned char)( outVol);
    OCR2B = 0;
  }
  else if ( outVol < 0 ) {
    OCR2A = 0;
    OCR2B = (unsigned char)(-outVol);
  }
  else {
    OCR2A = 0;
    OCR2B = 0;
  }
}

void setup() {
  pinMode(11, OUTPUT); // Speker out +
  pinMode(3, OUTPUT);  // Speker out -(GND)
  
  pinMode(13, OUTPUT);
  digitalWrite( 13, LOW );

  NeSynth08mk2::init( 138 ); // set BPM

  // for NeSynth08
  TCCR0A = 0b00000010; // CTC
  TCCR0B = 0b00000010; // 1/8
  OCR0A = 64;
  TIMSK0 = 0b00000010;

  // PWM Setting
  TCCR2A = 0b10100011; // Fast PWM
  TCCR2B = 0b00000001; // 1/1
  OCR2A = 0;
  OCR2B = 0;

  TCNT0 = 0;
  sei();
}

void loop() {
  unsigned char beat = NeSynth08mk2::beat();
  
  // if BPM = 60, blink 2Hz.
  if ( (beat & (unsigned char)0x08) == 0 ) {
    digitalWrite( 13, HIGH );
  }
  else {
    digitalWrite( 13, LOW );
  }
  
  if ( pastBeat != (beat >> 4) ) {
    const unsigned char *p = seq[seqIdx];
    if ( p[0] == (unsigned char)0xFF ) {
      seqIdx = 0;
      beatIdx = 0; 
    }

    if ( p[0] == beatIdx ) {
      if ( p[1] != (unsigned char)0 ) {
        NeSynth08mk2::noteOn( p[1], p[2] );
      }
      seqIdx++;
    }
 
    beatIdx++;
    pastBeat = (beat >> 4);
  }
}

