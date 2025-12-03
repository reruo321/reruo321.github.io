---
title: Network Study Challenge Day 1
layout: post
date: 2025-11-24
categories: network
tags: [network, OSI, TCP, IP, IPv4, IPv6, DHCP, CIDR, Wireshark]
---

# OSI Model vs TCP/IP Model
![OSI vs TCP/IP](/assets/images/2025-11-24-network-study-challenge-day-1/osi_tcpip_model.png)

| | OSI Model | TCP/IP Model |
| - | - | - |
| **Full Form** | **O**pen **S**ystems **I**nterconnection | **T**ransmission **C**ontrol **P**rotocol/**I**nternet **P**rotocol |
| **Characteristic** | Conceptual | Practical |
| **Strength** | - Standardization<br>- Independent layers<br>- Easier to adopt a new technology[^1]<br>- Make troubleshooting & network performance improvement more straightforward | - Real-world network applicability<br>- Have more applications |
| **Approach** | - Strict layer-by-layer architecture<br>- Strict function definition<br>- Strictly communicate only with adjacent layers | - Flexible architecture<br>- Layers are not strictly separated<br>- Two different random layers can interact |
| **Error<br>Handling** | - At data link layer (frame errors)<br>- At transport layer (end-to-end reliability) | - TCP |

[^1]: The OSI model's protocol independence and higher degree of modularity & layer granularity makes it easier to adopt new network technologies than the TCP/IP model. The OSI model easily adopts them as long as they adhere to the standardized interfaces between layers, but the TCP/IP model requires them to interoperate with the model's specific set of core protocols. The isolation from modularity and layer granularity of the OSI model also makes the adoption easier at one layer, while the TCP/IP model can make it harder because of its possibly larger impacts on multiple grouped functions or broader system adjustments.

# IPv4 vs IPv6
![IPv4 vs IPv6](/assets/images/2025-11-24-network-study-challenge-day-1/ipv4_ipv6.png)

| | IPv4 | IPv6 |
| - | - | - |
| Address<br>Configuration | - DHCP<br>- Manual Configuration | - DHCPv6 <br>- SLAAC (**S**tate**L**ess **A**ddress **A**uto**C**onfiguration, devices can generate their addresses based on network prefixes) |
| NAT | Good / Conserve address with private + public IP address spaces | Bad / Already have abundant address space, devices can have globally routable addresses |
| Header<br>Complexity | Variable-length (20 ~ 60 bytes[^2])<br>(Extensibility ↑, Packet processing ↓) | Fixed-length (40 bytes), streamlined<br>(Extensibility ↓, Packet processing ↑) |

[^2]: Basically 20 bytes, and can increase up to 60 bytes when optional fields and flags are added.

![IPv4 vs IPv6 Header Comparison](/assets/images/2025-11-24-network-study-challenge-day-1/header_comparison.png)

# Stateful vs Stateless
## Stateful (DHCP)
Let's talk about a stateful coffee shop A.

You walk in → the barista looks at a notebook and says:
“Ah, it’s you again! Your usual seat is #5, here’s your regular latte.”
She writes down in her notebook:
“Table 5 → Customer with red jacket → ordered latte at 8:15 am”
Tomorrow when you come back, she still remembers you and what you ordered last time.
→ The shop keeps a record (a “state”) about you.

This is exactly what a DHCP server does:
It keeps a little notebook (the lease database) that says
“this laptop’s MAC address → I gave it 192.168.1.100 until Friday”.
So we call it stateful = the network has to remember things about each device.

## Stateless (SLAAC)
Let's talk about a stateless coffee shop B.

You walk in the shop → there is a big sign on the wall:
“Help yourself! Any empty seat that starts with number 200 is yours today.
Write your own name on the cup.”
You pick seat 237, write your name, and sit down.
The shop owner never writes anything down and never remembers who sat where.
Tomorrow the sign will say the same thing, and you just pick another seat (or the same one) again.

→ The shop keeps no records, no memory, no “state”.

# Subnet Mask
* Network Address

# Reference
* [The Difference Between IPv4 and IPv6](https://aws.amazon.com/compare/the-difference-between-ipv4-and-ipv6/)
* [DHCPv6](https://www.ietf.org/rfc/rfc3315.txt)
* [SLAAC](https://www.networkacademy.io/ccna/ipv6/stateless-address-autoconfiguration-slaac)
