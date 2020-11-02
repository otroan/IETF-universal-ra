%%%
title = "The Universal IPv6 Configuration Option"
ipr = "trust200902"
area = "Internet"
workgroup = "Network Working Group"

[seriesInfo]
status = "standard"
name = "Internet-Draft"
value = "draft-troan-6man-universal-ra-option-03"
stream = "IETF"

[[author]]
initials="T."
surname="Winters"
fullname="T. Winters"
organization = "QA Cafe"
  [author.address]
  email = "tim@qacafe.com"

[[author]]
initials="O."
surname="Troan"
fullname="O. Troan"
organization = "cisco"
  [author.address]
  email = "ot@cisco.com"


%%%

.# Abstract

One of the original intentions for the IPv6 host configuration, was to configure
the network-layer parameters only with IPv6 ND, and use service discovery for
other configuration information. Unfortunately that hasn't panned out quite as
planned, and we are in a situation where all kinds of configuration options are
added to RAs and DHCP. This document proposes a new universal option for RA and
DHCP in a self-describing data format, with the list of elements maintained in
an IANA registry, with greatly relaxed rules for registration.

{mainmatter}

# Introduction

This document proposes a new universal option for the Router Advertisement IPv6
ND message [@!RFC4861] and DHCPv6 [@!RFC8415]. Its purpose is to use the RA and
DHCP messages as opaque carriers for configuration information between an agent
on a router or DHCP server and host / host application.

DHCP is suited to give per-client configuration information, while the RA
mechanism advertises configuration information to all hosts on the link. There
is a long running history of "conflict" between the two. The arguments go; there
is less fate-sharing in DHCP, DHCP doesn't deal with multiple sources of
information, or make it more difficult to change information independent of the
lifetimes, RA cannot be used to configure different information to different
clients and so on. And of course some options are only available in RAs and some
options are only available in DHCP.

While this proposal does not resolve the DHCP vs RA debate, it proposes a
solution to the problem of a very slow process of standardizing new options, and
the IETF spending an inordinate amount of time arguing over new configuration
options.

# Conventions

The key words "**MUST**", "**MUST NOT**", "**REQUIRED**", "**SHALL**", "**SHALL
NOT**", "**SHOULD**", "**SHOULD NOT**", "**RECOMMENDED**", "**MAY**", and
"**OPTIONAL**" in this document are to be interpreted as described in RFC 2119
[@!RFC2119].

Additionally, the key words "**MIGHT**", "**COULD**", "**MAY WISH TO**", "**WOULD
PROBABLY**", "**SHOULD CONSIDER**", and "**MUST (BUT WE KNOW YOU WON'T)**" in
this document are to interpreted as described in RFC 6919 [@!RFC6919].

# Introduction

This document specifies a new "self-describing" universal configuration option.
Currently new configuration option requires "standards action". The proposal is
that no future IETF document will be required. The configuration option is described
directly in the universal configuration IANA registry.

# The Universal IPv6 Configuration option

The option data is described using the schema language CDDL [@!RFC8610], encoded
in CBOR [@!RFC7049].

~~~ ascii-art
     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |     Type      |    Length     |   Data ...
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
~~~
Figure: IPv6 Configuration Option Format

Fields:

Type:

: 42 for Universal IPv6 Configuration Option

Length:
: The length of the option (including the type and length fields) in units of 8 octets.

Data:
: CBOR encoded data.

The Option is zero-padded to nearest 8-octet boundary.

Example:


``` json
{
    "ietf": {
        "dns": {
            "dnssl": [
                "example.com"
            ],
            "rdnss": [
                "2001:db8::1",
                "2001:db8::2"
            ]
        },
        "nat64": {
            "prefix": "64:ff9b::/96"
        }
        "rio": {
            "routes": [
                "rio_routes": {
                    "prefix": "::/0",
                    "next-hop": "fe80::1"
                }
            ]
        }
    }
}
```


The universal IPv6 Configuration option MUST be small enough to fit within a
single IPv6 ND or DHCPv6 packet. It then follows that a single element in the
dictionary cannot be larger than what fits within a single option. Different
elements can be split across multiple universal configuration options (in
separate packets). All IANA registered elements are under the "ietf" key in the
dictionary. Private configuration information can be included in the option
using different keys.

If information learnt via this option conflicts with other configuration
information learnt via Router Advertisement messages or via DHCPv6, that is
considered a configuration error. How those conflicts should be resolved is left
up to the implementation.

# Implementation Guidance

The purpose of this option is to allow users to use the RA or DHCPv6 as an opaque
carrier for configuration information without requiring code changes in the
option carrying infrastructure.

On the router or DHCPv6 server side there should be an API allowing a user to add
an element, e.g. a JSON object [@RFC8259] or a pre-encoded CBOR string to RAs
sent on a given interface or to DHCPv6 messages sent to a client.

On the host side, an API SHOULD be available allowing applications to subscribe
to received configuration elements. It SHOULD be possible to subscribe to
configuration object by dictionary key.

The contents of any elements that are not recognized, either in whole or in
part, by the receiving host MUST be ignored and the remainder of option's
contents MUST be processed as normal.

# Implementation Status

The Universal IPv6 configuration option sending side is implemented in VPP
(https://wiki.fd.io/view/VPP).

The implementation is a prototype released under Apache license and available
at:
https://github.com/vpp-dev/vpp/commit/156db316565e77de30890f6e9b2630bd97b0d61d.

# Security Considerations

Unless there is a security relationship between the host and the router (e.g.
SEND), and even then, the consumer of configuration information can put no trust
in the information received.

# IANA Considerations

IANA is requested to add a new registry for the Universal IPv6 Configuration
option. The registry should be named "IPv6 Universal Configuration Information
Option". Changes and additions to the registry require expert review [@RFC8126].

The schema field follows the CDDL schema definition in [@!RFC8610].

The IANA is requested to add the universal option to the
"IPv6 Neighbor Discovery Option Formats" registry with the value
of 42.

The IANA is requested to add the universal option to the
"Dynamic Host Configuration Protocol for IPv6 (DHCPv6) Option
Codes" registry.

## Initial objects in the registry

The PVD [@RFC8801] elements (and PIO, RIO [@RFC4191]) are included to provide an
alternative representation for the proposed new options in that draft.


~~~

   +-------------------------------------------------+-----------+
   | CDDL Description                                | Reference |
   +---------------+---------------------------------+-----------+
   | ietf = {                                        |           |
   |   ? dns : dns				     |		 |
   |   ? nat64: nat64				     |		 |
   |   ? ipv6-only: bool			     |		 |
   |   ? pvd : pvd				     |		 |
   |   ? mtu : uint .size 4			     |		 |
   |   ? rio : rio				     |		 |
   | }						     |		 |
   |                                                 |           |
   | pio = {                                         | [RFC4861] |
   |   prefix : tstr                                 |           |
   |   ? preferred-lifetime : uint                   |           |
   |   ? valid-lifetime : uint                       |		 |
   |   ? a-flag : bool				     |		 |
   |   ? l-flag : bool				     |		 |
   | }						     |		 |
   |                                                 |           |
   | rio_route = {				     | [RFC4191] |
   |   prefix : tstr				     |		 |
   |   ? preference : (0..3)			     |		 |
   |   ? lifetime : uint			     |		 |
   |   ? mtu : uint .size 4			     | [this]    |
   |   ? nexthop: tstr                               |           |   
   | }						     |		 |
   | rio = {					     |		 |
   |   routes : [+ rio_route]			     |		 |
   | }						     |		 |
   |                                                 |           |
   | dns = {                                         | [RFC8106] |
   |  dnssl : [* tstr]                               |           |
   |  rdnss : ipv6-addresses : [* tstr]              |           |
   |  ? lifetime : uint                              |           |
   | }                                               |           |
   |                                                 |           |
   | nat64 = {	                   		     | [RFC7050] |
   |   prefix : tstr                                 |		 |
   | }     			                     |		 |
   | ipv6-only : bool                                | [v6only]  |
   |						     |           |
   | pvd = {                                         | [pvd]     |
   |   fqdn : tstr				     |           |
   |   uri : tstr				     |		 |
   |   ? dns : dns				     |		 |
   |   ? nat64: nat64				     |		 |
   |   ? pio : pio				     |		 |
   |   ? rio : rio				     |		 |
   | }						     |		 |
   +---------------+---------------------------------+-----------+
~~~

{backmatter}
