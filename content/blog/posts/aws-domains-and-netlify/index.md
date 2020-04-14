---
title: Routing an AWS Registered Domain to Netlify
description: >
  Troubleshooting DNS records, specifically nameservers, when attempting to use
  Netlify's managed DNS for a domain registered through Route 53.
date: 2018-11-27
tags:
  - AWS
  - DNS
  - Netlify
  - Route 53
---

I recently tried to use Netlify's managed DNS with a domain name registered
through AWS and struggled. While it turned out that I was being a bit of an
idiot, I figured I would share the problem and solution here.

## First Attempt

As the instructions state when you attempt to register an externally managed
domain with Netlify, you must switch over the nameservers to the ones managed by
Netlify. Since I have just enough knowledge to be dangerous, I assumed that
creating an `NS` record in the Route 53 hosted zone I created would be enough,
so I went ahead and created the following record:

```
dns1.p01.nsone.net
dns2.p01.nsone.net
dns3.p01.nsone.net
dns4.p01.nsone.net
```

## Domain Verification Errors

Even after waiting the specified 24 hour period, I was still seeing errors with
associated my custom domain with the Netlify deployment.

{{<figure
    caption="The error message displayed by Netlify under the site's domain settings."
    src="check-dns.png"
>}}

Additionally, I could not obtain an SSL certificate for my custom domain.

{{< img caption="SSL certificate cannot by obtained because DNS verification failed."
        src="ssl-dns-failed.png" >}}

## Troubleshooting

The main reason I was confused here was that the results of any `dig` commands
showed the "correct" nameservers.

```
chathan@chathan-desktop: dig +short my-domain.com NS

dns1.p01.nsone.net
dns2.p01.nsone.net
dns3.p01.nsone.net
dns4.p01.nsone.net
```

Additionally, finding the `A` record for the domain from the above nameservers
correctly showed the IP of one of Netlify's load balancers.

```
chathan@chathan-desktop: dig +short @dns1.p01.nsone.net my-domain.com A

104.248.120.187
```

## Solution

After opening a support ticket with Netlify, I received a response indicating
that my nameservers were in fact incorrectly configured. To prove this, they ran
a simply whois query.

```
whois my-domain.com | grep "Name Server"
```

This produced the wrong nameservers which gave me a clue as to where to look.

Instead of creating an `NS` record in the hosted zone Route 53 automatically
creates when you register the domain, you have to go into the details of the
domain itself and set the list of nameservers there.

```
Route 53 -> Registered Domains -> <your domain>
```

{{< img src="aws-nameservers.png" >}}
