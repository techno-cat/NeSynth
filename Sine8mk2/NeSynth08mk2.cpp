#include "NeSynth08mk2.h"

#define POLY_MAX 8

namespace {

struct {
  unsigned short offset;
  unsigned short indexHi;
  unsigned short indexLo;
} _bpmInfo;

struct OSC {
  unsigned char note;
  unsigned char gate;
  const char *pWave;
  unsigned long index;
  unsigned long inc;
} _osc[POLY_MAX];

unsigned char _beat;

/*
    // wave size : 256
    offset = freq * 256 * 0x00010000 / (16M / (64*8));
*/
const unsigned long noteOffset[14] = {
  0x00000000, //   0.0000,         0.00
  0x000E6AFC, //  1760.00,    944892.81
  0x000F4677, //  1864.66,   1001079.06
  0x00102EFE, //  1975.53,   1060606.31
  0x00112559, //  2093.00,   1123673.25
  0x00122A5A, //  2217.46,   1190490.34
  0x00133EE0, //  2349.32,   1261280.57
  0x001463D8, //  2489.02,   1336280.22
  0x00159A3B, //  2637.02,   1415739.58
  0x0016E313, //  2793.83,   1499923.83
  0x00183F79, //  2959.96,   1589113.95
  0x0019B097, //  3135.96,   1683607.58
  0x001B37A8, //  3322.44,   1783720.09
  0x001CD5F9, //  3520.00,   1889785.61
};

const char wavSine[128] = {
  0,  0,  1,  2,  3,  3,  4,  5,  6,  6,  7,  8,  8,  9, 10, 11,
 11, 12, 13, 13, 14, 15, 15, 16, 17, 17, 18, 19, 19, 20, 20, 21,
 21, 22, 22, 23, 23, 24, 24, 25, 25, 26, 26, 26, 27, 27, 28, 28,
 28, 28, 29, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
 31, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29, 29, 29, 28,
 28, 28, 28, 27, 27, 26, 26, 26, 25, 25, 24, 24, 23, 23, 22, 22,
 21, 21, 20, 20, 19, 19, 18, 17, 17, 16, 15, 15, 14, 13, 13, 12,
 11, 11, 10,  9,  8,  8,  7,  6,  6,  5,  4,  3,  3,  2,  1,  0,
};

} /* namespace */

short NeSynth08mk2::main(void) {
  volatile unsigned char i;
  short outVol;

  /*
   * if ( move 1/16 -> _beat++ )
   */
  _bpmInfo.indexLo += _bpmInfo.offset;
  if ( _bpmInfo.indexLo < _bpmInfo.offset ) {
    _bpmInfo.indexHi++;
  }
  
  if ( _bpmInfo.indexHi & 0x0010 ) {
    _bpmInfo.indexHi -= 0x0010;
    _beat++;

    for (i=0; i<POLY_MAX; i++) {
      if ( _osc[i].gate == (unsigned char)0 ) {
        _osc[i].note = (unsigned char)0;
      }
      else {
        _osc[i].gate--;
      }
    }

  }

  // Mix osc output
  outVol = 0;
  for (i=0; i<POLY_MAX; i++) {
    OSC *p = &(_osc[i]);
    if ( p->note != (unsigned char)0 ) {
      unsigned char idx;
      p->index += p->inc;
      idx = (unsigned char)( (p->index >> 16) & 0xFF );
#if(0)
      outVol += (idx < (unsigned char)128 ? -31 : 31); // pulse
      //return 15 - idx1; // saw
#else
      if ( (unsigned char)127 < idx ) {
        outVol -= (short)( p->pWave[idx-128] );
      }
      else {
        outVol += (short)( p->pWave[idx] );
      }
#endif
    }
  }

  return outVol;
}

void NeSynth08mk2::init(unsigned char bpm)
{
  { // Init osc 
    unsigned char i;
    for (i=0; i<POLY_MAX; i++) {
      _osc[i].note = 0;
      _osc[i].index = 0;
      _osc[i].pWave = wavSine;
    }
  }

  { // BPM Setting
    unsigned char i;
  
    // (128.0 / 60.0) * 0x01000000 / (16000000 / (64*8)) * 4;
    unsigned short wk = 0x11E4; // 128.0 << 2, 1145.3 * 4.0
    _bpmInfo.offset = 0;
    for (i=0; i<8; i++) {
      if ( bpm & 0x80 ) {
        _bpmInfo.offset += wk;
      }
      
      bpm <<= 1;
      wk >>= 1;
    }
    
    _bpmInfo.offset >>= 2;
    _bpmInfo.indexHi = _bpmInfo.indexLo = 0;
  }

  _beat = 0;
}

unsigned char NeSynth08mk2::beat(void) {
  return _beat;
}

void NeSynth08mk2::noteOn(unsigned char note, unsigned char gate)
{
  unsigned char i;

  // assign note
  for (i=0; i<POLY_MAX; i++) {
    OSC *p = &(_osc[i]);
    if ( p->note == (unsigned char)0 ) {
      p->note = note;
      p->gate = gate;
      p->inc = (noteOffset[note] >> 2); // note = 1 (A: 440Hz)
      break;
    }
  }
}
