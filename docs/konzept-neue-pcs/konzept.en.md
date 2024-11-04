---
title: "Concept for Improving the IT Environment of IKSDP"
#author: Andreas Roth
date: "2024-08-28"
titlepage: true
fontsize: 11
---

\newpage

## Purpose of the Document

This document is intended to serve as a basis for the IKSDP working group to discuss potential improvements to IKSDP's technical equipment. It aims to provide guidance regarding options and associated costs.

The PCs in the computer room should be replaced with contemporary devices to ensure safe operation for users. The PC hardware to be purchased should meet the following requirements:

- Creation of Office documents
- Internet usage (browser)
- Email communication
- Playback of Full-HD videos
- Video telephony and conferences via Zoom, Teams, Jitsi, etc.

A complete new acquisition of devices is assumed. If there are opportunities to receive hardware as a donation, this option should be evaluated in terms of power consumption and performance.

## Current Situation

During my last visit in 2016, IKSDP had a small computer room with 6 PCs dating from around 2004. These PCs had Windows XP installed with some Office applications. There was also a work PC in the administration office. All PCs were connected to the internet. Microsoft ended support for Windows XP on April 8, 2014. Since then, there have been no security updates or bug fixes. It's unclear whether security applications were installed on the Windows XP PCs. However, these might not function properly due to the lack of support from Microsoft. According to Andreas Siekmann, this situation has not changed to date. It is strongly advised against continuing to operate these PCs in any way.

## Retrospective

During our visit, we were asked by several students and residents if we could procure PC hardware. Given the situation at the time, we developed the idea of replacing the outdated PCs with Raspberry Pis (Raspi). The Raspberry Pi is a single-board computer and one of the best-selling computers worldwide. It is particularly popular among hobbyists, educational institutions, and developers.

![img/raspi_v3.png](img/raspi_v3.png)

The low power consumption of only 4 watts makes the device particularly versatile.

Our idea at the time was to show the students and aspiring teachers how to procure relatively inexpensive hardware (about $35) to implement projects. Raspberry Pis are also available in Kenya. The prerequisite was that the Raspberry Pi runs on a Linux operating system, as there was no Windows for the ARM hardware platform on which the Raspberry Pi is based.

In our tests, we found that operating an office workstation on a Raspberry Pi 3 is basically possible, but quickly reaches its limits due to the low memory (1 GB RAM). The computer became very slow as soon as an internet browser was opened in parallel with an email program or an office application.

In June 2019, the successor, the Raspberry Pi 4, was released. This version is available with up to 8 GB RAM and a significantly more powerful CPU, albeit at a higher price (~$100). Our tests in 2020 showed that an office workstation can be operated well under Linux with this device. However, video calls via Zoom or Microsoft Teams with a webcam are not optimally possible, as the software from the manufacturers did not support video hardware acceleration. Since the Corona pandemic, however, we consider the possibility of video telephony to be absolutely necessary.

## PC Hardware

In September 2023, the Raspberry Pi 5 was released, which has a CPU about four times faster. However, it has not yet been verified whether this hardware is now sufficient for video calls. The energy consumption increased to just under 10 watts. The price for the 8 GB version is currently around $100, plus costs for SD card, case, and power supply, bringing the total price to about $150.

At the beginning of 2023, Intel brought the N100 platform to market, which was specifically developed for energy-efficient applications such as mini-PCs and low-cost laptops. Unlike the Raspberry Pi, this platform is based on the X86 architecture and is thus compatible with conventional PCs. This would make it possible to install a "normal" Windows operating system, which significantly improves compatibility.

### Intel N100 

The power consumption of the Intel N100 platform is about 8 watts at idle (most of the time) and rises to up to 25 watts under full load (rarely). Although this consumption is higher than the Raspberry Pi, it is still significantly lower than conventional office PCs, which consume about 50 watts. The N100 platform is about 40% faster than a Raspberry Pi 5 and should be able to meet all requirements without problems. The N100 has 4 CPU cores with a clock frequency of up to 3.4 GHz.

Various manufacturers integrate this platform into their devices. Here are some examples:

**Aoostar T box n100**

Hardware: CPU: N100, RAM 8/16GB, 256GB SSD
CPUMark: 5500
Link: https://aoostar.com/products/aoostar-t-box-intel-n100-metal-case-mini-pc4c-4t-with-w11-home-8-16gb-ram-256-512gb-ssd

Price: 137 EUR.

![Aoostar T box](img/aoostar-t-box1.png){ width=300px } 
`<img src="images/syslog-ng-mergerequest.png" alt="Test Pipeline" style="border: 2px solid black" align="left">`{=html}

**Bosgame mini pc**

Hardware: CPU: N100, RAM 16GB, 512GB SSD
CPUMark: 5500
Link: https://www.bosgamepc.com/products/bosgame-mini-pc-b100-intel-12th-gen-alder-lake--n100-16gb-ddr4-ram-512gb-ssd

Price: 152 EUR

### AMD Lucienne

Competitor AMD offers the Lucienne CPUs as a rival product to the Intel N100. These processors are equipped with 8 cores and reach clock speeds of up to 4.3 GHz, making them significantly more powerful. They also have an integrated graphics chip that provides sufficient performance for simple games. However, these CPUs are also more expensive and have a slightly higher power consumption. An example of a product with this CPU is:

**Aoostar MN57**

Hardware: CPU: AMD Ryzen 7 5700U, RAM 16GB, 256 SSD
CPUMark: 15000
Link: https://www.bosgamepc.com/products/bosgame-mini-pc-b100-intel-12th-gen-alder-lake--n100-16gb-ddr4-ram-512gb-ssd

Price: 279 EUR

All products come from Chinese suppliers that ship directly from China. Aoostar offers shipping to Kenya without additional shipping costs. However, it should be checked what customs fees might be incurred in Kenya. It also needs to be clarified whether an order confirmation from an online shop is sufficient for the project sponsor.

### Monitors

Our internet research has shown that TFT monitors tend to be more expensive and less available in Kenya.

Here are examples:

https://www.mombasacomputers.com/product/dell-p2018h-20-led-backlit-lcd-1600x900-hd-monitor/
Price: 18000KES - 126 EUR + VAT

https://devicestech.co.ke/product/22inch-edge-to-edge-monitorex-uk/
Price: 14500KES - 100 EUR + VAT

Perhaps a contact in Nairobi could check the prices for monitors in a mall on site, as these devices are probably best procured directly on site. It might also make sense to buy the devices online and store them with a trusted person in Nairobi.

### Evaluation and Costs

We currently recommend a mini-PC based on the Intel N100. This offers sufficient performance to meet IKSDP's requirements and represents a good compromise between cost and performance.

For the hardware of a PC workstation, one should expect about 250-300 USD. In addition to the PC, simple USB headsets should be purchased to be able to play back and record audio. New keyboards and mice with USB connection must also be procured. Webcams (about 50 USD) should also be planned for some of the PCs.

| **Component** |  **Price**   |
|------------|----------|
| PC N100    |  170 EUR |
| TFT        |  120 EUR |
| Accessories|  30  EUR |
|------------|----------|
| Total      |  320 EUR |

## Internet

We were unable to determine if there are internet providers that can provide internet via telephone or data cable at this location.

Therefore, we focused on mobile solutions.

### Starlink

Starlink is a satellite internet service from SpaceX that provides global internet connectivity, particularly for remote or underserved areas. Using a network of thousands of satellites in low Earth orbit, Starlink enables fast and reliable internet connection with low latency. The product is aimed at both individuals and businesses and is particularly useful in regions where conventional internet infrastructures are difficult to access.

In Germany, Starlink offers performance comparable to VDSL connections of 200 Mbps. We currently do not have experience reports from Kenya.

According to the website, internet access via Starlink has been available in Nyandiwa since early 2024.

![Starlink](img/starlink_bestellen.png)

The required hardware can either be purchased or rented. The monthly rent is 1950 KES (14 EUR), and the one-time activation fee is 2700 KES (18 EUR).

If you choose to buy instead of rent, you'll pay 45,500 KES (322 EUR) for the satellite dish, 5700 KES for the Ethernet adapter, and 13,300 KES for a mount.

For the internet tariff, you can choose between a volume-based tariff (50 GB for 1300 KES/9 EUR) and a flat rate for 6500 KES (46 EUR). If you exceed the 50 GB data volume on the volume-based tariff, 20 KES per additional GB will be charged. From a monthly data consumption of 250 GB, the flat rate would therefore be worthwhile.

### Mobile Internet

It was very difficult to get valid coverage data for the location in Nyandiwa. According to https://nperf.com, mobile internet is only available through the provider Airtel Mobile. However, the cell ends directly in Nyandiwa. It is questionable whether IKSDP actually has reception.

![Network Coverage](img/network_coverage_nyandiwa.png)

| **Bundle** | **Price (KES)**	 |
| -------|---------------|
| 5G Unlimited 10Mbps Plan |	3500KES/25 EUR |
| 5G Unlimited 20Mbps Plan |	5000KES/36 EUR |
| 5G Unlimited 30Mbps Plan |	6500KES/35 EUR |

Additionally, costs for a 5G/4G modem are incurred. A 4G modem with specially improved range, such as the Mikrotik LHG LTE18 Kit (see https://mikrotik.com/product/lhg_lte18), is available for about 250 EUR. 5G hardware, which might not be fully utilized in the near future, costs about 550 EUR.

### Evaluation and Costs

We currently recommend internet access via Starlink, as the quality of mobile internet is difficult to predict. We would suggest the smaller variant with rented hardware and a 50 GB tariff. If it turns out that more data is needed, it should be switched to the flat rate tariff.

Monthly costs (rent):

| **Component**                     | **Price**             |
| ------------------------------| ------------------|
| Starlink Hardware             | 1950 KES (14 EUR) |
| Starlink Internet tariff (50GB) | 1300 KES (9 EUR)  |
| optional 50GB*                | 1000 KES (7 EUR)  |
| ------------------------------| ------------------|
| Total                         | 4250 KES (30 EUR) |

+ one-time activation fee 2700 KES

## Network (WLAN)

We recommend hardware from the European network equipment manufacturer Mikrotik, based in Riga, Latvia. Although Mikrotik is relatively unknown in Europe, the company is very popular in South America, Eastern Europe, Asia, and Africa. Mikrotik stands out for its extremely comprehensive range of functions in hardware and software, which is often only found in enterprise solutions from manufacturers like Cisco. At the same time, the hardware costs are very low in comparison. Another advantage: Mikrotik has not yet taken any device out of maintenance. Even devices manufactured in 1997 still receive a current router operating system.

The hardware can be purchased in Kenya, and there are both partners and consultants on site who can provide support if necessary.

![Mikrotik Partners](img/mikrotik-distributors.png)
![Mikrotik Consultants](img/mikrotik-consultants.png)

For networking the computers, we could use the following products:

https://mikrotik.com/product/hex_s 80EUR
https://mikrotik.com/product/l009uigs_2haxd_in 	120EUR

These devices are also suitable for setting up remote access for support.

To provide WLAN coverage for the premises, outdoor access points like the Mikrotik mANTBox ax 15s https://mikrotik.com/product/mantbox_ax_15s (approx. 180 EUR) would be suitable. The device covers an angle of about 180 degrees. Depending on the positioning, two devices might be necessary to ensure full coverage.

| **Component**                     | **Price**             |
| ------------------------------| ------------------|
| Mikrotik HexS                 | 80 EUR            |
| L009UiGS-2HaxD-IN             | 120 EUR           |
| Access Point mANTBox ax 15s   | 180 EUR (approx. 2)|
| Accessories (cables, power supply) | 50 EUR            |
| ------------------------------| ------------------|
| Total                         | 430 EUR / 610 EUR |
