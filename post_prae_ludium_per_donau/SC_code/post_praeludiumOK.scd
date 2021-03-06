s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels = 1;
s.options.memSize_(65536 * 4);
s.reboot;

i = {SoundIn.ar}; //variabile globale "microfono in ingresso"

//i = {WhiteNoise.ar};

// Amp_Trasp

(
~amptrasp = {
	arg dly1, dly2, dly3, dly4,
	cf1, cf2, cf3, cf4,
	amp1, amp2, amp3, amp4;

	var ampt;
	var lp1, lp2, lp3, lp4;
	var delay1, delay2, delay3, delay4;
	var cut1, cut2, cut3, cut4;

z = {   // coefficenti filtro onepole
	arg h;
	a = s.sampleRate;
	b = 2 - (cos(2*pi*(h/a)));
	d = b - sqrt((b*b)-1.0);
};

cut1 = z.value(cf1);
cut2 = z.value(cf2);
cut3 = z.value(cf3);
cut4 = z.value(cf4);

delay1 = {DelayL.ar(i, 1, dly1, mul:(1-cut1))};	// delay ch 1
delay2 = {DelayL.ar(i, 1, dly2, mul:(1-cut2))};	// delay ch 2
delay3 = {DelayL.ar(i, 1, dly3, mul:(1-cut3))};	// delay ch 3
delay4 = {DelayL.ar(i, 1, dly4, mul:(1-cut4))};	// delay ch 4

lp1 = {OnePole.ar(delay1, cut1)};  // lpf ch 1
lp2 = {OnePole.ar(delay2, cut2)};  // lpf ch 2
lp3 = {OnePole.ar(delay3, cut3)};  // lpf ch 3
lp4 = {OnePole.ar(delay4, cut4)};  // lpf ch 4

//ampt = {Out.ar(~bus1,[lp1*amp1,lp2*amp2,lp3*amp3,lp4*amp4])};

[lp1*amp1,lp2*amp2,lp3*amp3,lp4*amp4];

//~bus1.index;

}.scope;
)

//PGM1

(
{
var delay1, delay2, delay3, delay4;
var in;

in = JPverb.ar(i, 5);  //Riverbero input

delay1 = DelayL.ar(in, 5, 5);	// delay ch 1
delay2 = DelayL.ar(in, 7, 7);   // delay ch 2
delay3 = DelayL.ar(in, 10, 10); // delay ch 3
delay4 = DelayL.ar(in, 15, 15); // delay ch 4

[delay1, delay2, delay3, delay4];

}.scope;
)

//PGM2

(
{
var halafon;

r = {SinOsc.ar(0.3).range(0.1, 1)};

u = LocalIn.ar(1);

p = {AllpassL.ar((i + (u * 1)), 1, r)};

h = {AllpassL.ar(p, 1, r)};

a = {AllpassL.ar(h, 1, r)};

s = {AllpassL.ar(a, 1, r)};

l = LocalOut.ar(s);

	halafon = PanAz.ar(4, (i + s)*0.6 , LFSaw.kr(0.1));

}.scope;
{
var halafon;

	halafon = PanAz.ar(4, (i + s)*0.6, LFSaw.kr(-0.01, 0.5));

}.scope;
)


//PGM3
(
{
var in;
in = JPverb.ar(i, 30);  //Riverbero input

[in, in];

}.scope;
)

//PGM4
(
{
var in;
var lpf;

in = JPverb.ar(i, 10);  //Riverbero input
lpf = LPF.ar(in, 566);  // lpf ch 1

[0, 0, in, in];

}.scope;
)

(
/* accoppiamento di view e controller */
var window, screen ; // dichiarazione delle variabili usate
// una finestra contenitore
var slider, slider2, slider3, slider4;
var knob, knob2, knob3, knob4;
var number, number2, number3, number4;

window = Window.new("Amp_trasp", Rect.new(300,800, 300, 300)) ;
// una manopola nella finestra, range: [0,1]
slider  = Slider.new(window, Rect(50, 100, 40, 100));
slider2 = Slider.new(window, Rect(100, 100, 40, 100));
slider3 = Slider.new(window, Rect(150, 100, 40, 100));
slider4 = Slider.new(window, Rect(200, 100, 40, 100));
knob  = Knob.new(window, Rect(45, 50, 50, 40)) ;
knob2 = Knob.new(window, Rect(95, 50, 50, 40)) ;
knob3 = Knob.new(window, Rect(145, 50, 50, 40)) ;
knob4 = Knob.new(window, Rect(195, 50, 50, 40)) ;
number = NumberBox.new(window, Rect(50, 210, 40, 20)) ;
number2 = NumberBox.new(window, Rect(100, 210, 40, 20)) ;
number3 = NumberBox.new(window, Rect(150, 210, 40, 20)) ;
number4 = NumberBox.new(window, Rect(200, 210, 40, 20)) ;
slider.value = 0 ;
slider2.value = 0 ;
slider3.value = 0 ;
slider4.value = 0 ;
knob.value = 0 ;
knob2.value = 0 ;
knob3.value = 0 ;
knob4.value = 0 ;
number.value = 0 ;
number2.value = 0 ;
number3.value = 0 ;
number4.value = 0 ;

knob.action_({ arg me;
	a = me.value;
	~amptrasp.set(\cf1, a.linlin(0, 1, 20, 20000));
});

knob2.action_({ arg me;
	a = me.value;
	~amptrasp.set(\cf2, a.linlin(0, 1, 20, 20000));
});

knob3.action_({ arg me;
	a = me.value;
	~amptrasp.set(\cf3, a.linlin(0, 1, 20, 20000));
});

knob4.action_({ arg me;
	a = me.value;
	~amptrasp.set(\cf4, a.linlin(0, 1, 20, 20000));
});

slider.action_({ arg me;
	a = me.value;
	~amptrasp.set(\amp1, a);
});

slider2.action_({ arg me;
	a = me.value;
	~amptrasp.set(\amp2, a);
});

slider3.action_({ arg me;
	a = me.value;
	~amptrasp.set(\amp3, a);
});

slider4.action_({ arg me;
	a = me.value;
	~amptrasp.set(\amp4, a);
});

number.action_({ arg me;
	a = me.value;
	~amptrasp.set(\dly1, a);
});

number2.action_({ arg me;
	a = me.value;
	~amptrasp.set(\dly2, a);
});
number3.action_({ arg me;
	a = me.value;
	~amptrasp.set(\dly3, a);
});
number4.action_({ arg me;
	a = me.value;
	~amptrasp.set(\dly4, a);
});
// non dimenticarmi
window.front ;
window.alwaysOnTop_(true);

)