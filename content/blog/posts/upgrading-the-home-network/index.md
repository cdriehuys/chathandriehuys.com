---
title: "Upgrading the Home Network"
date: 2020-05-09T12:12:43-04:00
description: >
  My experience overhauling my home network through overkill and excess.
tags:
 - Homelab
 - Networking
 - Ubiquiti
draft: true
---

In my [last post]({{< ref "/blog/posts/my-intro-to-home-networking" >}}), I
dipped my toes into the pool that is the Unifi product line. The money-sucking
monster that lives in that pool immediately grabbed me and pulled me under,
refusing to let me out until I went all-in.


# Hardware

This is what I ended up with:

- [Tripp Lite 9U Rack](https://smile.amazon.com/gp/product/B004VUOAPG)
- [Unifi Dream Machine Pro](https://store.ui.com/collections/unifi-network-routing-switching/products/udm-pro)
- [Unifi 24 Port Switch (US-24-250W)](https://smile.amazon.com/gp/product/B00OJZUQ24)
- [Unifi 8 Port Switch (US-8)](https://store.ui.com/collections/unifi-network-routing-switching/products/unifi-switch-8)
- [Cable Matters 24 Port Keystone Patch Panel](https://smile.amazon.com/gp/product/B0072JVT02)
- [StarTech 1U Shelf](https://smile.amazon.com/gp/product/B071RN1858)
- [CyberPower Surge Protector](https://smile.amazon.com/gp/product/B00077INZU)
- [Unifi 48V PoE Injector](https://smile.amazon.com/gp/product/B00HXT8MNI)
- [Monoprice RJ45 Cat5e Inline Coupler Keystone Jack (x24)](https://www.monoprice.com/product?c_id=303&cp_id=30307&cs_id=3030706&p_id=7285&seq=1&format=2)
- [Monoprice Velcro Ties](https://www.monoprice.com/product?c_id=303&cp_id=30310&cs_id=3031005&p_id=6476&seq=1&format=2)

*Did I need it? __No.__*

*Is it overkill? __Yes.__*

*Did I want it? __Absolutely.__*

{{< img caption="Some of the boxes I got (plus dog tax)."
        src="boxes.jpg" >}}

## Rationale

While there wasn't a whole lot of thought that went into these purchases, I do
have reasoning behind some of these purchases.

### Tripp Lite 9U Rack

I currently live in an apartment with a small corner available to place a rack.
This corner is small enough that a full-depth rack would absolutely not fit, so
I started searching for shallower racks meant for networking and media
equipment. This rack has the benefit of being enclosed for a small amount of
noise abatement as well as looking passable as a furniture piece.

### Unifi Dream Machine Pro

I was originally going to purchase a security gateway and cloud key as separate
pieces, but after a little more reading, I found that the USG is not ready for
gigabit speeds. After weighing this against the numerous online complaints
documenting the advertised but not-yet-implemented features and the frequent
bugs, I decided to just go for it. What's the worst that could happen, right?

More on this later.

### The Switches

For the main rack, I chose the 250W 24 port PoE switch. I wanted to make sure
that I had enough ports for future expansion, and I could envision myself using
16 ports, so here we are. The 8 port switch is for the network panel in our
apartment. I needed a switch in the panel so that I could connect the ethernet
ports located in each of the 3 bedrooms that are terminated at the panel. The
nice thing about the 8 port switch I chose is that it can be powered using PoE,
which eliminates one more cable from the panel.


# Installation

The physical installation process was pretty straightforward, although I still
have no idea how you mount the first item in a rack without three arms.

{{< img caption="With the door closed, this ended up looking like just a bunch of cables in a box..."
        src="udmp-and-switch-24.jpg" >}}

The sight of the Raspberry Pi and Hue Bridge on top of the rack sickened me, so
I immediately turned around and placed another order:

{{< img caption="Starting to look like something other than just cables."
        src="with-shelf.jpg" >}}

One patch panel and about an hour of cable management later:

{{< img caption="Look at all the blinky lights."
        src="clean-front.jpg" >}}

## Network Panel

Moving the majority of the equipment away from the network panel allowed me to
clean up the panel and gave me my biggest aesthetic win yet.

{{< img caption="The door actually closes now."
        src="closet-cleanup.jpg" >}}

This is one of the places I goofed though. The PoE injector and patch cable
could be removed if I used a USB power adapter for the fiber jack. Same number
of power cables and one less patch cable. Oh well, it
still looks good.


# Configuration

With all the physical components of the network in place, I moved on to
configuring the software.

## UniFi

To configure the network, I connected the fiber box to the WAN port of the
UDM-Pro and connected my laptop to one of the LAN ports.

After navigating to 192.168.1.1, the Unifi setup guide appeared. The only special
setup I had to do was to configure the VLAN ID and QoS tag for the WAN as per
[this Reddit post][reddit-ubiquiti-google-fiber]. This was only necessary
because I completely removed the Google Fiber network box from the network.
Strangely, the UniFi setup kept failing the internet connectivity check until I
pressed the "Troubleshoot" button, at which point the internet immediately
started working. Go figure.

I have seen one or two posts floating around that suggest the VLAN and QoS are
no longer necessary, but omitting or changing either setting eventually affects
internet connectivity for me.

After establishing a connection to the outside world, I moved on to adopting the
switches and FlexHD into my network. The switches immediately appeared for
adoption, but the FlexHD did not initially show up. Because I am impatient, I
factory reset the FlexHD, and it eventually showed up in the interface
approximately five minutes later. I don't know if the reset was necessary or if
the fact that the access point had been configured in "standalone" mode had
anything to do with this, but it works now.

## Pi-hole

Configuring the network to use the Pi-hole as its DNS server was super easy once
I found the setting in the UniFi interface. It's under __Settings > Networks >
LAN > DHCP Name Server__. By default, there are no restrictions on traffic
between VLANs, so configuring a network to use the Pi-hole for DNS is as easy as
entering the IP address in the aforementioned field. If you are using the guest
network feature, the Pi-hole's IP address must be added to the
"Pre-Authorization Access" list under __Settings > Guest Control__ to punch a
hole through the default policies that prevent devices on the guest network from
accessing other devices on the network.

The only hangup I ran into was that at some point during my fiddling, the
Raspberry Pi crashed which caused the internet to be inaccessible. It took me a
few minutes to discover that the blinky lights on the pi were not as blinky as
usual, but once I did, a power cycle fixed the problem. This does suggest that
running two Pi-holes is probably a good idea for such a crucial piece of the
network.


# The UniFi Dream Machine Pro

From what I've seen in real-world use of the UDM-Pro, the device is working
exactly as intended. It's been rock solid and maintained gigabit speeds even
with DPI enabled which is all I really need right now.

I know there is a [laundry list of missing features][udm-missing-features], but
as a newcomer to the world of UniFi, I can't miss something that I haven't had
before. However, it is disappointing there isn't a parallel to the JSON config
files on prior platforms. Providing a way to work around features that aren't
yet available in the UI goes a long way towards shifting perception from "this
is an unfinished product" to "this is the early stages of a product".

Lacking any sort of networking experience or qualifications, I don't feel
comfortable passing any sort of judgement on whether anyone else should buy the
UDM-Pro. For me, it has done exactly what I need it to do, and I have yet to
encounter a task I would like to do that is not supported.

# Next Steps

Now that I have the base of the network set up, there are a few other tasks I
have in mind in order to improve or expand the home lab.

* Label cables
  * It would be nice to know which cables run where using something other than
    a three-color post-it note scheme.
* Segregate devices with VLANs
  * I would like to separate our computers/phones from the Chromecasts and
    Google Homes on the network.
  * The biggest obstacle here is avoiding disruption of any existing workflows
    such as casting to the Chromecast or controlling smart lights.
* File server
  * This will probably be the next major task.
  * I want a place that I can back up my computers to as well as something that
    can be the backing storage for VMs, Kubernetes clusters, etc.
* More compute resources
  * I would like to play around with self-hosting apps such as Plex or standing
    up a Kubernetes cluster which are a little more that a first-generation
    Raspberry Pi can handle.
  * This seems to depend on getting some form of network storage available
    first.

[reddit-ubiquiti-google-fiber]: https://www.reddit.com/r/Ubiquiti/comments/9onmx7/google_fiber_with_usg_simple/
[udm-missing-features]: https://community.ui.com/questions/UDM-Features-missing-from-UDM-and-or-controller/faa5646e-476b-41ae-8c3b-4ef418e88028?page=1
