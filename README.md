# solid-core-compound-planet
Solid Core Compound Planetary Gearbox

I am attempting to consolidate and modularise (WIP) the codebase for a novel gearbox from various ad-hoc projects. This gearbox is an example of a compound planetary system where multiple planetary gear layers are stacked vertically. With the same number of evenly spaced planets in each layer both the central sun gears and planet gears are synchronised allowing them to be fused. I have not encountered another example of this arrangement and believe it to be of my own invention.

In attempting to distill what makes this design unique, I think it comes down to the following. Conventional wisdom would tell us that for planetary gears to mesh we require [https://woodgears.ca/gear/planetary.html](R=S+2P) where P, R, S are the number of teeth in the Planet, Ring and Sun gears respectively, assuming equal pitch in all. Furthermore, for evenly spaced planets we require N divides R+S evenly. This can be extended to R=S+2P+nN where N is the number of planets and n some small integer if we allow for a ring gear of a different pitch. This places significant restriction on what are considered "valid" combinations of P and S. Observe that this is an overdefined system and given any combination of P and S we can find R such that N divides R+S evenly and the solution space may instead be expressed as R=S+2P+nN+m for some small integer m (determined by P and S).

Given this newfound flexibility in gear selection, it becomes possible to impose further constraints in a compound planetary arrangement such as the synchronised Sun and Planet gears of this example. This concept may also be applied to other arrangements, for example synchronised Ring and Planet gears to drive differentially rotating Sun gears. eg. [Reduction Drive Knob](https://www.thingiverse.com/thing:3562490). Yet more gear ratios become possible with systems incorporating split Sun gears (idlers). For systems which omit the Sun gear entirely and use a Carrier mechanism instead, virtually all such constraints go out the window if we allow gears of slightly different pitch to mesh, which would allow for more extreme gear ratios still.

The idea of adding or subtracting teeth (violating the R=S+2P constraint) from the ring gear emulating cycloidal drive is not new and harks back to [WWII radar gear](https://en.wikipedia.org/wiki/Epicyclic_gearing), however this prevents meshing with the sun gear which is usually omitted and a carrier used instead (unless the number of teeth dropped is a multiple of number of planets). Furthermore synchronisation demands the sun gear teeth be some fixed multiple of the planet gears in each layer, this also demands a non-ideal number of teeth for non-identical gear ratios.

More [conventional designs](https://www.thingiverse.com/gear_down_for_what/designs) obeying R=S+2P are forced to separate sun gears, leaving idlers or [omit them entirely](https://en.wikipedia.org/wiki/File:Rearview_Mirror_Epicyclic_Gears.jpg) in place of carriers or unsupported planet gears. Concentrating drive stresses and limiting torque due to shear forces. This design distributes the drive force along the entire length and elliminates the need for a carrier. The tradeoff is a slightly distorted involute gear profile as we stretch or compress teeth to mesh but well within the tolerances of FDM. Even ideal involute gears suffer from sliding friction away from the pitch point.

First appearance:
[Solid Core Compound Planetary Gearbox (customizable)](https://www.thingiverse.com/thing:3511382) by [tmackay](https://www.thingiverse.com/tmackay) March 23, 2019

Other notable designs (copypasta) over time:

[Simple Toy Robot Arm 5DoF](https://www.thingiverse.com/thing:4555965) by [tmackay](https://www.thingiverse.com/tmackay) July 29, 2020

[Nut Cracker](https://www.thingiverse.com/thing:4470029) by [tmackay](https://www.thingiverse.com/tmackay) June 18, 2020

[Falcon Clamp V2](https://www.thingiverse.com/thing:4436194) by [tmackay](https://www.thingiverse.com/tmackay) June 09, 2020

[Mini Clamp](https://www.thingiverse.com/thing:4427567) by [tmackay](https://www.thingiverse.com/tmackay) June 05, 2020

[Puzzle Cube - Hard Mode](https://www.thingiverse.com/thing:4264931) by [tmackay](https://www.thingiverse.com/tmackay) April 06, 2020

[Puzzle Cube](https://www.thingiverse.com/thing:4176562) by [tmackay](https://www.thingiverse.com/tmackay) February 22, 2020

[Lament Configuration - Hellraiser Puzzle Box](https://www.thingiverse.com/thing:4109303) by [tmackay](https://www.thingiverse.com/tmackay) January 18, 2020

[Planetary Gear Puzzle Box](https://www.thingiverse.com/thing:4034834) by [tmackay](https://www.thingiverse.com/tmackay) December 10, 2019

[Gearbox Demo (Solid Core Compound Planetary)](https://www.thingiverse.com/thing:4027011) by [tmackay](https://www.thingiverse.com/tmackay) December 07, 2019
