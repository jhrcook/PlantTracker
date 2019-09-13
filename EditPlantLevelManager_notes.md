# Notes on implementation of drop-down multi-selection menu

[![ios](https://img.shields.io/badge/iOS-Plant_Tracker-999999.svg?style=flat&logo=apple)](https://github.com/jhrcook/PlantTracker)  

author: Joshua Cook  
date: 2019-09-12

**Table of Contents**

  1. [Introduction](#Introduction)
  2. [Problem](#Problem)
  3. [Solution](#Solution)
  4. [Implementation Details](#Implementation-Details)

**[Add gif of opertaional editing system.]**

## Introduction

The Plant Tracker app is my pet-project that I created because I want to get started learning iOS development.
It's purpose is to help my mom take care of her plants (mainly succulents and cacti).
I am still working on the first tab, "Library," which will contain information on all of the types of plants that she has possessed or come across at nurseries.
The first view of the Library is a table view with a row for each plant.
Selecting a plant takes the user to the detail view for the plant, a custom view with a main header images and a information panel that has three sub-views: a general information view (in progress), notes view (functional), and a view with links (to-do).
The general information view is another table view with each row showing a specific property of the plant.
The first two are the names of the plant, scientific and common names, and the rest are pre-determined types (enumerations in Swift).


## Problem

The problem I encountered was how to let the user change the general information for a plant.
The name properties were simple: tapping on them brings up an alert controller with a place for text input.
I could not, however, figure out a good way of letting a user tap on the other proprties and be able to select from a predetermined list of options.


## Solution

Leo suggested the following solution: when the user taps on a cell, another appears below it with the available options.
For example, the [Overcast]() app has the following feature when a podcast episode is selected:

**[Add gif of Overcast system.]**


## Implementation Details


