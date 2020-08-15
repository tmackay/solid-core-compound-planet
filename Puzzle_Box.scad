// OpenSCAD Compound Planetary System
// (c) 2019, tmackay
//
// Licensed under a Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) license, http://creativecommons.org/licenses/by-sa/4.0.
include <SCCPv1.scad> 

// Use for command line option '-Dg=n'
// 0-7+ - generate parts individually in assembled positions. Combine with MeshLab.
// 0 box
// 1 ring gears and jaws
// 2 sun gear and knob
// 3+ planet gears
// 100+ emboss pattern segments
g=1;

// Overall scale (to avoid small numbers, internal faces or non-manifold edges)
scl = 1000;

// Number of planet gears in gearbox
planets = 5; //[3:1:21]
// Layer height (for ring horizontal split)
layer_h_ = 0.2; //[0:0.01:1]
// Height of planetary layers (layer_h will be subtracted from gears>0)
gh_ = [7.4, 7.6, 7.6];
// Number of teeth in planet gears
pt = [4, 5, 6];
// For additional gear ratios we can add or subtract extra teeth (in multiples of planets) from rings but the profile will be further from ideal
of = [0, 0, 0];
// number of teeth to twist across
nt = [1, 1, 1];
// Sun gear multiplier
sgm = 1; //[1:1:5]
// Outer diameter
outer_d_ = 25.0; //[30:0.2:300]
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
FingerPoints = 6;   			//[3,4,5,6,7,8,9,10]
//Diameter of finger holes
FingerHoleDiameter_ = 5; //[5:0.5:50]
TaperFingerPoints = true;			// true

// Outer teeth
outer_t = [5,7];
// Width of outer teeth
outer_w_=3; //[0:0.1:10]
outer_w=scl*outer_w_;

// Encoder symbols csv for daisy chained encoder rows
charinput="0123456789ABCDEFEDCBA987654321"; // 30 symbols for how many turns the encoder layer makes during a complete cycle
sym = split(",",charinput); // workaround for customizer
// Font used for all rows
font = "Liberation Mono:style=Bold";
// Depth of embossed characters
char_thickness_ = 0.5;
char_thickness = scl*char_thickness_;

// Tolerances for geometry connections.
AT_=1/64;
// Curve resolution settings, minimum angle
$fa = 5/1;
// Curve resolution settings, minimum size
$fs = 1/1;
// Curve resolution settings, number of segments
$fn=96;

// common calculated variables
modules = len(gh_);
core_h = scl*addl(gh_,len(gh_));
wall = scl*wall_;
bearing_h = scl*bearing_h_;
gh = scl*gh_;
outer_d = outer_d_*scl;
layer_h = scl*layer_h_;
tol = scl*tol_;
AT=AT_*scl;
ST=AT*2;
TT=AT/2;

// Thickness of wall at thinnest point
wall_thickness = 1.2; // [0:0.1:5]
// Tooth overlap - how much grab the ring teeth have on the core teeth
tooth_overlap = 1.2; // [0:0.1:5]
// calculate wall and teeth depth from above requirements
t = scl*(wall_thickness+tooth_overlap+2*tol_);
w = scl*(wall_thickness+tooth_overlap+1.5*tol_-tooth_overlap/2);

// Only used for gear ratio calculations for encoder (otherwise calculated internally in gearbox();)
dt = pt*sgm;
rt = [for(i=[0:modules-1])round((2*dt[i]+2*pt[i])/planets+of[i])*planets-dt[i]];
gr = [for(i=[0:modules-2])abs((1+rt[modules-1]/dt[modules-1])*rt[i]/((rt[i]-pt[i])+pt[i]*(pt[modules-1]-rt[modules-1])/pt[modules-1]))];

// TODO: check and simplify - looking for lowest integer of turns when consecutive rings align at starting point
rev = [for(i=[1:modules-2])abs(rt[i]*(rt[i-1]-pt[i-1]+pt[i-1]*(pt[modules-1]-rt[modules-1])/pt[modules-1])/(rt[i]-pt[i]+pt[i]*(pt[modules-1]-rt[modules-1])/pt[modules-1]))];

for(i=[0:modules-3])if(len(sym[i])!=round(rev[i]))echo(str("Require ", rev[i], " characters for ring", i+1));

// Box
if(g==0||g==undef){
    difference(){
        cylinder(d=outer_d+2*wall,h=core_h);
        translate([0,0,scl+3*tol-TT])cylinder(d=outer_d+4*tol,h=core_h+AT);
        // bottom taper
        translate([0,0,scl-TT])cylinder(d1=outer_d+4*tol-6*tol,d2=outer_d+4*tol,h=3*tol+AT);
        translate([0,0,-TT])cylinder(d=outer_d+4*tol-6*tol,h=scl+AT);
        
        // top taper
        translate([0,0,core_h-scl])cylinder(d=outer_d-4*w+8*tol+2*t+2*w+2*tol,h=scl+AT);
        translate([0,0,core_h-scl-t])cylinder(d1=outer_d-4*w+2*w+2*tol,d2=outer_d-4*w+8*tol+2*t+2*w+2*tol,h=t+AT);
        r=(outer_d+(outer_w+4*tol)/sqrt(2))/2;
        for (i=[0:modules-2])translate([0,0,addl(gh,i)]){
            h=gh[i]/2;
            d=h/4;
            // outer teeth
            if(!i&&len(outer_t))intersection(){
                translate([0,0,i%2?h+bearing_h-2*layer_h:h-bearing_h])rotate_extrude()
                    polygon( points=[[0,0],[r-d,0],[r,d],[r,core_h-d],[r-d,core_h],[0,core_h]] );
                for(i = [0:len(outer_t)-1], j = [0:outer_t[i]-1])
                    mirror([i,0,0])rotate([0,0,j*360/outer_t[i]])translate([outer_d/2,0,0])rotate([0,0,45])
                        cylinder(d=outer_w+4*tol,h=core_h,$fn=4);
            }
            // track
            translate([0,0,i%2?h+bearing_h-2*layer_h:h-bearing_h])
                rotate_extrude()
                    polygon( points=[[0,0],[r-d,0],[r,d],[r,h-d],[r-d,h],[0,h]] );
            // peek holes
            if(i>0)translate([0,0,gh[i]/4]){
                rotate([90,90,180*i])translate([0,0,outer_d/2])
                    cylinder(d=gh[i]/3,h=2*wall,$fn=12);
                // decorative holes
                //if(len(outer_t))for(j = [0:outer_t[0]-1])rotate([0,0,j*360/outer_t[0]])
                    rotate([90,90,180*i])translate([0,0,outer_d/2+2*wall/3])
                        cylinder(d1=gh[i]/3,d2=gh[i],h=wall,$fn=12);
            }
        }
        translate([(outer_d+wall)/2+tol-1.5*tol,0,-wall/4])
            cylinder(d=gh[0]/4,h=wall/2);
        tri()cut()import("pattern.stl");
    }
}

// Core
if(g>0&&g<99||g==undef){
    difference(){
        // positive volume
        union(){
            // top taper
            difference(){
                union(){
                    translate([0,0,core_h-scl])
                        cylinder(d=outer_d-4*w+2*t+4*tol+2*w+2*tol,h=scl);
                    translate([0,0,core_h-scl-t])
                        cylinder(d1=outer_d-4*w-4*tol+2*w+2*tol,d2=outer_d-4*w+2*t+4*tol+2*w+2*tol,h=t+AT);
                }
                translate([0,0,core_h-t-scl-AT])cylinder(r=outer_d/2-AT,h=t+scl+ST);
            }
            for (i=[0:modules-1])translate([0,0,addl(gh,i)]){
                // outer teeth
                r=(outer_d+outer_w/sqrt(2))/2;
                h=gh[i]/2;
                d=h/4;
                if(len(outer_t))intersection(){
                    translate([0,0,i%2?h+bearing_h-2*layer_h:h-bearing_h])rotate_extrude()
                        polygon(points=[[outer_d/2-AT,0],[r-d,0],[r,d],[r,h-(i<modules-1?d:0)],[r-d,h],[outer_d/2-AT,h]]);
                    for(k = [0:len(outer_t)-1], j = [0:outer_t[k]-1])
                        mirror([k,0,0])rotate([0,0,j*360/outer_t[k]])translate([outer_d/2,0,0])rotate([0,0,45])
                            cylinder(d=outer_w,h=core_h,$fn=4);
                }
            }
            mirror([1,0,0])gearbox(
                gen = undef, scl = scl, planets = planets, layer_h_ = layer_h_, gh_ = gh_, pt = pt, of = of, nt = nt,
                sgm = sgm, outer_d_ = outer_d_, wall_ = wall_, shaft_d_ = shaft_d_, depth_ratio = depth_ratio,
                depth_ratio2 = depth_ratio2, tol_ = tol_, P = P, bearing_h_ = bearing_h_, ChamferGearsTop = ChamferGearsTop,
                ChamferGearsBottom = ChamferGearsBottom, Knob = Knob, KnobDiameter_ = KnobDiameter_,
                KnobTotalHeight_ = KnobTotalHeight_, FingerPoints = FingerPoints, FingerHoleDiameter_ = FingerHoleDiameter_,
                TaperFingerPoints = TaperFingerPoints, AT_ = AT_, $fa = $fa, $fs = $fs, $fn = $fn
            );
        }
        // encoder (TODO: hardcoded gear ratios)
        for (i=[1:modules-2],j=[0:len(sym[i-1])-1])
            translate([0,0,addl(gh,i)+gh[i]/4])
                rotate([90,0,180*i+360*gr[i-1]/gr[i]*j])translate([0,0,outer_d/2-wall/4])
                    if(j)linear_extrude(2*char_thickness+tol)
                        scale(min(1.25*PI*(outer_d-wall/2)/len(sym[i-1]),gh[i]/2)/10)
                            text(sym[i-1][j],font=font,size=10,$fn=4,valign="center",halign="center");
                    else cylinder(d=gh[i]/4,h=wall/2);
        // bottom taper
        difference(){
            translate([0,0,-AT])cylinder(r=outer_d/2+AT,h=scl+3*tol+AT);
            translate([0,0,scl])cylinder(d1=outer_d-6*tol,d2=outer_d,h=3*tol+AT);
            cylinder(d=outer_d-6*tol,h=scl+AT);
        }
        translate([(outer_d-wall)/2+tol-4.5*tol,0,-wall/4])
            cylinder(d=gh[0]/4,h=wall/2);
        
    }
}

// TODO: hardcoded for $fn=96
// Pattern, simplify to 20k faces in MeshLab - Total rendering time: 0 hours, 4 minutes, 50 seconds
if(g==99)mirror([1,0,-1]){
    mirror([0,0,1])
        scale([((outer_d/2+wall)*sin(360/96)*96/3+AT)/249,((outer_d/2+wall)*sin(360/96)*96/3+AT)/249,core_h/10000])
            surface(file="pattern.png");
    cube([(outer_d/2+wall)*sin(360/96)*96/3+AT,(outer_d/2+wall)*sin(360/96)*96/3+AT,wall]);
}

// Test Cylinder - Total rendering time: 0 hours, 18 minutes, 3 seconds
if(g>99)difference(){
    cylinder(r=outer_d/2+wall,h=core_h);
    tri()cut()import("pattern.stl");
}

module tri(){
    for(i=[0:3])rotate(120*i)children();
}

module cut(){
    for(i=[0:96/3-1])rotate(i*360/96)intersection(){
        translate([0,0,scl])cube([outer_d,sin(360/96)*(outer_d/2+wall)+AT,core_h-2*scl]);
        translate([outer_d/2+wall,0,0])rotate(180/96)translate([0,-i*sin(360/96)*(outer_d/2+wall),0])
            children();
    }
}

function substr(s,st,en,p="") = (st>=en||st>=len(s))?p:substr(s,st+1,en,str(p,s[st]));

function split(h,s,p=[]) = let(x=search(h,s))x==[]?concat(p,s):
    let(i=x[0],l=substr(s,0,i),r=substr(s,i+1,len(s)))split(h,r,concat(p,l));