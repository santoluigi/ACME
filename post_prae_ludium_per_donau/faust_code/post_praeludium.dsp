import("stdfaust.lib");

input = _ * (vslider("in[unit:dB]", -96, -96, 12, 0.01) : ba.db2linear : si.smoo);

master = (vslider("master[unit:dB]", -96, -96, 12, 0.01) : ba.db2linear : si.smoo);

output_1 = _ * master;

output_2 = _ * master;

output_3 = _ * master;

output_4 = _ * master;

out = hgroup("[04]out", (output_1 : meter_1), (output_2: meter_2), (output_3:meter_3), (output_4:meter_4));


//////////////////Main (anplificazione trasparente)

amp_trasp = _ <: hgroup("[08]main", ch_1,ch_2,ch_3,ch_4)
    with {
        ch_1 = de.delay(ma.SR,vgroup("ch_1", (nentry("dist_1", 0,0,50,0.1)/340)*ma.SR) : fi.lowpass(1,(nentry("lpf_1[style:knob]", 20000,0,20000,1)):si.smoo));
        ch_2 = de.delay(ma.SR,vgroup("ch_2", (nentry("dist_2", 0,0,50,0.1)/340)*ma.SR): fi.lowpass(1,(nentry("lpf_2[style:knob]", 20000,0,20000,1)):si.smoo));
        ch_3 = de.delay(ma.SR,vgroup("ch_3", (nentry("dist_3", 0,0,50,0.1)/340)*ma.SR) : fi.lowpass(1,(nentry("lpf_3[style:knob]", 20000,0,20000,1)):si.smoo));
        ch_4 = de.delay(ma.SR,vgroup("ch_4", (nentry("dist_4", 0,0,50,0.1)/340)*ma.SR):  fi.lowpass(1,(nentry("lpf_4[style:knob]", 20000,0,20000,1)):si.smoo));
    };

main = amp_trasp;

//ch_1 = de.delay(ma.SR,(nentry("dist_1", 0,0,50,0.1)/340)*ma.SR) : fi.lowpass(1,(nentry("lpf_1[style:knob]", 20000,0,20000,1)):si.smoo);
//ch_2 = de.delay(ma.SR,(nentry("dist_2", 0,0,50,0.1)/340)*ma.SR):  fi.lowpass(1,(nentry("lpf_2[style:knob]", 20000,0,20000,1)):si.smoo);
//ch_3 = de.delay(ma.SR,(nentry("dist_3", 0,0,50,0.1)/340)*ma.SR) : fi.lowpass(1,(nentry("lpf_3[style:knob]", 20000,0,20000,1)):si.smoo);
//ch_4 = de.delay(ma.SR,(nentry("dist_4", 0,0,50,0.1)/340)*ma.SR): fi.lowpass(1,(nentry("lpf_4[style:knob]", 20000,0,20000,1)):si.smoo);
//main = _ <: ch_1,ch_2,ch_3,ch_4;

//////////////////PGM1

input_dy = _ * (nentry("in[style:knob]", 0,0,1,0.01) : si.smoo);

output_dy = _ * (nentry("out[style:knob]", 0,0,1,0.01) : si.smoo);

feedback = (nentry("feedback[style:knob]", 0,0,0.9,0.01) : si.smoo);

delay_1 = input_dy : (+ : de.delay(5*ma.SR, 5*(ma.SR)))~*(feedback) : output_dy;

delay_2 = input_dy : (+ : de.delay(7*ma.SR, 7*(ma.SR)))~*(feedback) : output_dy;

delay_3 = input_dy : (+ : de.delay(10*ma.SR, 10*(ma.SR)))~*(feedback) : output_dy;

delay_4 = input_dy : (+ : de.delay(15*ma.SR, 15*(ma.SR)))~*(feedback) : output_dy;

pgm1 = _ <: hgroup("delay",delay_1, delay_2, delay_3, delay_4);

////////////////// PGM2

frq_lfo = (nentry("frq_lfo[style:knob]", 0,0,5,0.001) : si.smoo);

lfo = os.osc(frq_lfo);

feedback_ph = (nentry("feedback[style:knob]", 0,0,0.9,0.01) : si.smoo);

phaser = _ <:  ((+ : fi.allpassn(1,lfo) : fi.allpassn(1,lfo) : fi.allpassn(1,lfo) : fi.allpassn(1,lfo)) ~*(feedback_ph)) : _ ;

rotation_1 = os.osc(0.01);

rotation_2 = os.osccos(0.01);

halofon_1 = sp.spat(4, rotation_1, 1);
halofon_2 = sp.spat(4, rotation_2, 1);

pgm2 = hgroup("[03]phaser", _ : phaser <: halofon_1, halofon_2);

///////////////////PGM3

pgm3 = _ <: re.zita_rev_fdn(350, 2000, 30, 30, 20000) :> _,_;

/////////////////// PGM4

pgm4 = _ : fi.lowpass(4,566) <: re.zita_rev_fdn(350, 2000, 10, 10, 20000) :> _,_;


process = hgroup("post_praeludium", hgroup("[01]in", (input : meter_1)) <: (vgroup("", main, hgroup("", vgroup("[01]effects", pgm1, pgm2), pgm3, pgm4) :> out)));

envelop = abs : max ~ -(6/ma.SR) : max(ba.db2linear(-96)) : ba.linear2db;

meter_1(x) = attach(x, envelop(x) : vbargraph("[02]d1[unit:dB]", -96, +12));
meter_2(x) = attach(x, envelop(x) : vbargraph("[02]d2[unit:dB]", -96, +12));
meter_3(x) = attach(x, envelop(x) : vbargraph("[02]d3[unit:dB]", -96, +12));
meter_4(x) = attach(x, envelop(x) : vbargraph("[02]d4[unit:dB]", -96, +12));
