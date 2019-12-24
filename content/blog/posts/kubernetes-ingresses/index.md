---
title: Kubernetes Ingresses
description: >
  Musings on how Kubernetes ingresses work and their implications for managing
  traffic to a cluster.
date: 2019-12-22
tags:
  - Kubernetes
  - Routing
---

I've been playing around with Kubernetes for a little bit now and I wanted to
share some of my thoughts on the process of routing external traffic into a
Kubernetes cluster. After all, having a web-scale, enterprise-grade service mesh
continuously deployed across multiple cloud providers to withstand the rigors of
chaos engineering isn't much good if customers can't access the services being
provided[^buzz].

# Ingresses

Kubernetes' provided [`Ingress`][k8s-ingress] objects are the default way of
routing, well, *ingress* traffic from outside your cluster to your service.
Let's look at an example `Ingress` from the Kubernetes documentation:

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: test-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        backend:
          serviceName: test
          servicePort: 80
```

All this `Ingress` does is route HTTP traffic entering the cluster that matches
the path `/testpath` (on any host) to port 80 of the `test` service. 

# Rewrites

The `Ingress` carries this annotation:

```yaml
nginx.ingress.kubernetes.io/rewrite-target: /
``` 

This means that traffic matching any of the paths in the rules of the `Ingress`
will be rewritten to exclude the matched path before being routed to the target
service. For example, external consumers of the service would issue a request to
`/testpath/resources/foo`, but the `test` service would see the request's path
as `/resources/foo`. There are also ways to use regular expressions to
manipulate the path seen by the service.

In my experience, this works seamlessly with any service that doesn't need to
know its own external URL. The most prevalent occurrence where this breaks down
is when the application serves content that references other paths for things
like images, JavaScript, or links for buttons. This also breaks any redirects
that use absolute URLs.

I would like to clarify that these issues related to external URLs are not
unique to Kubernetes and will occur with any proxied application that does URL
rewriting, and that these issues can be solved with an application that can be
configured to know about the URL rewriting that is done. However, this is a new
issue for many whose first exposure to this problem occurs during their foray
into Kubernetes which is why I wanted to call it out.

# External Access

Even after deploying an `Ingress` in your cluster, you may notice that you still
cannot access your service from outside the cluster. This is because there is
still no piece of the infrastructure that is actually accepting the packets of
external traffic from outside your cluster and passing them to the routing
mechanism that the `Ingress` resources describe.

This is where [ingress controllers][k8s-ingress-controller] come into play. In
my mind, this is an area in which the Kubernetes documentation needs more work.
It is understandable that the documentation is not cohesive here because each
controller is responsible for a drastically different mechanism for traffic
routing. On one side we have the NGINX ingress controller which simply runs an
NGINX instance on each node that routes traffic into your cluster, and on the
other we have controllers that create a load balancer on your cloud platform of
choice. Due to the differences between each controller, it makes sense for the
Kubernetes team to encapsulate this resource and have providers create their own
controllers with their own documentation.

While this delegation of responsibility makes sense, it still makes it difficult
for users of Kubernetes, specifically because they lose the consistency and
standards of the rest of the documentation. I don't really have a proposed
solution for this, but I think it is important to understand what is lost by
delegating documentation responsibilities to third parties.

# Load Balancers

While the NGINX ingress controller is typically recommended for experimentation,
it is not particularly useful when deploying to a cloud platform where nodes are
ephemeral and hostnames may change at any time. This is why there are specific
ingress controllers for the major platforms which will spin up a load balancer
for you that automatically adapts to nodes being created and destroyed.

While these ingresses work well, each `Ingress` resource creates a separate load
balancer, and load balancers aren't cheap. As far as I can tell, there's also no
way to have ingresses share a load balancer.

# Feedback

As always, feel free to reach out to me with further comments or questions on
this topic. I am by no means an expert in any of the topics here, and
corrections are much appreciated.


[^buzz]: Feel free to insert more buzzwords as you see fit.

[k8s-ingress]: https://kubernetes.io/docs/concepts/services-networking/ingress/
[k8s-ingress-controller]: https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/
