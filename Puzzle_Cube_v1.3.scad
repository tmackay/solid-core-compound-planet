// OpenSCAD Puzzle Cube
// (c) 2020, tmackay
//
// Licensed under a Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) license, http://creativecommons.org/licenses/by-sa/4.0.

include <SCCPv1.scad> // see https://github.com/tmackay/solid-core-compound-planet

// Which one would you like to see?
part = "box"; // [box:Box,lower:Lower Half,upper:Upper Half,core:Core,tool:Key Tool]

// Use for command line option '-Dgen=n', overrides 'part'
// 0-7+ - generate parts individually in assembled positions. Combine with MeshLab.
// 0 box
// 1 ring gears and jaws
// 2 sun gear and knob
// 3+ planet gears
gen=undef;

// Overall scale (to avoid small numbers, internal faces or non-manifold edges)
scl = 1000;

// External dimensions of cube
cube_w_ = 76.2;
cube_w = cube_w_*scl;

// Number of planet gears in inner circle
planets = 5; //[3:1:21]

// Height of planetary layers (layer_h will be subtracted from gears>0). Non-uniform heights will reveal bugs.
gh_ = [7.2, 7.4, 7.4, 7.4, 7.4, 7.4];
gh = scl*gh_;
// Modules, planetary layers
modules = len(gh); //[2:1:3]

// Number of teeth in planet gears
pt = [5, 5, 5, 7, 6, 4];
//pt = [5, 5, 5, 5, 6, 4];

// For additional gear ratios we can add or subtract extra teeth (in multiples of planets) from rings but the profile will be further from ideal
of =0*pt ;
// number of teeth to twist across
nt = pt/pt[0];
// Sun gear multiplier
sgm = 2; //[1:1:5]
// For fused sun gears, we require them to be a multiple of the planet teeth
dt = pt*sgm;
// Find closest ring gear to ideal
// and add offset
rt = [for(i=[0:modules-1])round((2*dt[i]+2*pt[i])/planets+of[i])*planets-dt[i]];
// Outer diameter of core
outer_d_ = 36.0; //[30:0.2:300]
outer_d = scl*outer_d_;
// Ring wall thickness (relative pitch radius)
wall_ = 3.1; //[0:0.1:20]
wall = scl*wall_;

// Negative - tinkercad import will fill in hollow shapes (most unhelpful). This will also save a subtraction operation ie. This will give us the shape to subtract from the art cube directly.
Negative = 0;				// [1:No, 0.5:Yes, 0:Half]
// Simplified model without gears
draft = 0; // [0:No, 1:Yes]

// Calculate cp based on desired ring wall thickness
cp=(outer_d/2-wall)*360/(dt+2*pt);

// what ring should be for teeth to mesh without additional scaling
rtn = dt+2*pt;

// Shaft diameter
shaft_d_ = 6; //[0:0.1:25]
shaft_d = scl*shaft_d_;
// Spring outer diameter
spring_d_ = 5; //[0:0.1:25]
spring_d = scl*spring_d_;
// False gate depth
fg_ = 1; //[0:0.1:5]
fg = scl*fg_;

// Width of outer teeth
outer_w_=3; //[0:0.1:10]
outer_w=scl*outer_w_;
// Aspect ratio of teeth (depth relative to width)
teeth_a=0.75;
// Aspect ratio of core teeth (depth relative to width)
teeth_a2=0.5;
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
// Bearing height
bearing_h_ = 1;  //[0:0.01:5]
bearing_h = scl*bearing_h_;
// Layer height (for ring horizontal split)
layer_h_ = 0.2; //[0:0.01:1]
layer_h = scl*layer_h_;
// height of rim (ideally a multiple of layer_h
rim_h=3;
// Chamfer exposed gears, top - watch fingers
ChamferGearsTop = 0;				// [1:No, 0.5:Yes, 0:Half]
// Chamfer exposed gears, bottom - help with elephant's foot/tolerance
ChamferGearsBottom = 0;				// [1:No, 0.5:Yes, 0:Half]

// Tolerances for geometry connections.
AT_=1/64;
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

// sanity check - relative to bottom gear(s)
for (i=[0:modules-1]){
    if ((dt[i]+rt[i])%planets)
        echo(str("Warning: For even spacing, planets (", i, ") must divide ", dt[i]+rt[i]));
    if (dt[i] + 2*pt[i] != rt[i])
        echo(str("Teeth fewer than ideal (ring", i, "): ", dt[i]+2*pt[i]-rt[i]));
    if(i>0)echo(str("Input/Output gear ratio (ring", i, "): 1:",abs((1+rt[0]/dt[0])*rt[i]/((rt[i]-pt[i])+pt[i]*(pt[0]-rt[0])/pt[0]))));
    //if(i>0)echo(str("Input/Output gear ratio (ring", i, "): 1:","(1+",rt[0],"/",dt[0],")*",rt[i],"/(",(rt[i]-pt[i]),pt[i]*(pt[0]-rt[0]),"/",pt[0],")"));
}

// find first rotating ring
mid = search(1,[for (i=[0:modules-1]) pt[0]*(rt[i]-pt[i]) == pt[i]*(rt[0]-pt[0])?0:1])[0];
echo(str("mid: ",mid));

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
core_h2 = (cube_w-core_h)/2;

r=1*scl+outer_d/2-4*tol;
h=core_h2;
d=h/4;

// core tool - for demonstration
if(g==undef&&part=="tool"){
    // TODO: use of tol for vertical clearances - use multiple of layer_h instead
    translate([0,0,core_h2-cube_w/2-gh[0]-AT])cylinder(d=r,h=gh[0]+AT);
    translate([0,0,core_h2-cube_w/2-AT])cylinder(d=shaft_d-2*tol,h=gh[0]+ST);
    
    // outer teeth
    intersection(){
        r=(shaft_d+outer_w/sqrt(2))/2-2*tol;
        r1=shaft_d/2-2*tol;
        h=gh[0]/2;
        d=teeth_a2*outer_w;
        dz=d/sqrt(3);
        translate([0,0,core_h2+gh[0]/2-cube_w/2])rotate_extrude()
            polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
        for(j = [0:1])rotate([0,0,180*j])
            translate([r,0,core_h2+gh[0]/2-cube_w/2])scale([2,1,1])rotate([0,0,45])
                cylinder(d=outer_w-4*tol,h=core_h+core_h2+tol+ST,$fn=4);
    }
}

// Box
if(g==0||g==undef&&(part=="box"||part=="lower"||part=="upper"))difference(){
    if(Negative)cube(cube_w,center=true);
    lament();
}

module lament(){
    if(g==0||part=="box"||part=="lower")lamenthalf(turns=true)children();
    if(g==0||part=="box"||part=="upper")mirror([0,0,1])mirror([0,1,0])lamenthalf()mirror([0,0,1])mirror([0,1,0])children();
}

module lamenthalf(turns=false){
    difference(){
        union(){
            // top ledge
            translate([0,0,1*scl-cube_w/2])
                cylinder(r1=outer_d/2+teeth_a*outer_w, r2=outer_d/2, h=(rim_h-1)*scl-layer_h+AT);
            translate([0,0,-cube_w/2])
                cylinder(r=outer_d/2+teeth_a*outer_w, h=1*scl+AT);

            translate([0,0,-cube_w/2])
                cylinder(d=outer_d,h=core_h2-tol,$fn=96);
            for (i=[0:2:15]){
                difference(){
                    intersection(){
                        cube(cube_w,center=true);
                        rotate([0,0,i*360/16])
                            translate([cube_w/2+tol,cube_w/2,0])cube(cube_w,center=true);
                        rotate([0,0,(i-1)*360/16])
                            translate([-cube_w/2-tol,cube_w/2,0])cube(cube_w,center=true);
                    }
                    difference(){ // TODO: flatten positive and negative volumes
                        translate([0,0,core_h2-tol-cube_w/2])
                            cylinder(d=outer_d+4*tol,h=cube_w-core_h2+tol+AT);
                        // turning teeth
                        if(turns)for(i=[modules/2-1:modules/2-1])translate([0,0,addl(gh,i)-cube_w/2+core_h2+(i>0&&i<modules/2?layer_h:0)]){
                            r=(outer_d+outer_w/sqrt(2))/2+2*tol;
                            r1=outer_d/2+2*tol;
                            h=gh[i]/2;
                            d=teeth_a*outer_w;
                            dz=d/sqrt(3);
                            // track
                            translate([0,0,core_h/2+core_h2])
                                rotate_extrude()
                                    polygon(points=[[r1+AT,0],[r1,0],[r1-d,dz],[r1-d,h-dz],[r1,h],[r1+AT,h]]);
                        }
                    }
                }
            }

            // TODO: use of tol for vertical clearances - use multiple of layer_h instead
            translate([0,0,core_h2-cube_w/2-tol-AT])cylinder(d=r,h=tol+AT);
            translate([0,0,core_h2-cube_w/2-AT])cylinder(d=shaft_d-2*tol,h=gh[0]+ST);
            
            // outer teeth of secondary locking mechanism
            intersection(){
                r=(shaft_d+outer_w/sqrt(2))/2-2*tol;
                r1=shaft_d/2-2*tol;
                h=gh[0]/2;
                d=teeth_a2*outer_w;
                dz=d/sqrt(3);
                translate([0,0,core_h2+gh[0]/2-cube_w/2])rotate_extrude()
                    polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
                for(j = [0:1])rotate([0,0,180*j])
                    translate([r,0,core_h2+gh[0]/2-cube_w/2])scale([2,1,1])rotate([0,0,45])
                        cylinder(d=outer_w-4*tol,h=core_h+core_h2+tol+ST,$fn=4);
            }
        }

        // Dial spool track
        // TODO: parameterise dial diameter and hard coded offsets, scope global variables
        translate([0,0,-cube_w/2])rotate_extrude()
            polygon( points=[
                [r,-AT],[r,1*scl],[r-2.5*d,2*d],[r-2.5*d,h-1.5*d],[r-d,h-1*scl],[r-d,h+AT],[r-d-2*tol,h+AT],
                [r-d-2*tol,h-1*scl],[r-2.5*d-2*tol,h-1.5*d],[r-2.5*d-2*tol,2*d],[r-2*tol,1*scl],[r-2*tol,-AT]]);

        // vertical tracks and teeth gates
        translate([0,0,core_h2-cube_w/2+(turns?addl(gh,mid-1)+gh[mid-1]/2:0)])intersection(){
            r=(outer_d+outer_w/sqrt(2))/2+2*tol;
            r1=outer_d/2+2*tol;
            h=turns?core_h+core_h2:gh[0]/2+gh[1]+gh[2]+core_h/2+core_h2; // TODO: module dependant
            d=teeth_a*outer_w;
            dz=d/sqrt(3);
            rotate_extrude()
                polygon(points=[[r1-d-AT,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[r1-d-AT,h]]);
            // outer teeth
            for(j = [1:8]){
                intersection(){
                    rotate(j*360/8+asin(tol/r1)-(turns?0:360/32))cube([r1+d+AT,r1+d+AT,h]);
                    rotate(90-360/32+j*360/8-asin(tol/r1)-(turns?0:360/32))cube([r1+d+AT,r1+d+AT,h]);
                }
            }
        }

        // locking tracks - TODO: asymetrical teeth
        for (i=[(turns?mid:0):(turns?modules-1:modules-mid-1)])translate([0,0,addl(gh,i)-cube_w/2+core_h2]){
            r=(outer_d+outer_w/sqrt(2))/2+2*tol;
            r1=outer_d/2+2*tol;
            h=gh[i]/2;
            d=teeth_a*outer_w;
            dz=d/sqrt(3);
            // track
            translate([0,0,(i>modules/2-1?gh[i]/2:0)+(i>0&&i<modules/2?layer_h:0)])
                rotate_extrude()
                    polygon(points=[[r1-tol,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[r1-tol,h]]);
        }

        // turning teeth TODO: clearance to teeth
        if(!turns)mirror([0,0,1])for(i=[modules/2-1:modules/2-1])translate([0,0,addl(gh,i)-cube_w/2+core_h2+(i>0?layer_h:0)]){
            r=(outer_d+outer_w/sqrt(2))/2;//+2*tol;
            r1=outer_d/2;
            h=gh[i]/2+core_h2;
            d=teeth_a*outer_w;
            dz=d/sqrt(3);
            // track
            translate([0,0,core_h/2+core_h2-core_h2])intersection(){
                rotate_extrude()
                    polygon(points=[[r1+AT,0],[r1,0],[r1-d,dz],[r1-d,h-dz],[r1,h],[r1+AT,h]]);
                for(j = [1:8]){
                    intersection(){
                        rotate(j*360/8+asin(tol/r1)+360/16)cube([r1+d+AT,r1+d+AT,h]);
                        rotate(90-360/32+j*360/8-asin(tol/r1)+360/16)cube([r1+d+AT,r1+d+AT,h]);
                    }
                }
            }
        }
        
        // top ledge
        translate([0,0,cube_w/2-rim_h*scl])
            cylinder(r1=outer_d/2+2*tol, r2=outer_d/2+2*tol+teeth_a*outer_w, h=(rim_h-1)*scl+AT);
        translate([0,0,cube_w/2-1*scl])
            cylinder(r=outer_d/2+2*tol+teeth_a*outer_w, h=rim_h*scl+AT);

        // temporary section (for fiddling with spool cutout)
        // translate(-cube_w*[1,0,1])cube(2*cube_w);
    }
}

// Core
if(g==1||g==undef&&part=="core")translate([0,0,core_h2-cube_w/2]){
    difference(){
        // positive volume
        union(){
            for (i=[mid-1:modules-1])translate([0,0,addl(gh,i)+gh[i]/2]){
                // outer teeth
                r=(outer_d+outer_w/sqrt(2))/2;
                r1=outer_d/2;
                h=gh[i]/2;
                d=teeth_a*outer_w;
                dz=d/sqrt(3);
                for(j = [1:16])rotate_extrude()
                    polygon(points=[[r1-AT,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[r1-AT,h]]);
            }
            difference(){
                cylinder(r=outer_d/2,h=core_h);
                cylinder(r=outer_d/2-teeth_a*outer_w-AT,h=core_h);
                for (i=[mid:modules-1])
                    translate([0,0,addl(gh,i)-layer_h+bearing_h]){
                        translate(-outer_d*[1,1,0])cube([2*outer_d,2*outer_d,layer_h]);
                    }
            }
            if(draft)cylinder(r=outer_d/2-teeth_a*outer_w,h=core_h);
            else gearbox(
                gen = gen, scl = scl, planets = planets, layer_h_ = layer_h_, gh_ = gh_, pt = pt, of = of, nt = nt,
                sgm = sgm, outer_d_ = outer_d_-2*teeth_a*outer_w_, wall_ = wall_, shaft_d_ = shaft_d_, depth_ratio = depth_ratio,
                depth_ratio2 = depth_ratio2, tol_ = tol_, P = P, bearing_h_ = bearing_h_, ChamferGearsTop = ChamferGearsTop,
                ChamferGearsBottom = ChamferGearsBottom, Knob = 0, KnobDiameter_ = 0,
                KnobTotalHeight_ = 0, FingerPoints = 0, FingerHoleDiameter_ = 0,
                TaperFingerPoints = 0, AT_ = AT_, $fa = $fa, $fs = $fs, $fn = $fn
            );
        }
        // negative volume
        // vertical tracks
        union(){
            r=(outer_d+outer_w/sqrt(2))/2;
            r1=outer_d/2;
            h=gh[mid]/2;
            h1=gh[mid]+gh[mid-1]+bearing_h;
            h2=core_h-addl(gh,mid-2)+AT;
            d=teeth_a*outer_w;
            dz=d/sqrt(3);
            translate([0,0,addl(gh,mid-2)]){
                rotate_extrude()
                    polygon(points=[[r1+AT,0],[r1,0],[r1-d,dz],[r1-d,h-dz],[r1,h],[r1+AT,h]]);
                for(j = [1:16])intersection(){
                        rotate(j*360/16+asin(tol/r1)+360/32)cube([r1+d+AT,r1+d+AT,h2]);
                        rotate(90-360/32+j*360/16-asin(tol/r1)+360/32)cube([r1+d+AT,r1+d+AT,h2]);
                        rotate_extrude()
                            polygon(points=[[r1+d+AT,0],[r1,0],[r1-d*(j%2),dz],[r1-d*(j%2),h1],[r1-d,h1],[r1-d,h2],[r1+d+AT,h2]]);
                }
            }
        }

        translate([0,0,-spring_d/2])cylinder(d=shaft_d,h=core_h/2,$fn=24);
        translate([0,0,core_h/2+spring_d/2])cylinder(d=shaft_d,h=core_h/2,$fn=24);
        translate([0,0,core_h/2-spring_d/2])cylinder(d=spring_d,h=spring_d,$fn=24);
        translate([0,0,core_h/2-spring_d/2])cylinder(d2=spring_d,d1=shaft_d,h=(shaft_d-spring_d)/2,$fn=24);
        translate([0,0,core_h/2+spring_d/2-(shaft_d-spring_d)/2])cylinder(d1=spring_d,d2=shaft_d,h=(shaft_d-spring_d)/2,$fn=24);
    
        // upper secondary lock vertical tracks
        intersection(){
            r=(shaft_d+outer_w/sqrt(2))/2;
            r1=shaft_d/2;
            h=gh[0]*2;
            d=teeth_a2*outer_w;
            dz=d/sqrt(3);
            translate([0,0,addl(gh,modules-1)])rotate_extrude($fn=24)
                polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
            for(j = [0:1])rotate([0,0,180*j])
                translate([r,0,addl(gh,modules-1)])scale([2,1,1])rotate([0,0,45])
                    cylinder(d=outer_w,h=core_h+core_h2+tol+ST,$fn=4);
        }
        // lower secondary lock vertical tracks. TODO: dedup
        intersection(){
            r=(shaft_d+outer_w/sqrt(2))/2;
            r1=shaft_d/2;
            h=gh[0]*2;
            d=teeth_a2*outer_w;
            dz=d/sqrt(3);
            translate([0,0,gh[0]-h])rotate_extrude($fn=24)
                polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
            for(j = [0:1])rotate([0,0,180*j])
                translate([r,0,gh[0]-h])scale([2,1,1])rotate([0,0,45])
                    cylinder(d=outer_w,h=core_h+core_h2+tol+ST,$fn=4);
        }
    
        // false gates - we could make it a lot harder by setting h=gh[0]/2
        intersection(){
            r=(shaft_d+outer_w/sqrt(2))/2;
            r1=shaft_d/2;
            h=gh[0]/2+fg;
            d=teeth_a2*outer_w;
            dz=d/sqrt(3);
            translate([0,0,addl(gh,modules-1)])rotate_extrude($fn=24)
                polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
            for(i = [-1:2:1], j = [0:1])rotate([0,0,90+180*j+i*30])
                translate([r,0,addl(gh,modules-1)])scale([2,1,1])rotate([0,0,45])
                    cylinder(d=outer_w,h=core_h+core_h2+tol+ST,$fn=4);
        }
        intersection(){
            r=(shaft_d+outer_w/sqrt(2))/2;
            r1=shaft_d/2;
            h=gh[0]/2+fg;
            d=teeth_a2*outer_w;
            dz=d/sqrt(3);
            translate([0,0,gh[0]-h])rotate_extrude($fn=24)
                polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
            for(i = [-1:2:1], j = [0:1])rotate([0,0,90+180*j+i*30])
                translate([r,0,gh[0]-h])scale([2,1,1])rotate([0,0,45])
                    cylinder(d=outer_w,h=core_h+core_h2+tol+ST,$fn=4);
        }
        
        // track
        r=(shaft_d+outer_w/sqrt(2))/2;
        r1=shaft_d/2;
        h=gh[0]/2;
        d=teeth_a2*outer_w;
        dz=d/sqrt(3);
        difference(){
            translate([0,0,addl(gh,modules-1)])
                rotate_extrude($fn=24)
                    polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
                // end stops
                for(j = [0:1])rotate([0,0,90+180*j])
                    translate([r,0,addl(gh,modules-1)])scale([2,1,1])rotate([0,0,45])
                        cylinder(d=outer_w*2,h=core_h+core_h2+tol+ST,$fn=4);
        }
        difference(){
            translate([0,0,gh[0]/2])
                rotate_extrude($fn=24)
                    polygon(points=[[0,0],[r1,0],[r1+d,dz],[r1+d,h-dz],[r1,h],[0,h]]);
                // end stops
                for(j = [0:1])rotate([0,0,90+180*j])
                    translate([r,0,gh[0]/2])scale([2,1,1])rotate([0,0,45])
                        cylinder(d=outer_w*2,h=core_h+core_h2+tol+ST,$fn=4);
        }
    }
}
