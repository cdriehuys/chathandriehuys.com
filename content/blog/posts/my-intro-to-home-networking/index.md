---
title: "My Introduction to Home Networking"
description: >
  How a simple wifi upgrade took me down the rabbit hole that is home
  networking.
date: 2020-04-14T16:58:07-04:00
tags:
  - Homelab
  - Networking
  - Ubiquiti
draft: true
---

When I moved into a new apartment after graduating from college, my two
roommates and I were excited because the apartment complex had Google Fiber
available. What could be more exciting to fresh college graduates than gigabit
internet, right?

I scheduled an appointment, a tech came to the apartment, and the first thing he
asked me was "Where do you want the network box?". After thinking for all of two
seconds, I replied "In the closet with the patch panel." My logic was that I
wanted to utilize the cat5 cables that were already run through the apartment,
so it made the most sense to place the network box where those cables were
accessible.

After the installation, I terminated the cables in the patch panel, connected
the cables that we actually wanted to use to the network box, and ran some speed
tests to bask in the glorious gigabit speeds.

# Wifi? What's That?

Since my daily driver is a desktop with a wired connection, I don't use wifi for
much, so I had no reason to suspect anything was amiss with our network. Every
now and then, one of my roommates would mention that they had to restart the
network box or how they couldn't get wifi in the living room. I was starting to
wonder what was wrong with our setup. Maybe you can spot the issue here.

{{< img caption="Our original wifi setup." src="original-wifi.png" >}}

The final straw came on one of the first warm days of 2020. One of my roommates
and I decided to sit on the porch and get some work done. We pulled up our
chairs, opened our laptops, and *WHAT??? No internet???*

Of course, now that this issue had affected me, something had to be done about
it.

# My Introduction to ~~Cocaine~~ Ubiquiti

At this point, I had some idea that the location (and possibly quality) of our
network box was heavily impacting our wireless speeds throughout the apartment.
After a bit of research, I came to the conclusion that disabling the wireless
network broadcast from the network box and adding a standalone access point was
the best solution to our problem.

Now if you've researched home networking before, there's a good chance you've
come across Ubiquiti before. Their UniFi line in particular is aimed towards the
prosumer/small business market. As a newcomer to the networking space, I'll
admit I was drawn in by the sleek looks and polished appearance of their
software. Along with good reviews from people such as
[Troy Hunt][troy-hunt-ubiquiti], I was sold on the
[UniFi FlexHD Access Point][unifi-flexhd] almost immediately.

This was certainly an impulsive decision on my part, and I'm sure there are
other access points out there that are much cheaper and can do exactly what I
need (ie broadcast a basic wireless network), but I was curious and figured that
one access point would not be a major commitment.

## FlexHD Setup

A week later, the access point was at my door, and I was ready to install it.
After pulling it out of the box, my first thought was "Wow, that's small." I had
seen the comparison photo with the Coke can, but I was still impressed.

I only had two hiccups during setup. The first was wondering why a cat5 cable
wasn't working only to discover that there were actually two cables in the rats
nest I was working with. The other had to do with connecting to the FlexHD from
the mobile app.

After connecting a cable from the router to the PoE injector supplied with the
FlexHD and then to the FlexHD itself, the access point booted up, and I could
access it from the UniFi Network app. I wanted to replace our existing wireless
network broadcast from the network box with an identical network broadcast from
the FlexHD. To do that, I first disabled the wireless network coming from the
Google Fiber network box. After that, I could not connect to the FlexHD from the
mobile app. Admittedly, this was a reading comprehension error on my part, as
the app specifically states:

> Access points, switches, and gateways __on your local network__ will be shown
> here.
>
> &mdash; "UniFi Network" app, 2020

This was mostly confusing to me because when initially searching for devices to
connect to, the app prompted me for Bluetooth permissions, so I thought that's
all that was needed for the connection. After approximately ten minutes of head
scratching and factory resetting, I realized that disabling the wireless network
was the only change I had made. Once I enabled it, lo-and-behold, I could
connect to the FlexHD again.

My second (and more successful) attempt at setting up the FlexHD looked like:

1. Set up the FlexHD to broadcast a network with a different SSID than our
   original network.
2. Disable the network broadcast by the Google Fiber network box.
3. Rename the network broadcast from the FlexHD to have the same SSID as the
   original network.

## Results

It turns out that placing the access point closer to where the wifi is actually
used helps a great deal. I am also hypothesizing that the original network box
being placed in a closet and surrounded with metal was not helping either. With
the FlexHD, I saw speeds go from approximately 20 Mbps to 200 Mbps on my laptop,
and in some cases I saw speeds up to ~100 times better on my phone.

I took some [pre-upgrade][bench-pre-upgrade] and [post-upgrade][bench-new-wifi]
benchmarks, which are published [on GitHub][home-network-github].

I'm also super proud of the professional quality installation job:

{{< img caption="The FlexHD powered by the included PoE injector. I probably need more cables."
        src="flexhd.jpg" >}}

Unfortunately for my wallet, I am planning to expand our network with more UniFi
products. This will be a good opportunity to compare how the FlexHD is managed
as a standalone device versus when it's managed by a controller.

# Pi-hole

With the network closet already cracked open, I finally got around to setting up
a [Pi-hole][pi-hole] using the Raspberry Pi that I've had sitting around for the
last ~6 years. The installation itself was fairly straightforward. I used the
bash script from the project's website to start the installation, accepted the
default options, and was up and running in about five minutes.

From my Google Fiber account, I was then able to give the Pi a static IP
address and modify the DNS settings to point to the Pi-hole. I saw the client
count on the Pi-hole slowly increase (presumably as the DHCP renewal process
occurred for each client).

I was actually surprised at the number of queries that have already been
blocked. Everybody on the network uses ad-blockers, and yet in the three days
the Pi-hole has been running, it has blocked over 1,800 queries.

{{< img caption="Pi-hole statistics after the first three days."
           src="pi-hole-stats.png" >}}

The Raspberry Pi was also added to the network in a highly organized and
professional manner:

{{< img caption="The network closet where the fiber line enters the apartment. Includes the network box, a switch, a Philips Hue controller, and now a Pi-hole."
           src="network-closet.jpg" >}}

## Caveats

The only issues with the Pi-hole so far revolve around IPv6. Google Fiber does
not provide an option to customize DNS for IPv6 nor does it provide an option to
disable IPv6, so devices that connect over IPv6 do not go through the Pi-hole.
So far this primarily affects my Android phone.

Additionally, I noticed a lot of software getting installed locally during the
Pi-hole installation, so I may look into running Pi-hole in a Docker container
so that there are no conflicts if I want to run other things on the Pi.

# Moving Forward

As a web developer who works primarily over the internet, I of course know
everything there is to know about networking.

{{< img caption="Proof of my knowledge." src="network-knowledge.jpg" >}}

In reality, despite being a web developer who works primarily over the internet,
I know very little about networking. Apart from configuring DNS for web servers
and running janky cables across the floors, walls, and ceilings of a house that
wasn't wired for ethernet, I have very little networking experience.

I'm hoping to expand the home network soon to be a place where I can experiment
and learn more. I think my first task after obtaining some more capable
networking equipment is going to be attempting to create VLANs for the different
devices on the network. Specifically I would like to segregate trusted devices
from IoT devices.

If you're in the same boat as me and trying to experiment more at home, I highly
recommend visiting the [/r/homelab subreddit][reddit-homelab] to see some of the
~~absolutely insane~~ practical things you can accomplish[^related-subreddits].
I've also learned a lot by lurking in the subreddit's Discord channel and seeing
what kind of questions people ask along with the responses they get.

[^related-subreddits]: Also [/r/HomeServer](https://reddit.com/r/HomeServer) and
                       [/r/selfhosted](https://reddit.com/r/selfhosted).

[bench-new-wifi]: https://github.com/cdriehuys/home-network/blob/master/speedtests/new-access-point.csv
[bench-pre-upgrade]: https://github.com/cdriehuys/home-network/blob/master/speedtests/pre-upgrade.csv
[home-network-github]: https://github.com/cdriehuys/home-network
[pi-hole]: https://pi-hole.net/
[reddit-homelab]: https://reddit.com/r/homelab
[troy-hunt-ubiquiti]: https://www.troyhunt.com/ubiquiti-all-the-things-how-i-finally-fixed-my-dodgy-wifi/
[unifi-flexhd]: https://store.ui.com/collections/unifi-network-access-points/products/unifi-flexhd
