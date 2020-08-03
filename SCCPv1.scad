// OpenSCAD Compound Planetary System
// (c) 2019, tmackay
//
// Licensed under a Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) license, http://creativecommons.org/licenses/by-sa/4.0.
//include <MCAD/involute_gears.scad> 

// TODO:
// modularise whole thing
// get rid of globals
// per layer depth ratio or auto-calculate maximum based on interference
// check fudge factor for s<1

// Which one would you like to see?
part = "core"; // [core:Core]

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
planets = 5; //[3:1:21]

// Layer height (for ring horizontal split)
layer_h_ = 0.2; //[0:0.01:1]
layer_h = scl*layer_h_;
// Height of planetary layers (layer_h will be subtracted from gears>0)
gh_ = [7.4, 7.6, 7.6];
gh = scl*gh_;
// Modules, planetary layers
modules = len(gh); //[2:1:3]
// Number of teeth in planet gears
pt = [5, 4, 5];
// For additional gear ratios we can add or subtract extra teeth (in multiples of planets) from rings but the profile will be further from ideal
of = 0*gh_;
// number of teeth to twist across
nt = pt/pt[0];
// Sun gear multiplier
sgm = 1; //[1:1:5]
// For fused sun gears, we require them to be a multiple of the planet teeth
dt = pt*sgm;
// Find closest ring gear to ideal
// and add offset
rt = [for(i=[0:modules-1])round((2*dt[i]+2*pt[i])/planets+of[i])*planets-dt[i]];
// Outer diameter of core
outer_d_ = 25.0; //[30:0.2:300]
outer_d = scl*outer_d_;
// Ring wall thickness (relative pitch radius)
wall_ = 2.5; //[0:0.1:20]
wall = scl*wall_;

// Calculate cp based on desired ring wall thickness (TODO: depth_ratio)
cp=(outer_d/2-1.25*wall)*360/(dt+2*pt);

// what ring should be for teeth to mesh without additional scaling
rtn = dt+2*pt;
// scale ring gear (approximate profile shift)
s=[for(i=[0:modules-1])rtn[i]/rt[i]];
// scale helix angle to mesh
ha=[for(i=[0:modules-1])atan(PI*nt[i]*cp[i]/90/gh[i])];

// Shaft diameter
shaft_d_ = 0; //[0:0.1:25]
shaft_d = scl*shaft_d_;

// secondary shafts (for larger sun gears)
shafts = 6; //[0:1:12]
// Width of outer teeth
outer_w_=3; //[0:0.1:10]
outer_w=scl*outer_w_;
// Aspect ratio of teeth (depth relative to width)
teeth_a=0.75;
// Offset of wider teeth (angle)
outer_o=2; //[0:0.1:10]
// Outside Gear depth ratio
depth_ratio=0.25; //[0:0.05:1]
// Inside Gear depth ratio
depth_ratio2=0.5; //[0:0.05:1]
// Gear clearance
tol_=0.2; //[0:0.01:0.5]
tol=scl*tol_;
// pressure angle
P=30; //[30:60]
// height of rim (ideally a multiple of layer_h
rim_h=3;
// Bearing height
bearing_h_ = 1;  //[0:0.01:5]
bearing_h = scl*bearing_h_;
// Chamfer exposed gears, top - watch fingers
ChamferGearsTop = 0;				// [1:No, 0.5:Yes, 0:Half]
// Chamfer exposed gears, bottom - help with elephant's foot/tolerance
ChamferGearsBottom = 0;				// [1:No, 0.5:Yes, 0:Half]
//Include a knob
Knob = 1;				// [1:Yes , 0:No]
//Diameter of the knob, in mm
KnobDiameter_ = 12.0;			//[10:0.5:100]
KnobDiameter = scl*KnobDiameter_;
//Thickness of knob, including the stem, in mm:
KnobTotalHeight_ = 10;			//[10:thin,15:normal,30:thick, 40:very thick]
KnobTotalHeight = scl*KnobTotalHeight_;
//Number of points on the knob
FingerPoints = 5;   			//[3,4,5,6,7,8,9,10]
//Diameter of finger holes
FingerHoleDiameter_ = 5; //[5:0.5:50]
FingerHoleDiameter = scl*FingerHoleDiameter_;
TaperFingerPoints = true;			// true
//Include a nut capture at the top
TopNutCapture = 0;				//[1:Yes , 0:No]
//Include a nut capture at the base
BaseNutCapture = 0/1;				// [1:Yes , 0:No]

// Curve resolution settings, minimum angle
$fa = 5/1;
// Curve resolution settings, minimum size
$fs = 1/1;
// Curve resolution settings, number of segments
$fn=96;

// Planetary gear ratio for fixed ring: 1:1+R/S
//echo(str("Gear ratio of first planetary stage: 1:", 1+ring_t1/drive_t));

// (Planet/Ring interaction: Nr*wr-Np*wp=(Nr-Np)*wc)
// one revolution of carrier (wc=1) turns planets on their axis
// wp = (Np-Nr)/Np = eg. (10-31)/10=-2.1 turns
// Secondary Planet/Ring interaction
// wr = ((Nr-Np)+Np*wp)/Nr = eg. ((34-11)-11*2.1)/34 = 1/340
// or Nr2/((Nr2-Np2)+Np2*(Np1-Nr1)/Np1)
//echo(str("Gear ratio of planet/ring stage: 1:", abs(ring_t2/((ring_t2-planet_t2)+planet_t2*(planet_t-ring_t1)/planet_t)))); // eg. 3.8181..

// Final gear ratio is product of above, eg. 1:1298.18..
//echo(str("Input/Output gear ratio: 1:",abs((1+ring_t1/drive_t)*ring_t2/((ring_t2-planet_t2)+planet_t2*(planet_t-ring_t1)/planet_t))));

// sanity check
for (i=[1:modules-1]){
    if ((dt[i]+rt[i])%planets)
        echo(str("Warning: For even spacing, planets (", i, ") must divide ", dt[i]+rt[i]));
    if (dt[i] + 2*pt[i] != rt[i])
        echo(str("Teeth fewer than ideal (ring", i, "): ", dt[i]+2*pt[i]-rt[i]));
    if(i<modules-1)echo(str("Input/Output gear ratio (ring", i, "): 1:",abs((1+rt[modules-1]/dt[modules-1])*rt[i]/((rt[i]-pt[i])+pt[i]*(pt[modules-1]-rt[modules-1])/pt[modules-1]))));
}

g=addl([for(i=[0:modules-1])(dt[i]+rt[i])%planets],modules)?99:gen;

// Calibration cube (invalid input)
if (g==99) {
    translate(scl*10*[-1,-1,0])cube(scl*20);
}

// Tolerances for geometry connections.
AT=scl/64;
ST=AT*2;
TT=AT/2;

core_h=addl(gh,modules);

// overhang test
if(g==undef&&part=="test"){
    //gear2D(pt[0],cp[0]*PI/180,P,depth_ratio,tol,gh[1]);
    ring2D(rt[0],s[0]*cp[0]*PI/180,P,depth_ratio,depth_ratio2,-tol,gh[1],outer_d/2);
}

// Ring gears
if(g==1||g==undef&&part=="core"){
    difference(){
        // positive volume
        for (i=[0:modules-1])translate([0,0,addl(gh,i)]){
            // ring body
            difference(){
                cylinder(r=outer_d/2,h=gh[i]);
                cylinder(r=outer_d/2-wall/2,h=gh[i]);
            }
            intersection(){
                extrudegear(t1=rt[i],gear_h=gh[i],tol=-tol,helix_angle=ha[i],cp=cp[i],AT=ST)
                    ring2D(rt[i],s[i]*cp[i]*PI/180,(2*s[i]-1)*P,depth_ratio,depth_ratio2/(2*s[i]-1),-tol,0,outer_d/2-wall/2+tol); // depth_ratio2,P fudged to account for tooth scaling - more applicable to s[i]>1?
                // cutout overhanging teeth at angle
                if(i>0&&rt[i-1]!=rt[i])rotate([0,0,-180/rt[i-1]*2*nt[i-1]])translate([0,0,layer_h])
                    ring2D(rt[i-1],s[i-1]*cp[i-1]*PI/180,(2*s[i-1]-1)*P,depth_ratio,depth_ratio2/(2*s[i-1]-1),-tol,gh[i],outer_d/2-wall/2+tol);
            }
        }
        // negative volume
        for (i=[0:modules-1])translate([0,0,addl(gh,i)]){
            // bearing surface
            if(i>0&&(pt[i-1]-rt[i-1])/pt[i-1]!=(pt[i]-rt[i])/pt[i])
                rotate_extrude()translate([0,(i%2?0:layer_h),0])mirror([0,i%2?1:0,0])
                    polygon(points=[[outer_d/2+tol,bearing_h-layer_h],[outer_d/2-wall/2-tol,bearing_h-layer_h],
                        [outer_d/2-wall/2-tol,-layer_h],[outer_d/2-wall/2+tol,-layer_h],
                        [outer_d/2-wall/2+tol,bearing_h-2*layer_h],[outer_d/2+tol,bearing_h-2*layer_h]]);
            // chamfer bottom gear
            if(ChamferGearsBottom<1&&i==0)translate([0,0,-TT])
                linear_extrude(height=(rt[i]*s[i]*cp[i]/360)/sqrt(3),scale=0,slices=1)
                    if(ChamferGearsTop>0)
                        hull()gear2D(rt[i],s[i]*cp[i]*PI/180,P,depth_ratio,depth_ratio2,-tol,0);
                    else
                        circle($fn=rt[i]*2,r=rt[i]*s[i]*cp[i]/360);
            // chamfer top gear
            if(ChamferGearsTop<1&&i==modules-1)translate([0,0,gh[i]+TT])mirror([0,0,1])
                linear_extrude(height=(rt[i]*s[i]*cp[i]/360)/sqrt(3),scale=0,slices=1)
                    if(ChamferGearsTop>0)
                        hull()gear2D(rt[i],s[i]*cp[i]*PI/180,P,depth_ratio,depth_ratio2,-tol,0);
                    else
                        circle($fn=rt[i]*2,r=rt[i]*s[i]*cp[i]/360);
        }
    }
}

// Knob by Hank Cowdog 2 Feb 2015, somewhat modified
//Diameter of the shaft thru-bolt, in mm 
ShaftDiameter = shaft_d;
ShaftEasingPercentage = 0/100.0;  // 10% is plenty
NutFlatWidth = 1.75 * ShaftDiameter;
NutHeight =     0.87 * ShaftDiameter;
SineOfSixtyDegrees = 0.86602540378/1.0;
NutPointWidth = NutFlatWidth /SineOfSixtyDegrees;
EasedShaftDiameter = ShaftDiameter * (1.0+ShaftEasingPercentage);
// center gears and knob
if(g==2||g==undef&&part=="core"){
    if(Knob)translate([0,0,core_h])
        rotate([0,0,180/dt[modules-1]*(1+2*nt[modules-1]-pt[modules-1]%2)])intersection(){
            translate([0,0,KnobTotalHeight])mirror([0,0,1])difference(){
                // The whole knob
                cylinder(h=KnobTotalHeight+TT, r=KnobDiameter/2, $fn=24);
                // each finger point
                for (i = [0 : FingerPoints-1]){
                    rotate( i * 360 / FingerPoints, [0, 0, 1])
                    translate([(KnobDiameter *.6), 0, -1])
                    union() {
                        // remove the vertical part of the finger hole 
                        cylinder(h=KnobTotalHeight+2, r=FingerHoleDiameter/2, $fn=24);
                        // taper the sides of the finger points 
                        if(TaperFingerPoints) {
                            rotate_extrude(convexity = 10, $fn=24)
                                translate([FingerHoleDiameter/2.0, 0, 0])
                                polygon( points=scl*[[2,-3],[-1,6],[-1,-3]] );
                        }
                    }
                }
                // Drill the shaft and nut captures
                translate([0,0,KnobTotalHeight+1])scale([1,1,-1])union(){
                //The thru-shaft
                    cylinder(h=KnobTotalHeight+2, r=EasedShaftDiameter/2., $fn=24);
                    // Drill the nut capture
                    if (1 == BaseNutCapture) {
                        cylinder(h=NutHeight + 1, r=NutPointWidth/2.0, $fn=6);
                    }
                }
                // Drill the 2nd nut capture      
                if (1==TopNutCapture){ 
                    translate([0,0,-1])
                        cylinder(h=NutHeight + 1, r=NutPointWidth/2.0, $fn=6);
                }
                // taper the ends of the points
                if(TaperFingerPoints) {
                    rotate_extrude(convexity = 10, $fn=24)
                    translate([KnobDiameter/2, 0, 0])
                    polygon( points=scl*[[-2,-3],[1,6],[1,-3]] );
                }
            }
            // Transition knob to gear. Cutout overhanging teeth at angle
            gear2D(dt[modules-1],cp[modules-1]*PI/180,P,depth_ratio2,depth_ratio,tol,KnobTotalHeight);
    }
    for (i = [0:modules-1]){
        // the gear itself
        translate([0,0,addl(gh,i)])intersection(){
            rotate([0,0,180/dt[i]*(1-pt[i]%2)])mirror([0,1,0])
                extrudegear(t1=dt[i],bore=0,cp=cp[i],helix_angle=ha[i],gear_h=gh[i],rot=180/dt[i]*(1-pt[i]%2))
                    gear2D(dt[i],cp[i]*PI/180,P,depth_ratio2,depth_ratio,tol,0);
            // chamfer bottom gear
            if(ChamferGearsBottom<1&&i==0)rotate(90/pt[i])translate([0,0,-TT])
                linear_extrude(height=gh[i]+AT,scale=1+gh[i]/(dt[i]*cp[i]/360)*sqrt(3),slices=1)
                    circle($fn=dt[i]*2,r=dt[i]*cp[i]/360-ChamferGearsBottom*min(cp[i]/(2*tan(P))+tol,depth_ratio2*cp[i]*PI/180+tol));
            // cutout overhanging teeth at angle
            if(i>0&&dt[i-1]!=dt[i])rotate([0,0,180/dt[i-1]*(1+2*nt[i-1]-pt[i-1]%2)])
                gear2D(dt[i-1],cp[i-1]*PI/180,P,depth_ratio2,depth_ratio,tol,gh[i]);
            
            // chamfer top gear
            if(!Knob&&ChamferGearsTop<1&&i==modules-1)translate([0,0,gh[i]+TT])rotate(90/dt[i])mirror([0,0,1])
                linear_extrude(height=gh[i]+ST,scale=1+gh[i]/(dt[i]*cp[i]/360)*sqrt(3),slices=1)
                    circle($fn=dt[i]*2,r=dt[i]*cp[i]/360-ChamferGearsTop*min(cp[i]/(2*tan(P))+tol,depth_ratio2*cp[i]*PI/180+tol));
        }
    }
}

// planets
if(g>2||g==undef&&part=="core"){
    planets(t1=pt[0], t2=dt[0],offset=(dt[0]+pt[0])*cp[0]/360,n=planets,t=rt[0]+dt[0])difference(){
        for (i = [0:modules-1]){
            translate([0,0,addl(gh,i)]){
                intersection(){
                    // the gear itself
                    extrudegear(t1=pt[i],bore=0,cp=cp[i],helix_angle=ha[i],gear_h=gh[i])
                        gear2D(pt[i],cp[i]*PI/180,P,depth_ratio,depth_ratio2,tol,0);
                    // chamfer bottom gear
                    if(ChamferGearsBottom<1&&i==0)rotate(90/pt[i])translate([0,0,-TT])
                        linear_extrude(height=gh[i]+AT,scale=1+gh[i]/(pt[i]*cp[i]/360)*sqrt(3),slices=1)
                            circle($fn=pt[i]*2,r=pt[i]*cp[i]/360-ChamferGearsBottom*min(cp[i]/(2*tan(P))+tol,depth_ratio*cp[i]*PI/180+tol));                
                    // cutout overhanging teeth at angle
                    if(i>0&&pt[i-1]!=pt[i])rotate([0,0,180/pt[i-1]*(-2*nt[i-1])])
                        gear2D(pt[i-1],cp[i-1]*PI/180,P,depth_ratio,depth_ratio2,tol,gh[i]);
                    // chamfer top gear
                    if(ChamferGearsTop<1&&i==modules-1)translate([0,0,gh[i]+TT])rotate(90/pt[i])mirror([0,0,1])
                        linear_extrude(height=gh[i]+ST,scale=1+gh[i]/(pt[i]*cp[i]/360)*sqrt(3),slices=1)
                            circle($fn=pt[i]*2,r=pt[i]*cp[i]/360-ChamferGearsTop*min(cp[i]/(2*tan(P))+tol,depth_ratio*cp[i]*PI/180+tol));
                }
            }
        }
        if(pt[0]*cp[0]/360-ChamferGearsTop*min(cp[0]/(2*tan(P))+tol) > shaft_d)
            translate([0,0,-TT])cylinder(d=shaft_d,h=core_h+AT);
    }
}

// test overhang removal
if(g==undef&&part=="3D"){
    //gear2D(dt[0],cp[0]*PI/180,P,depth_ratio2,depth_ratio,tol,gh[1]);
    ring2D(rt[0],s[0]*cp[0]*PI/180,P,depth_ratio,depth_ratio2,-tol,gh[1],outer_d/2-wall/2);
}

// test overhang removal
if(g==undef&&part=="2D"){
    for(i=[0:1])translate([0,i*(outer_d+tol),0]){
        planets(t1=pt[i], t2=dt[i],offset=(dt[i]+pt[i])*cp[i]/360,n=planets,t=rt[i]+dt[i])
            gear2D(pt[i],cp[i]*PI/180,P,depth_ratio,depth_ratio2,tol,0);
        ring2D(rt[i],s[i]*cp[i]*PI/180,(2*s[i]-1)*P,depth_ratio,depth_ratio2/(2*s[i]-1),-tol,0,outer_d/2-wall/2+tol); // depth_ratio2,P fudged to account for tooth scaling
        rotate([0,0,180/dt[i]*(1-pt[i]%2)])
            gear2D(dt[i],cp[i]*PI/180,P,depth_ratio2,depth_ratio,tol,0);
    }
}

// Space out planet gears approximately equally
module planets(){
    for(i = [0:n-1])if(g==undef||i==g-3)
    rotate([0,0,round(i*t/n)*360/t])
        translate([offset,0,0]) rotate([0,0,round(i*t/n)*360/t*t2/t1])
            children();
}

// Rotational and mirror symmetry
module seg(z=10){
    for(i=[0:360/z:359.9])rotate([0,0,i]){
        children();
        mirror([0,1,0])children();
    }
}

// half-tooth overhang volume
module overhang(height=0){
    if(height>0)minkowski(){
        linear_extrude(AT)children();
        cylinder(r1=0,r2=height*1.75,h=height,$fn=12); // 60 degree overhang
    } else children();
}

// reversible herringbone gear
module extrudegear(t1=13,bore=0,rot=0,helix_angle=0,gear_h=10,cp=10){
    translate([0,0,gear_h/2])
        herringbone(t1,PI*cp/180,P,tol,helix_angle,gear_h,AT=AT)
            children();
}

module mir(){
    children();
    mirror([0,0,1])children();
}

// Herringbone gear code, somewhat modified, taken from:
// Planetary gear bearing (customizable)
// https://www.thingiverse.com/thing:138222
// Captive Planetary Gear Set: parametric. by terrym is licensed under the Creative Commons - Attribution - Share Alike license.
module herringbone(
	number_of_teeth=15,
	circular_pitch=10,
	pressure_angle=28,
	clearance=0,
	helix_angle=0,
	gear_thickness=5){
    pitch_radius = number_of_teeth*circular_pitch/(2*PI);
    twist=tan(helix_angle)*gear_thickness/2/pitch_radius*180/PI;
    mir()linear_extrude(height=gear_thickness/2,twist=twist,slices=6)children(); 
}

module gear2D (
	number_of_teeth,
	circular_pitch,
	pressure_angle,
	depth_ratio,
	depth_ratio2,
	clearance,
    height=0){
pitch_radius = number_of_teeth*circular_pitch/(2*PI);
base_radius = pitch_radius*cos(pressure_angle);
depth=circular_pitch/(2*tan(pressure_angle));
outer_radius = clearance<0 ? pitch_radius+depth/2-clearance : pitch_radius+depth/2;
root_radius1 = pitch_radius-depth/2-clearance/2;
root_radius = (clearance<0 && root_radius1<base_radius) ? base_radius : root_radius1;
backlash_angle = clearance/(pitch_radius*cos(pressure_angle)) * 180 / PI;
half_thick_angle = 90/number_of_teeth - backlash_angle/2;
pitch_point = involute (base_radius, involute_intersect_angle (base_radius, pitch_radius));
pitch_angle = atan2 (pitch_point[1], pitch_point[0]);
min_radius = max (base_radius,root_radius);

seg(number_of_teeth)overhang(height)intersection(){
	circle($fn=number_of_teeth*6,r=pitch_radius+depth_ratio*circular_pitch/2-clearance/2);
	union(){
        intersection(){
            rotate(90/number_of_teeth)
                circle($fn=number_of_teeth*6,r=max(root_radius,pitch_radius-depth_ratio2*circular_pitch/2-clearance/2));
            mirror([0,1,0])square(max(root_radius,pitch_radius-depth_ratio2*circular_pitch/2-clearance/2));
            rotate(-180/number_of_teeth)translate([0,-AT,0])
                square(max(root_radius,pitch_radius-depth_ratio2*circular_pitch/2-clearance/2));
        }
        halftooth (
			pitch_angle,
			base_radius,
			min_radius,
			outer_radius,
			half_thick_angle);		
		}
	}
}

module ring2D (number_of_teeth,circular_pitch,pressure_angle,depth_ratio,depth_ratio2,clearance,height=0,radius){
    pitch_radius = number_of_teeth*circular_pitch/(2*PI);
    base_radius = pitch_radius*cos(pressure_angle);
    depth=circular_pitch/(2*tan(pressure_angle));
    outer_radius = clearance<0 ? pitch_radius+depth/2-clearance : pitch_radius+depth/2;
    root_radius1 = pitch_radius-depth/2-clearance/2;
    root_radius = (clearance<0 && root_radius1<base_radius) ? base_radius : root_radius1;
    backlash_angle = clearance/(pitch_radius*cos(pressure_angle)) * 180 / PI;
    half_thick_angle = 90/number_of_teeth - backlash_angle/2;
    pitch_point = involute (base_radius, involute_intersect_angle (base_radius, pitch_radius));
    pitch_angle = atan2 (pitch_point[1], pitch_point[0]);
    min_radius = max (base_radius,root_radius);
    seg(number_of_teeth)overhang(height)difference(){
        intersection(){
            circle(r=radius);
            mirror([0,1,0])square(radius);
            rotate(-180/number_of_teeth)translate([0,-AT,0])square(radius);
        }
        intersection(){
            circle($fn=number_of_teeth*6,r=pitch_radius+depth_ratio*circular_pitch/2-clearance/2);
            union(){
                rotate(90/number_of_teeth)
                    circle($fn=number_of_teeth*6,r=max(root_radius,pitch_radius-depth_ratio2*circular_pitch/2-clearance/2));
                halftooth (pitch_angle,base_radius,min_radius,outer_radius,half_thick_angle);		
            }
        }
    }
}

module halftooth (
	pitch_angle,
	base_radius,
	min_radius,
	outer_radius,
	half_thick_angle){
index=[0,1,2,3,4,5];
start_angle = max(involute_intersect_angle (base_radius, min_radius)-5,0);
stop_angle = involute_intersect_angle (base_radius, outer_radius);
angle=index*(stop_angle-start_angle)/index[len(index)-1];
p=[[0,0], // The more of these the smoother the involute shape of the teeth.
	involute(base_radius,angle[0]+start_angle),
	involute(base_radius,angle[1]+start_angle),
	involute(base_radius,angle[2]+start_angle),
	involute(base_radius,angle[3]+start_angle),
	involute(base_radius,angle[4]+start_angle),
	involute(base_radius,angle[5]+start_angle)];

difference(){
	rotate(-pitch_angle-half_thick_angle)polygon(points=p);
	square(2*outer_radius);
}}

// Mathematical Functions
//===============

// Finds the angle of the involute about the base radius at the given distance (radius) from it's center.
//source: http://www.mathhelpforum.com/math-help/geometry/136011-circle-involute-solving-y-any-given-x.html

function involute_intersect_angle (base_radius, radius) = sqrt (pow (radius/base_radius, 2) - 1) * 180 / PI;

// Calculate the involute position for a given base radius and involute angle.

function involute (base_radius, involute_angle) =
[
	base_radius*(cos (involute_angle) + involute_angle*PI/180*sin (involute_angle)),
	base_radius*(sin (involute_angle) - involute_angle*PI/180*cos (involute_angle))
];

// Recursively sums all elements of a list up to n'th element, counting from 1
function addl(list,n=0) = n>0?(n<=len(list)?list[n-1]+addl(list,n-1):list[n-1]):0;