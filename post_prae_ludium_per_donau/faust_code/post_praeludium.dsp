import("stdfaust.lib");

input = _ * ingroup((gain)) : ingroup(meter)
  with{
    ingroup(x) = hgroup("[01]INPUT", x);
    gain = vslider("[01]GAIN[unit:dB][midi:ctrl 1]", -96, -96, 12, 0.01) : ba.db2linear : si.smoo;
    meter(x) = attach(x, envelop(x) : vbargraph("[02]METER[unit:dB]", -96, +12));
    envelop = abs : max ~ -(6/ma.SR) : max(ba.db2linear(-96)) : ba.linear2db;
};

//////////////////Main (anplificazione trasparente)

amp_trasp = _ <: ch_1,ch_2,ch_3,ch_4
  with {
    ampgroup(x) = hgroup("[02]AMPLIFICAZIONE", x);
    ch1group(x) = vgroup("[01]CH1", x);
    ch2group(x) = vgroup("[01]CH2", x);
    ch3group(x) = vgroup("[01]CH3", x);
    ch4group(x) = vgroup("[01]CH4", x);
    g1group(x) = hgroup("[02]gain1", x);
    g2group(x) = hgroup("[02]gain2", x);
    g3group(x) = hgroup("[02]gain3", x);
    g4group(x) = hgroup("[02]gain4", x);
    meter1(x) = attach(x, an.amp_follower(0.150, x) : ba.linear2db : vbargraph("[02]METER1[unit:dB]", -96, +12));
    meter2(x) = attach(x, an.amp_follower(0.150, x) : ba.linear2db : vbargraph("[02]METER2[unit:dB]", -96, +12));
    meter3(x) = attach(x, an.amp_follower(0.150, x) : ba.linear2db :vbargraph("[02]METER3[unit:dB]", -96, +12));
    meter4(x) = attach(x, an.amp_follower(0.150, x) : ba.linear2db :vbargraph("[02]METER4[unit:dB]", -96, +12));

    maxdel = ma.SR;

    del1 = ch1group(pm.l2s(nentry("[03]METERS", 0,0,50,0.1)));
    fil1 = ch1group(nentry("[01]lpf_1[style:knob]", 20000,0,20000,1)) : si.smoo;
    gain1 = ch1group(g1group(_ * (vslider("[01]ch 1[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g1group(meter1));

    del2 = ch2group(pm.l2s(nentry("[03]METERS", 0,0,50,0.1)));
    fil2 = ch2group(nentry("[01]lpf_1[style:knob]", 20000,0,20000,1)) : si.smoo;
    gain2 = ch2group(g2group(_ * (vslider("[01]ch 2[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g2group(meter2));

    del3 = ch3group(pm.l2s(nentry("[03]METERS", 0,0,50,0.1)));
    fil3 = ch3group(nentry("[01]lpf_1[style:knob]", 20000,0,20000,1)) : si.smoo;
    gain3 = ch3group(g3group(_ * (vslider("[01]ch 3[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g3group(meter3));

    del4 = ch4group(pm.l2s(nentry("[03]METERS", 0,0,50,0.1)));
    fil4 = ch4group(nentry("[01]lpf_1[style:knob]", 20000,0,20000,1)) : si.smoo;
    gain4 = ch4group(g4group(_ * (vslider("[01]ch 4[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g4group(meter4));

        ch_1 = ampgroup(gain1 : de.delay(maxdel,del1) : fi.lowpass(1,fil1));
        ch_2 = ampgroup(gain2 : de.delay(maxdel,del2) : fi.lowpass(1,fil2));
        ch_3 = ampgroup(gain3 : de.delay(maxdel,del3) : fi.lowpass(1,fil3));
        ch_4 = ampgroup(gain4 : de.delay(maxdel,del4) : fi.lowpass(1,fil4));
    };

//////////////////PGM_1

pgm1 = _ * pgm1group(mute) : rev <: ch_1,ch_2,ch_3,ch_4
  with {
    pgm1group(x) = vgroup("pgm 1", x);
    ampgroup(x) = hgroup("[02]OUT", x);
    dlygroup(x) = hgroup("[01]dly", x);
    input_dy = _ * (nentry("in[style:knob]", 0,0,1,0.01) : si.smoo);
    output_dy = _ * (nentry("out[style:knob]", 0,0,1,0.01) : si.smoo);
    feedback = (nentry("feedback[style:knob]", 0,0,0.9,0.01) : si.smoo);

    g1group(x) = hgroup("[02]CH 1", x);
    g2group(x) = hgroup("[02]CH 2", x);
    g3group(x) = hgroup("[02]CH 3", x);
    g4group(x) = hgroup("[02]CH 4", x);
    meter1(x) = attach(x, envelop(x) : vbargraph("[02]METER1[unit:dB]", -96, +12));
    meter2(x) = attach(x, envelop(x) : vbargraph("[02]METER2[unit:dB]", -96, +12));
    meter3(x) = attach(x, envelop(x) : vbargraph("[02]METER3[unit:dB]", -96, +12));
    meter4(x) = attach(x, envelop(x) : vbargraph("[02]METER4[unit:dB]", -96, +12));

    envelop = abs : max ~ -(6/ma.SR) : max(ba.db2linear(-96)) : ba.linear2db;

    mute = (1 - checkbox("mute"));  //tasto mute

    gain1 = g1group(_ * (vslider("[01]ch 1[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g1group(meter1);

    gain2 = g2group(_ * (vslider("[01]ch 2[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g2group(meter2);

    gain3 = g3group(_ * (vslider("[01]ch 3[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g3group(meter3);

    gain4 = g4group(_ * (vslider("[01]ch 4[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g4group(meter4);

        ch_1 = pgm1group(delay_1 : ampgroup(gain1));
        ch_2 = pgm1group(delay_2 : ampgroup(gain2));
        ch_3 = pgm1group(delay_3 : ampgroup(gain3));
        ch_4 = pgm1group(delay_4 : ampgroup(gain4));

        delay_1 = dlygroup(input_dy : (+ : de.delay(5*ma.SR, 5*(ma.SR)))~*(feedback) : output_dy);
        delay_2 = dlygroup(input_dy : (+ : de.delay(7*ma.SR, 7*(ma.SR)))~*(feedback) : output_dy);
        delay_3 = dlygroup(input_dy : (+ : de.delay(10*ma.SR, 10*(ma.SR)))~*(feedback) : output_dy);
        delay_4 = dlygroup(input_dy : (+ : de.delay(15*ma.SR, 15*(ma.SR)))~*(feedback) : output_dy);

        rev = _ <: re.zita_rev_fdn(350, 2000, 30, 5, 20000) :> _ ;

    };

//////////////////// PGM2

pgm2 = _ * pgm2group(mute) : pgm2group(phaser) : pgm2group(halofon) <: ch_1,ch_2,ch_3,ch_4
    with{
    pgm2group(x) = vgroup("pgm 2", x);
    ampgroup(x) = hgroup("[02]OUT", x);
    efgroup(x) = hgroup("[01]effect", x);
    feedback = (nentry("feedback[style:knob]", 0,0,0.9,0.01) : si.smoo);

    g1group(x) = hgroup("[02]CH 1", x);
    g2group(x) = hgroup("[02]CH 2", x);
    g3group(x) = hgroup("[02]CH 3", x);
    g4group(x) = hgroup("[02]CH 4", x);
    meter1(x) = attach(x, envelop(x) : vbargraph("[02]METER1[unit:dB]", -96, +12));
    meter2(x) = attach(x, envelop(x) : vbargraph("[02]METER2[unit:dB]", -96, +12));
    meter3(x) = attach(x, envelop(x) : vbargraph("[02]METER3[unit:dB]", -96, +12));
    meter4(x) = attach(x, envelop(x) : vbargraph("[02]METER4[unit:dB]", -96, +12));

    envelop = abs : max ~ -(6/ma.SR) : max(ba.db2linear(-96)) : ba.linear2db;

    mute = (1 - checkbox("[5]mute"));  //tasto mute

    gain1 = g1group(_ * (vslider("[01]ch 1[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g1group(meter1);

    gain2 = g2group(_ * (vslider("[01]ch 2[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g2group(meter2);

    gain3 = g3group(_ * (vslider("[01]ch 3[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g3group(meter3);

    gain4 = g4group(_ * (vslider("[01]ch 4[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g4group(meter4);

        ch_1 = pgm2group(ampgroup(gain1));
        ch_2 = pgm2group(ampgroup(gain2));
        ch_3 = pgm2group(ampgroup(gain3));
        ch_4 = pgm2group(ampgroup(gain4));


phaser = _ : efgroup(phasing)
    with{
        phgroup(x) = hgroup("Phaser", x);
        frq_lfo = phgroup(nentry("speed[style:knob]", 0,0,5,0.001) : si.smoo);
        lfo = os.osc(frq_lfo);
        feedback_ph = phgroup(nentry("feedback[style:knob]", 0,0,0.9,0.01) : si.smoo);
        phasing = _ <:  ((+ : fi.allpassn(1,lfo) : fi.allpassn(1,lfo) : fi.allpassn(1,lfo) : fi.allpassn(1,lfo)) ~*(feedback_ph)) : _ ;
    };

halofon = efgroup(doublehalofone) :> _,_,_,_
    with{
        speed = nentry("speed halofon[style:knob]", 0, 0, 0.5, 0.001);
        rotation_1 = os.osc(speed);
        rotation_2 = os.osccos(speed);
        halofon_1 = sp.spat(4, rotation_1, 1);
        halofon_2 = sp.spat(4, rotation_2, 1);
        doublehalofone = _ <: halofon_1, halofon_2;
    };

};

///////////////////PGM3

pgm3 = _ * pgm3group(mute) : rev : ch_1,ch_2
    with{
    pgm3group(x) = vgroup("pgm 3", x);
    ampgroup(x) = hgroup("[02]OUT", x);
    feedback = (nentry("feedback[style:knob]", 0,0,0.9,0.01) : si.smoo);

    g1group(x) = hgroup("[02]CH 1", x);
    g2group(x) = hgroup("[02]CH 2", x);

    meter1(x) = attach(x, envelop(x) : vbargraph("[02]METER1[unit:dB]", -96, +12));
    meter2(x) = attach(x, envelop(x) : vbargraph("[02]METER2[unit:dB]", -96, +12));

    envelop = abs : max ~ -(6/ma.SR) : max(ba.db2linear(-96)) : ba.linear2db;

    mute = (1 - checkbox("[5]mute"));  //tasto mute

    gain1 = g1group(_ * (vslider("[01]ch 1[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g1group(meter1);

    gain2 = g2group(_ * (vslider("[01]ch 2[unit:dB]", -96, -96, 12, 0.1)
     : ba.db2linear : si.smoo)): g2group(meter2);

    rev = _ <: re.zita_rev_fdn(350, 2000, 30, 30, 20000) :> _,_;

        ch_1 = pgm3group(ampgroup(gain1));
        ch_2 = pgm3group(ampgroup(gain2));

    };

    /////////////////// PGM4

    pgm4 = _ * pgm4group(mute) : lpf : rev : ch_3,ch_4
        with{
        pgm4group(x) = vgroup("pgm 4", x);
        ampgroup(x) = hgroup("[02]OUT", x);
        feedback = (nentry("feedback[style:knob]", 0,0,0.9,0.01) : si.smoo);

        g1group(x) = hgroup("[02]CH 3", x);
        g2group(x) = hgroup("[02]CH 4", x);

        meter1(x) = attach(x, envelop(x) : vbargraph("[02]METER1[unit:dB]", -96, +12));
        meter2(x) = attach(x, envelop(x) : vbargraph("[02]METER2[unit:dB]", -96, +12));

        envelop = abs : max ~ -(6/ma.SR) : max(ba.db2linear(-96)) : ba.linear2db;

        mute = (1 - checkbox("[5]mute"));  //tasto mute

        gain1 = g1group(_ * (vslider("[01]ch 1[unit:dB]", -96, -96, 12, 0.1)
         : ba.db2linear : si.smoo)): g1group(meter1);

        gain2 = g2group(_ * (vslider("[01]ch 2[unit:dB]", -96, -96, 12, 0.1)
         : ba.db2linear : si.smoo)): g2group(meter2);

        rev = _ <: re.zita_rev_fdn(350, 2000, 10, 10, 20000) :> _,_;

        lpf = fi.lowpass(4,566);

            ch_3 = pgm4group(ampgroup(gain1));
            ch_4 = pgm4group(ampgroup(gain2));

        };

process = hgroup("post-prae-ludium per Donau", input <: amp_trasp, pgm1, pgm2, pgm3, pgm4) :> _,_,_,_;


//tgroup("PANELS", microphones :> hgroup("[03] MAIN", input : main)
