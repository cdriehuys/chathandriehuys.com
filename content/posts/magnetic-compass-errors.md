---
title: "Magnetic Compass Errors"
date: 2024-01-27T22:13:05Z
tags:
  - Flying
---

A magnetic compass has various sources of error that must be taken into account
when taking a reading from it. Because magnets are magical and confusing, the
errors and corresponding corrections aren't always intuitive, so let's walk
through them.

<!--more-->

## Variation and Deviation

These are the two simplest sources of error to consider.

Variation is caused by the difference between magnetic north, and true north.
Isogonic lines (lines of equivalent variation) are typically indicated on a
sectional chart. To adjust for variation, either &deg;E or &deg;W, subtract or
add from true course, respectively.

> East is least, west is best

Deviation is caused by the various magnetic fields contained in the aircraft. It
can be reduced through airplane-specific calibration of the compass, and
accounted for by using a compass card which shows deviation corrections for
various headings.

## Magnetic Dip

The Earth's magnetic field is only parallel to the surface at the magnetic
equator. As you move towards the poles, the magnetic field lines have an
increased vertical component. This causes the north side of the compass to point
down in the northern hemisphere, and up in the southern hemisphere.

Magnetic dip is responsible for two types of compass errors: turning errors, and
acceleration errors.

### Turning Errors

When turning from a northernly heading, the compass tends to lag the turn,
sometimes even showing a turn in the opposite direction. Turning from a
southernly heading shows the opposite behavior, and the compass will lead the
turn.

> **U**ndershoot **N**orth, **O**vershoot **S**outh

### Acceleration Errors

During acceleration and deceleration, the compass has a tendency to erroneously
indicate a turn. This is most pronounced when on on east/west heading, and is
absent when on a north/south heading. When accelerating, the compass will show a
turn to the north, and when decelerating, the compass will show a turn to the
south. This behavior is reversed in the southern hemisphere.

> **A**ccelerate **N**orth, **D**ecelerate **S**outh

To understand why we see the magnetic compass shift during acceleration, we have
to understand a little bit about how the compass is assembled. The magnetic
portion of the compass is suspended inside its enclosure such that the magnetic
portion remains aligned with the Earth's magnetic field while the housing and
the rest of the airplane rotates around it. Because the vertical component of
the magnetic field is not useful for purposes of navigation, the compass is
constrained to only rotate in the horizontal plane. This is done by dropping the
compass' center of gravity below the pivot point it's mounted on, and results in
only the horizontal component of the magnetic field affecting the compass
indication when the assembly is level.

During acceleration and deceleration, the pendulous nature of the mounting means
the compass will lean nose-down or nose-up, respectively. This causes the
vertical component of the magnetic field to have an effect on the compass
indication, causing the errors described above.

## References

The material this is based on can be found in _The Pilot's Handbook of
Aeronautical Knowledge_, Chapter 8, under the section _Compass Systems_.
