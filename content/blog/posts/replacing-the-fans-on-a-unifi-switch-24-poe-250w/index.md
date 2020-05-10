---
title: "Replacing the Fans on a UniFi Switch 24 Poe 250w"
date: 2020-05-10T10:19:36-04:00
description: >
  Replacing the fans on a UniFi switch to reduce noise.
tags:
  - Hardware
  - Homelab
  - Noctua
  - Ubiquiti
---

I have two pieces of hardware with fans in my home networking rack. The first is
a UniFi Dream Machine Pro which has never been audible. The second on the other
hand, a UniFi Switch 24 PoE 250W, has fans audible from approximately ten feet
away. Perhaps slightly less with the air conditioning running. This was highly
annoying as this radius encompasses the couch in our living room, somewhere we
frequently occupy. Armed with the knowledge that other people had done a fan
replacement on this switch, I decided to do the same.

The first step was to find some replacement fans. The brand that immediately
comes to mind when I think of quiet fans is Noctua, a company known for their
silent fans and, well, *unique* color scheme. For this project, I was replacing
the two 40x20 millimeter fans that come with the switch, which corresponds to
Noctua's [NF A4x20 FLX model][noctua-nf-a4x20-flx].

{{< img src="noctua-nf-a4x20-flx.jpg" >}}

The process of disassembling the switch was fairly straightforward. Remove the
seven screws from the sides and back of the switch. The shell can then be slid
backwards to disengage the tabs at the front, and then lifted off to separate it
completely.

{{< img caption="So this is what the inside of a switch looks like..."
        src="switch-internals.jpg" >}}

Unfortunately the connectors on the Noctua fans were not long enough to reach
the fan connectors on the main board, but Noctua accounts for this and provides
the equipment necessary to splice the existing fan wires together with the
included "OmniJoin" connector. While it did feel wrong to cut through the
existing fan wires, I found joining the "OmniJoin" adapter to the existing wires
as easy as the manual made it out to be.

{{< img caption="One of the spliced connections."
        src="splice.jpg" >}}

The next obstacle I encountered was mounting the fans. The screws used to mount
the stock fans were too small to attach to the Noctua fans, and the screws
included with the new fans were too large to fit in the mounting holes. I
decided to try the rubber anti-vibration mounts included with the fan kit, and
after much struggling with a pair of pliers, I managed to pull the rubber mounts
through the mounting holes that were clearly smaller than intended. Then I
realized that the mounts would not be able to protrude from the side of the
case, as the shell sits flush with the case. I ended up trimming the mounts down
to about 1 millimeter which probably reduces the strength of the mounts, but I
don't foresee this being a major issue. If the mounts do end up failing, I will
probably attach them with Velcro instead.

{{< img caption="The fans mounted to pull air out of the case. Note the mounts protruding from the side of the case."
        src="fans-mounted.jpg" >}}

After sliding the shell back into place over the protruding fan mounts, I
screwed it back into place. A tip here is to start with the screws at the back
of the case which will align the holes on the sides.

With the new fans, the switch is inaudible until about two feet away. Mission
accomplished. I do regret not getting temperature readings before doing the
replacement, but right now the switch is sitting at 65&deg;&nbsp;C while
providing about 10 W of PoE power. While this seems to be a bit higher than
average, it is still well within the standard operating temperatures.

```
RackSwitch-US.v4.0.80# swctrl env show
General Temperature (C): 65
Temp Sensor      Temp (C)     State            Max Temp (C)  Alert Temp (C)
===============  ===========  ===============  ============  ==============
TEMP-1           51           Normal           53            75
TEMP-2           38           Normal           39            75
PoE-01           57           Normal           59            80
PoE-02           65           Normal           65            75
PoE-03           65           Normal           65            75
PoE-04           63           Normal           65            75
PoE-05           61           Normal           61            70
PoE-06           59           Normal           61            70

Fan Duty Level: 100
Fan              Speed       Duty level  State
===============  ==========  ==========  ===============
Fan-1            0           100         Operational
Fan-2            0           100         Operational
Fan-3            0           100         Operational
Fan-4            0           100         Operational
```

If these temperatures become a problem, I will populate the two empty intake
fan slots. Overall I'm very happy with the change, and more importantly, so are
my roommates.

[noctua-nf-a4x20-flx]: https://smile.amazon.com/Noctua-NF-A4x20-FLX-Premium-40x20mm/dp/B072JK9GX6
