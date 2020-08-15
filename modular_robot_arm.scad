// OpenSCAD Modular Toy Robot Arm
// (c) 2020, tmackay
//
// Licensed under a Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) license, http://creativecommons.org/licenses/by-sa/4.0.
include <SCCPv1.scad>; // https://github.com/tmackay/solid-core-compound-planet

// Which one would you like to see?
part = "wrist"; // [elbow:Elbow Joint,elbows:Double Elbow,triplet:Triple Elbow,joiner:Joiner,base:Rotating Base,grip:Grip,wrist:Wrist Grip,rotator:Rotator Joint,rotator2:Alternate Rotator]

// Use for command line option '-Dgen=n', overrides 'part'
// 0-7+ - generate parts individually in assembled positions. Combine with MeshLab.
// 0 box
// 1 ring gears and jaws
// 2 sun gear and knob
// 3+ planet gears
gen=undef;

// Overall scale (to avoid small numbers, internal faces or non-manifold edges)
scl = 1000;

// Number of planet gears in gearbox
planets = 5; //[3:1:21]
// Number of planet gears in base bearing
base_planets = 8; //[3:1:21]

// Layer height (for ring horizontal split)
layer_h_ = 0.2; //[0:0.01:1]
// Height of planetary layers (layer_h will be subtracted from gears>0)
gh_ = [7.4, 7.6, 7.6];
// Number of teeth in planet gears
pt = [5, 4, 5];
// For additional gear ratios we can add or subtract extra teeth (in multiples of planets) from rings but the profile will be further from ideal
of = [0, 0, 0];
// number of teeth to twist across
nt = [1, 1, 1];
// Sun gear multiplier
sgm = 1; //[1:1:5]
// Sun gear multiplier (base bearing)
base_sgm = 2; //[1:1:5]
// Outer diameter
outer_d_ = 25.0; //[30:0.2:300]
// Base bearing diameter
base_d_ = 55.0; //[30:0.2:300]
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
Knob = 1;				// [1:Yes , 0:No]
//Diameter of the knob, in mm
KnobDiameter_ = 15.0;			//[10:0.5:100]
//Thickness of knob, including the stem, in mm:
KnobTotalHeight_ = 10;			//[10:thin,15:normal,30:thick, 40:very thick]
//Number of points on the knob
FingerPoints = 5;   			//[3,4,5,6,7,8,9,10]
//Diameter of finger holes
FingerHoleDiameter_ = 6; //[5:0.5:50]
TaperFingerPoints = true;			// true
// Number of legs
legs = 4; //[3,4,5,6]

// Tolerances for geometry connections.
AT_=1/64;
// Curve resolution settings, minimum angle
$fa = 5/1;
// Curve resolution settings, minimum size
$fs = 1/1;
// Curve resolution settings, number of segments
$fn=96;

// Number of sets of jaws
jaws = 1; //[0:1:6]
// Jaw Initial Rotation (from closed)
jaw_rot = 90; //[0:180]
// Jaw Size
jaw_size_ = 22; //[0:100]
jaw_size = scl*jaw_size_;
arm_size_ = 25;
arm_size = scl*arm_size_;
arm_width_ = 10;
arm_width = scl*arm_width_;
// Jaw Offset
jaw_offset_ = 3; //[0:0.1:100]
jaw_offset = scl*jaw_offset_;
// Jaw Taper Angle (outside edge)
jaw_angle = 9; //[0:60]
// Dimple radius
dim_r_ = 1.1; //[0:0.1:2]
dim_r = scl*dim_r_;
// Dimple depth ratio
dim_d = 0.5; //[0:0.1:1]

// common calculated variables
modules = len(gh_);
core_h = scl*addl(gh_,len(gh_));
base_d = base_d_*scl;
wall = scl*wall_;
bearing_h = scl*bearing_h_;
gh = scl*gh_;
outer_d = outer_d_*scl;
layer_h = scl*layer_h_;
tol = scl*tol_;
AT=AT_*scl;
ST=AT*2;
TT=AT/2;

if (part=="elbow")
    elbow(arm_size=arm_size,jaws=0,jaw_rot=jaw_rot);

if (part=="elbows"){
    elbow(arm_size=arm_size,jaws=0,jaw_rot=jaw_rot,out=false);
    translate([0,-outer_d-2*arm_size,0])mirror([1,1,0])mirror([1,0,0])
        elbow(arm_size=arm_size,jaws=0,jaw_rot=jaw_rot,in=false);
}

if (part=="triplet"){
    elbow(arm_size=arm_size,jaws=0,jaw_rot=jaw_rot,out=false);
    translate([0,-outer_d-2*arm_size,0])mirror([1,1,0])mirror([1,0,0])
        elbow(arm_size=arm_size,jaws=0,jaw_rot=jaw_rot,in=false,out=false);
    translate([outer_d+2*arm_size,-outer_d-2*arm_size,0])mirror([0,1,0])mirror([1,0,0])
        elbow(arm_size=arm_size,jaws=0,jaw_rot=jaw_rot,in=false);}

if (part=="rotator")
    rotator();

if (part=="rotator2")
    rotator2();

if (part=="joiner")
    joiner();

if (part=="base")
    base();

if (part=="grip")
    elbow(arm_size=arm_size,jaw_rot=0);

if (part=="wrist"){
    elbow(arm_size=arm_size,jaws=0,jaw_rot=jaw_rot,out=false);
    translate([0,-outer_d-arm_size-2*tol,0])mirror([1,1,0])mirror([1,0,0])
        elbow(arm_size=arm_size,jaw_rot=0,in=false);
}

module elbow(in=true,out=true) {
    dim_s = core_h/(floor(core_h/dim_r/3)+1);
    for(k=[0:1])rotate([0,0,-jaw_rot*k])mirror([0,k,0])difference(){
        union(){
            if(!k||!jaws)translate([0,-arm_width/2,0])
                cube([outer_d/2+(!k&&in||k&&out&&!jaws?arm_size/4:arm_size),arm_width,core_h]);
            if(!k&&in||k&&out&&!jaws)difference(){
                hull(){
                    translate([outer_d/2+arm_size/4,-arm_width/2,0])
                        cube([arm_size/4,arm_width,core_h]);
                    translate([arm_size,0,0])rotate([45,0,0])
                        cube([arm_size/2,core_h/sqrt(2),core_h/sqrt(2)]);
                }
                translate([arm_size,0,wall*sqrt(2)])rotate([45,0,0])
                    cube([arm_size/2+AT,core_h/sqrt(2)-2*wall,core_h/sqrt(2)-2*wall]);
            }
            if(jaws){
                for(i=[1-(1-k)/2:jaw_size/dim_s-1],j=[1-(1-k)/2:core_h/dim_s-1/2])
                    translate([i*dim_s-outer_d/2-jaw_size,jaw_offset,j*dim_s])
                        scale([1,dim_d,1])rotate([90,0,0])sphere(r=dim_r,$fn=6);
                mirror([1,0,0])intersection(){
                    translate([0,jaw_offset,0])
                        cube([outer_d/2+jaw_size,outer_d/2-jaw_offset,core_h]);
                    rotate([0,0,-jaw_angle])
                        cube([outer_d/2+jaw_size,outer_d/2,core_h]);
                }
            }
        }
        //for (i=[0:modules-1])translate([0,0,addl(gh,i)+(!i||i%2?0:bearing_h-layer_h)]) // TODO: repetition
        //    cylinder(r=outer_d/2+(i%2?-2*tol:2*tol),h=gh[i]+(i%2?bearing_h-2*layer_h:-bearing_h+2*layer_h));
        translate([0,0,addl(gh,0)-AT])
            cylinder(r=outer_d/2+2*(1-2*k)*tol,h=gh[0]-bearing_h+2*layer_h+AT);
        translate([0,0,addl(gh,1)-bearing_h+layer_h])
            cylinder(r=outer_d/2-2*(1-2*k)*tol,h=gh[1]+2*bearing_h-layer_h);
        translate([0,0,addl(gh,2)+bearing_h-layer_h])
            cylinder(r=outer_d/2+2*(1-2*k)*tol,h=gh[2]+AT);
        if(jaws)for(i=[1-k/2:jaw_size/dim_s-1],j=[1-k/2:core_h/dim_s-1/2])
            translate([i*dim_s-outer_d/2-jaw_size,jaw_offset,j*dim_s])
                scale([1,dim_d,1])rotate([90,0,0])sphere(r=dim_r,$fn=6);
    }
    gearbox(
        gen = gen, scl = scl, planets = planets, layer_h_ = layer_h_, gh_ = gh_, pt = pt, of = of, nt = nt,
        sgm = sgm, outer_d_ = outer_d_, wall_ = wall_, shaft_d_ = shaft_d_, depth_ratio = depth_ratio,
        depth_ratio2 = depth_ratio2, tol_ = tol_, P = P, bearing_h_ = bearing_h_, ChamferGearsTop = ChamferGearsTop,
        ChamferGearsBottom = ChamferGearsBottom, Knob = Knob, KnobDiameter_ = KnobDiameter_,
        KnobTotalHeight_ = KnobTotalHeight_, FingerPoints = FingerPoints, FingerHoleDiameter_ = FingerHoleDiameter_,
        TaperFingerPoints = TaperFingerPoints, AT_ = AT_, $fa = $fa, $fs = $fs, $fn = $fn
    );
}

module rotator(){
    for(k=[0:1])rotate([0,0,-jaw_rot*k])mirror([0,k,0])difference(){
        translate([0,-arm_width/2,0])
            cube([outer_d/2+(k?1.5*wall:arm_size/4),arm_width,core_h]);
        //for (i=[0:modules-1])translate([0,0,addl(gh,i)+(!i||i%2?0:bearing_h-layer_h)])
        //    cylinder(r=outer_d/2+(i%2?-2*tol:2*tol),h=gh[i]+(i%2?bearing_h-2*layer_h:-bearing_h+2*layer_h));
        translate([0,0,addl(gh,0)-AT])
            cylinder(r=outer_d/2+2*(1-2*k)*tol,h=gh[0]-bearing_h+2*layer_h+AT);
        translate([0,0,addl(gh,1)-bearing_h+layer_h])
            cylinder(r=outer_d/2-2*(1-2*k)*tol,h=gh[1]+2*bearing_h-layer_h);
        translate([0,0,addl(gh,2)+bearing_h-layer_h])
            cylinder(r=outer_d/2+2*(1-2*k)*tol,h=gh[2]+AT);
    }
    difference(){
        hull(){
            translate([outer_d/2+arm_size/4,-arm_width/2,0])
                cube([arm_size/4,arm_width,core_h]);
            translate([arm_size,0,0])rotate([45,0,0])
                cube([arm_size/2,core_h/sqrt(2),core_h/sqrt(2)]);
        }
        translate([arm_size,0,wall*sqrt(2)])rotate([45,0,0])
            cube([arm_size/2+AT,core_h/sqrt(2)-2*wall,core_h/sqrt(2)-2*wall]);
    }
    mirror([0,0,1])difference(){
        hull(){
            cylinder(d=outer_d,h=3*layer_h);
            translate([0,0,3*layer_h+arm_size/4])rotate([0,0,45])
                cube([core_h/sqrt(2),core_h/sqrt(2),arm_size/2],center=true);
            rotate([0,0,-jaw_rot])mirror([0,1,0])
                translate([0,-arm_width/2,0])
                    cube([outer_d/2+1.5*wall,arm_width,3*layer_h]);
        }
        translate([0,0,3*layer_h+arm_size/4])rotate([0,0,45])
            cube([core_h/sqrt(2)-2*wall,core_h/sqrt(2)-2*wall,arm_size/2+AT],center=true);
        translate([0,0,-AT])cylinder(d=outer_d-2*wall,h=layer_h+AT);
    }
    gearbox(
        gen = gen, scl = scl, planets = planets, layer_h_ = layer_h_, gh_ = gh_, pt = pt, of = of, nt = nt,
        sgm = sgm, outer_d_ = outer_d_, wall_ = wall_, shaft_d_ = shaft_d_, depth_ratio = depth_ratio,
        depth_ratio2 = depth_ratio2, tol_ = tol_, P = P, bearing_h_ = bearing_h_, ChamferGearsTop = ChamferGearsTop,
        ChamferGearsBottom = ChamferGearsBottom, Knob = Knob, KnobDiameter_ = KnobDiameter_,
        KnobTotalHeight_ = KnobTotalHeight_, FingerPoints = FingerPoints, FingerHoleDiameter_ = FingerHoleDiameter_,
        TaperFingerPoints = TaperFingerPoints, AT_ = AT_, $fa = $fa, $fs = $fs, $fn = $fn
    );         
}

module rotator2(){
    for(k=[0:1])rotate([0,0,-jaw_rot*k])mirror([0,k,0])difference(){
        union(){
            translate([0,-arm_width/2,0])
                cube([outer_d/2+wall,arm_width,core_h]);
            hull(){
                translate([outer_d/2+wall,-arm_width/2,0])
                    cube([wall/2,arm_width,core_h]);
                translate([outer_d/2+2*tol,0,k?core_h-arm_size/2:0])mirror([1,0,-1])rotate([45,0,0])
                    cube([arm_size/2,core_h/sqrt(2),core_h/sqrt(2)]);
            }
        }
        //for (i=[0:modules-1])translate([0,0,addl(gh,i)+(!i||i%2?0:bearing_h-layer_h)])
        //    cylinder(r=outer_d/2+(i%2?-2*tol:2*tol),h=gh[i]+(i%2?bearing_h-2*layer_h:-bearing_h+2*layer_h));
        translate([0,0,addl(gh,0)-AT])
            cylinder(r=outer_d/2+2*(1-2*k)*tol,h=gh[0]-bearing_h+2*layer_h+AT);
        translate([0,0,addl(gh,1)-bearing_h+layer_h])
            cylinder(r=outer_d/2-2*(1-2*k)*tol,h=gh[1]+2*bearing_h-layer_h);
        translate([0,0,addl(gh,2)+bearing_h-layer_h])
            cylinder(r=outer_d/2+2*(1-2*k)*tol,h=gh[2]+AT);
        translate([outer_d/2+2*tol,0,k?core_h-arm_size/2:-AT])mirror([1,0,-1])
            translate([0,0,wall*sqrt(2)])rotate([45,0,0])
                cube([arm_size/2+AT,core_h/sqrt(2)-2*wall,core_h/sqrt(2)-2*wall]);
    }    
    gearbox(
        gen = gen, scl = scl, planets = planets, layer_h_ = layer_h_, gh_ = gh_, pt = pt, of = of, nt = nt,
        sgm = sgm, outer_d_ = outer_d_, wall_ = wall_, shaft_d_ = shaft_d_, depth_ratio = depth_ratio,
        depth_ratio2 = depth_ratio2, tol_ = tol_, P = P, bearing_h_ = bearing_h_, ChamferGearsTop = ChamferGearsTop,
        ChamferGearsBottom = ChamferGearsBottom, Knob = Knob, KnobDiameter_ = KnobDiameter_,
        KnobTotalHeight_ = KnobTotalHeight_, FingerPoints = FingerPoints, FingerHoleDiameter_ = FingerHoleDiameter_,
        TaperFingerPoints = TaperFingerPoints, AT_ = AT_, $fa = $fa, $fs = $fs, $fn = $fn
    );         
}

module joiner(cutout=false,indent=false){
    difference(){
        linear_extrude(core_h/sqrt(2)-2*wall-layer_h)difference(){
            offset(r = wall)square([arm_size-2*tol-2*wall,core_h/sqrt(2)-4*wall-tol],center=true);
            if(cutout){
                translate([-arm_size/4+tol/2+wall/4,0,0])
                    square([arm_size/2-tol-wall-wall/2,core_h/sqrt(2)-4*wall-tol],center=true);
                translate([arm_size/4-tol/2-wall/4,0,0])
                    square([arm_size/2-tol-wall-wall/2,core_h/sqrt(2)-4*wall-tol],center=true);
            }
        }
        if(!cutout&&indent){
            translate([0,0,-AT])linear_extrude(core_h/2/sqrt(2)-wall-layer_h/2,scale=0)
                square([arm_size-2*tol-2*wall,core_h/sqrt(2)-4*wall-tol],center=true);
            translate([0,0,core_h/sqrt(2)-2*wall-layer_h+AT])mirror([0,0,1])linear_extrude(core_h/2/sqrt(2)-wall-layer_h/2,scale=0)
                square([arm_size-2*tol-2*wall,core_h/sqrt(2)-4*wall-tol],center=true);
            translate([0,core_h/2/sqrt(2)-2*wall-tol/2+wall+AT,core_h/2/sqrt(2)-wall-layer_h/2])
                mirror([0,1,1])linear_extrude(core_h/2/sqrt(2)-2*wall-tol/2,scale=0)
                    square([arm_size-2*tol-2*wall,core_h/sqrt(2)-2*wall-3*layer_h],center=true);
            mirror([0,1,0])translate([0,core_h/2/sqrt(2)-2*wall-tol/2+wall+AT,core_h/2/sqrt(2)-wall-layer_h/2])
                mirror([0,1,1])linear_extrude(core_h/2/sqrt(2)-2*wall-tol/2,scale=0)
                    square([arm_size-2*tol-2*wall,core_h/sqrt(2)-2*wall-3*layer_h],center=true);
            translate([0,0,core_h/sqrt(2)-2*wall-layer_h]/2)
                mirror([1,0,1])cylinder(h=arm_size,d=wall,center=true,$fn=6);
        }     
    } 
}

module base(){
    difference(){
        gearbox(
            gen = gen, scl = scl, planets = base_planets, layer_h_ = layer_h_, gh_ = [arm_size_/2], pt = pt, of = of, nt = nt,
            sgm = base_sgm, outer_d_ = base_d_, wall_ = 2*wall_, shaft_d_ = shaft_d_, depth_ratio = depth_ratio,
            depth_ratio2 = depth_ratio2, tol_ = tol_, P = P, bearing_h_ = bearing_h_, ChamferGearsTop = ChamferGearsTop,
            ChamferGearsBottom = ChamferGearsBottom, Knob = 0, KnobDiameter_ = KnobDiameter_,
            KnobTotalHeight_ = KnobTotalHeight_, FingerPoints = FingerPoints, FingerHoleDiameter_ = FingerHoleDiameter_,
            TaperFingerPoints = TaperFingerPoints, AT_ = AT_, $fa = $fa, $fs = $fs, $fn = $fn
        );
        cube([core_h/sqrt(2)-2*wall,core_h/sqrt(2)-2*wall,2*arm_size+ST],center=true);
    }
    //legs
    intersection(){
        for(i=[0:legs-1])rotate([0,0,i*360/legs])translate([-arm_width,0,0])
            cube([2*arm_width,base_d,base_d]);
        rotate_extrude(convexity = 10)
            polygon([[base_d/2-AT,0],[base_d/2-AT,arm_size/2],[base_d-arm_size/2,base_d/2],[base_d-arm_width/2,base_d/2],[base_d-arm_width/2,base_d/2-arm_width/2]]);
    }
}