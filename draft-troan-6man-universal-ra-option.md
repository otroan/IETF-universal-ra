%%%
title = "The Universal IPv6 Configuration Option"
ipr = "trust200902"
area = "Internet"
workgroup = "Network Working Group"

[seriesInfo]
status = "standard"
name = "Internet-Draft"
value = "draft-troan-6man-universal-ra-option-05"
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
added to RAs. This document proposes a new universal option for RA
in a self-describing data format, with the list of elements maintained in
an IANA registry, with greatly relaxed rules for registration.

{mainmatter}

# Introduction

This document proposes a new universal option for the Router Advertisement IPv6
ND message [@!RFC4861]. Its purpose is to use the RA
messages as opaque carriers for configuration information between an agent
on a router and a host.

DHCP is suited to give per-client configuration information, while the RA
mechanism advertises configuration information to all hosts on the link. There
is a long running history of "conflict" between the two. The arguments go; there
is less fate-sharing in DHCP, DHCP doesn't deal with multiple sources of
information, or make it more difficult to change information independent of the
lifetimes, RA cannot be used to configure different information to different
clients and so on. And of course some options are only available in RAs and some
options are only available in DHCP.

While this proposal does not resolve the DHCP vs RA debate, it proposes a
solution to the problem of a very slow process of standardizing new Router Advertisement options, 
and the IETF spending an inordinate amount of time arguing over new configuration
options in Router Advertisements.  It is possible in the future to use 
the new universal option in DHCP, since this would lead to additional conflict resolution 
an additional document will need to be considered for that.

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

Example of an JSON instance of the option:


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
        },
        "rio": [
            {
                "prefix": "::/0",
                "next-hop": "fe80::1"
            },
            {
                "prefix": "2001:db8::/32",
                "next-hop": "fe80::2"
            }
        ]
    }
}
```


The universal IPv6 Configuration option MUST be small enough to fit within a
single IPv6 ND packet. It then follows that a single element in the
dictionary cannot be larger than what fits within a single option. Different
elements can be split across multiple universal configuration options (in
separate packets). All IANA registered elements are under the "ietf" key in the
dictionary. Private configuration information can be included in the option
using different keys.

If information learnt via this option conflicts with other configuration
information learnt via Router Advertisement messages, that is
considered a configuration error. How those conflicts should be resolved is left
up to the implementation.

# CBOR encoding

It is recommended that the user can configure the option using JSON. Likewise an
application registering interest in an option SHOULD be able to use string keys.
The CBOR encoding to save space, uses integers for map keys. The mapping table
between integer and string map keys are part of the IANA registry for the
option.

Values -23-23 encodes to a single byte in CBOR, and these values are reserved
for IETF used map keys.

# Implementation Guidance

The purpose of this option is to allow users to use the RA as an opaque
carrier for configuration information without requiring code changes in the
option carrying infrastructure.

On the router there should be an API allowing a user to add
an element, e.g. a JSON object [@RFC8259] or a pre-encoded CBOR string to RAs
sent on a given interface.

On the host side, an API SHOULD be available allowing applications to subscribe
to received configuration elements. It SHOULD be possible to subscribe to
configuration object by dictionary key.

The contents of any elements that are not recognized, either in whole or in
part, by the receiving host MUST be ignored and the remainder of option's
contents MUST be processed as normal.

An implementation SHOULD provide a "JSON interface" for configuring the option.

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
Option".

The schema field follows the CDDL schema definition in [@!RFC8610].

Changes and additions to the registry follow the policies below [@RFC8126]:

Range                      | Registration Procedure
---------------------------|----------------------
-23-23                     | Standards Action
24-32767                   | Specification Required
32768-18446744073709551615 | Expert Review

A new registration requires a new CBOR key to parameter name assignment and a
CDDL definition.

## Universal configuration option
The IANA is requested to add the universal option to the
"IPv6 Neighbor Discovery Option Formats" registry with the value
of 42.

=======
## Initial objects in the registry

The PVD [@RFC8801] elements and DNS [@RFC8106]) are included to provide an
alternative representation for the proposed new options in that draft.


## Initial objects in the registry

### CDDL/JSON Mapping Parameters to CBOR

Parameter Name / JSON key | CBOR Key
--------------------------|-----------
ietf                      | -23
pio                       | -22
mtu                       | -21
rio                       | -20
dns                       | -19
nat64                     | -18
ipv6-only                 | -17
pvd                       | -16
prefix                    | -15
preferred-lifetime        | -14
valid-lifetime            | -13
lifetime                  | -12
a-flag                    | -11
l-flag                    | -10
preference                | -9 
nexthop                   | -8 
nssl                      | -7 
dnss                      | -6 
fqdn                      | -5 
uri                       | -4 


### Key Registry

~~~ cddl
+------------------------------------------------+-----------+
|CDDL                                            | Reference |
+------------------------------------------------+-----------+
|ietf = {                                        |           |
|  ? pio : [+ pio]                               |           |
|  ? rio : [+ rio]                               |           |
|  ? dns : dns                                   |           |
|  ? nat64: nat64                                |           |
|  ? ipv6-only: bool                             |           |
|  ? pvd : pvd                                   |           |
|}                                               |           |
|                                                |           |
|                                                |           |
|dns = {                                         | RFC8106   |
|  nssl : [* tstr]                               |           |
|  dnss : [+ ipv6-address]                       |           |
|  lifetime : uint .size 4                       |           |
|}                                               |           |
|                                                |           |
|nat64 = {                                       | RFC7050   |
|  prefix : ipv6-prefix                          |           |
|}                                               |           |
|ipv6-only : bool                                | [v6only]  |
|                                                |           |
|pvd = {                                         |           |
|  fqdn : tstr                                   |           |
|  uri : tstr                                    |           |
|  ? dns : dns                                   |           |
|  ? nat64: nat64                                |           |
|  ? pio : [+ pio]                               |           |
|  ? rio : [+ rio]                               |           |
|}                                               |           |
+------------------------------------------------+-----------+
~~~

{backmatter}
# Acknowledgements

Many thanks to Dave Thaler for feedback and suggestions of a more effective CBOR encoding.
Thank you very much to Carsten Bormann for CBOR and CDDL help.
