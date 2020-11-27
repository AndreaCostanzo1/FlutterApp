# Beertastic :beers:

:hammer_and_wrench: **Build & Tests:** [![CircleCI](https://circleci.com/gh/AndreaCostanzo1/FlutterApp/tree/master.svg?style=svg)](https://circleci.com/gh/AndreaCostanzo1/FlutterApp/tree/master)

:notebook: **Design Document:** &nbsp;[Download here](https://github.com/AndreaCostanzo1/FlutterApp/blob/master/docs/Costanzo_dd.pdf)

:file_folder: **Slides:** &nbsp;[Download here](https://github.com/AndreaCostanzo1/FlutterApp/blob/master/docs/Beertastic.pptx)

## Goal of the project :dart:

This repository contains the work done for the course of ***Design and Implementation of Mobile Applications*** at Politecnico di Milano (Italy). 
The goal of the course was to design a "mobile" application in which the user experience assumes a central role, starting from how the various elements characterizing the UI should be disposed to how users should interact with them.
Beertastic was thought to provide users with a smooth and joyful way to approach to the beer and brewery worlds, by offering the possibility to read articles, see events, search beers and exchange opinions.
This document presents a functional specification of the architectural components defining the system as well as their interfaces and interactions, and make use of graphs to expose better their relationships and behaviours.

## Technologies used :nut_and_bolt:

- **Frontend**
  - Flutter
  - Android (Java) for the ML part related to barcodes and QR codes
- **Backend**
  - Firebase [Authentication, Functions, Firestore (Database), Storage, ML]
- **Continuous integration**
  - CircleCI
  - Codecov

*The usage of these technologies is further detailed in the design document*


*Some UIs have been inspired from:*
- https://www.youtube.com/watch?v=pAYGLroI1DI&t=135s [Event Page]
- https://www.youtube.com/watch?v=K8pG0Lo4f1o [Beer Page]
- https://www.youtube.com/watch?v=x77Ijv0kCJc [Settings]


