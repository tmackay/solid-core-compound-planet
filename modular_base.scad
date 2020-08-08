// OpenSCAD Planetary Elbow Joint
// (c) 2020, tmackay
//
// Licensed under a Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) license, http://creativecommons.org/licenses/by-sa/4.0.
include <SCCPv1.scad>;

// Use for command line option '-Dgen=n', overrides 'part'
// 0-7+ - generate parts individually in assembled positions. Combine with MeshLab.
// 0 box
// 1 ring gears and jaws
// 2 sun gear and knob
// 3+ planet gears
gen=undef;

// Overall scale (to avoid small numbers, internal faces or non-manifold edges)
scl = 1000;

// Number of planet gears in inner circle
planets = 8; //[3:1:21]

// Layer height (for ring horizontal split)
layer_h_ = 0.2; //[0:0.01:1]
// Height of planetary layers (layer_h will be subtracted from gears>0)
gh_ = [12.4];
// Number of teeth in planet gears
pt = [5];
// For additional gear ratios we can add or subtract extra teeth (in multiples of planets) from rings but the profile will be further from ideal
of = [0];
// number of teeth to twist across
nt = [1];
// Sun gear multiplier
sgm = 2; //[1:1:5]
// Outer diameter
outer_d_ = 55.0; //[30:0.2:300]
// Ring wall thickness (relative pitch radius)
wall_ = 2.5; //[0:0.1:20]
// Shaft diameter
shaft_d_ = 0; //[0:0.1:25]
// Outside Gear depth ratio
depth_ratio=0.25; //[0:0.05:1]
// Inside Gear depth ratio
depth_ratio2=0.5; //[0:0.05:1]
// Gear clearance
tol_=0.2; //[0:0.01:0.5]
// pressure angle
P=30; //[30:60]
// Bearing height
bearing_h_ = 1;  //[0:0.01:5]
// Chamfer exposed gears, top - watch fingers
ChamferGearsTop = 0;				// [1:No, 0.5:Yes, 0:Half]
// Chamfer exposed gears, bottom - help with elephant's foot/tolerance
ChamferGearsBottom = 0;				// [1:No, 0.5:Yes, 0:Half]
//Include a knob
Knob = 0;				// [1:Yes , 0:No]
//Diameter of the knob, in mm
KnobDiameter_ = 15.0;			//[10:0.5:100]
//Thickness of knob, including the stem, in mm:
KnobTotalHeight_ = 10;			//[10:thin,15:normal,30:thick, 40:very thick]
//Number of points on the knob
FingerPoints = 5;   			//[3,4,5,6,7,8,9,10]
//Diameter of finger holes
FingerHoleDiameter_ = 6; //[5:0.5:50]
TaperFingerPoints = true;			// true

// Tolerances for geometry connections.
AT_=1/64;
// Curve resolution settings, minimum angle
$fa = 5/1;
// Curve resolution settings, minimum size
$fs = 1/1;
// Curve resolution settings, number of segments
$fn=96;

gh = scl*gh_;
outer_d = outer_d_*scl;
AT=AT_*scl;
ST=AT*2;
TT=AT/2;

arm_size_ = 25;
arm_size = scl*arm_size_;
arm_width_ = 10;
arm_width = scl*arm_width_;

tol = scl*tol_;
wall = scl*wall_;

core_h=22.6*scl;

difference(){
    gearbox(
        gen = gen, scl = scl, planets = planets, layer_h_ = layer_h_, gh_ = gh_, pt = pt, of = of, nt = nt,
        sgm = sgm, outer_d_ = outer_d_, wall_ = 2*wall_, shaft_d_ = shaft_d_, depth_ratio = depth_ratio,
        depth_ratio2 = depth_ratio2, tol_ = tol_, P = P, bearing_h_ = bearing_h_, ChamferGearsTop = ChamferGearsTop,
        ChamferGearsBottom = ChamferGearsBottom, Knob = Knob, KnobDiameter_ = KnobDiameter_,
        KnobTotalHeight_ = KnobTotalHeight_, FingerPoints = FingerPoints, FingerHoleDiameter_ = FingerHoleDiameter_,
        TaperFingerPoints = TaperFingerPoints, AT_ = AT_, $fa = $fa, $fs = $fs, $fn = $fn
    );

    cube([core_h/sqrt(2)-2*wall,core_h/sqrt(2)-2*wall,2*gh[0]+ST],center=true);
}

    //legs
    intersection(){
        for(i=[0:3])rotate([0,0,i*90])
            cube([2*arm_width,2*outer_d,outer_d],center=true);
        rotate_extrude(convexity = 10)
            polygon([[outer_d/2-AT,0],[outer_d/2-AT,gh[0]],[outer_d-gh[0],outer_d/2],[outer_d-arm_width/2,outer_d/2],[outer_d-arm_width/2,outer_d/2-arm_width/2]]);
    }