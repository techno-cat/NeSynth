#ifndef NESYNTH08MK2_h
#define NESYNTH08MK2_h

class NeSynth08mk2 {
  public:
    static unsigned char beat(void);
    static void init(unsigned char bpm);
    static short main(void);
    static void noteOn(unsigned char note, unsigned char gate);
};

#endif /* NESYNTH08MK2_h */
