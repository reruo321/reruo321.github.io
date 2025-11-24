---
title: Network Study Challenge Day 1
layout: post
date: 2025-11-24
categories: network
tags: [network, OSI, TCP, IP, DHCP, CIDR, Wireshark]
---

# OSI Model vs TCP/IP Model
![OSI vs TCP/IP](/assets/images/2025-11-24-network-study-challenge-day-1/osi_tcpip_model.png)

|                   	| OSI Model                                                                                                            	| TCP/IP Model                                                                                             	|
|-------------------	|----------------------------------------------------------------------------------------------------------------------	|----------------------------------------------------------------------------------------------------------	|
| **Full Form**         	| **O**pen **S**ystems **I**nterconnection                                                                                         	| **T**ransmission **C**ontrol **P**rotocol/**I**nternet **P**rotocol                                                          	|
| **Strength**             	| - Easier to adopt a new technology<br>- Make troubleshooting & improving network performance more straightforward    	| - Practical<br>- Have more applications<br>- More commonly used in the actual networking structures          	|
| **Approach**          	| - Strict layer-by-layer architecture<br>- Strict function definition<br>- Strictly communicate only with adjacent layers 	| - Flexible architecture<br>- Layers are not strictly separated<br>- Two different random layers can interact 	|
| **Error<br>Handling** 	| - At data link layer (frame errors) <br>- At transport layer (end-to-end reliability)                                      	| - TCP                                                                                                      	|