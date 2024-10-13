# IllumiGate LED System - Software Design Document

## Overview

This project involves creating an LED system for a gate, with multiple RGBW LED strips arranged in different geometries, such as triangular and square sections. The goal is to design a software solution that enables the creation of animations using the real geometry of the LED sections, such as a purple light that "bounces" around the sides of a triangle and moves over to a square section.

## Technical Details

- Hardware: The project runs on low-cost microcontrollers like Arduino, STM32, ESP8266, etc.

- LED Libraries: The available libraries control the hardware, taking an LED position (e.g., LED 17 out of 64) and an RGBW value.

- Microcontroller Setup: Each section may need a separate microcontroller due to wiring constraints. We will start with a single microcontroller, but eventually, the system will support distributed devices using MQTT for coordination.

- Designer Tool: A "Designer" program will be developed using Raylib to create animations with a 3D representation of the gate's geometry. Animations will be uploaded to the hardware, preferably via WiFi.

## System Components

### 1. Designer Program (PC Application)

The Designer program is a PC-based tool that allows users to visually create and manage LED animations.

Technology: The GUI and 3D visualization will be built with Raylib.

Features:

3D Representation: Users will have a 3D view of the LED geometries (e.g., triangular, square sections).

Geometry Definition: Users can define and save geometries that match the physical layout of the LED strips.

Animation Tools: The program will have tools for designing animations, including:

Keyframes and Timeline: Define animations with keyframes, specifying the color, brightness, and position for each LED over time.

Predefined Effects: Offer effects like bounce, wave, and transitions, with adjustable parameters.

Custom Scripts: Allow scripting of custom animations for advanced users.

Data Export: The created animations will be saved as JSON files that contain the state of each LED at different timestamps or logic describing the animation behavior.

### 2. Animation Controller (Microcontroller Code)

The microcontrollers will run firmware capable of receiving animation data and controlling the LED strips accordingly.

Microcontroller: Use ESP32 or other WiFi-enabled controllers for communication.

Base Firmware:

Implement WiFi connectivity to connect to the local network.

Use HTTP or MQTT to receive animation instructions.

Animation Playback:

Parse animation data received from the Designer program and convert it to RGBW values for each LED.

Implement MQTT to handle synchronization if multiple microcontrollers are used.

### 3. Data Transfer

WiFi Communication:

On the Designer side, implement a mechanism to send animation data to the microcontrollers via WiFi.

Microcontrollers will either run an HTTP server to receive files or use MQTT to listen for animation data.

Distributed Control:

When multiple microcontrollers are used, synchronization will be managed through an MQTT broker, with each device subscribing to specific topics (e.g., gate/triangle1, gate/square1).

Step-by-Step Development Plan

Step 1: Designer Application with Raylib

Set Up 3D Geometry:

Create a model of the gate and represent the LED strips in 3D.

Allow users to define and position LED strips accurately to visualize the layout.

GUI Controls:

Implement GUI components to let users select LED sections, adjust colors, brightness, timing, and create animations using keyframes.

Offer drag-and-drop tools and color pickers for easy animation creation.

Animation Export:

Generate an output file (e.g., JSON) containing the LED states or animation logic, which can be sent to the microcontrollers.

Step 2: Microcontroller Firmware

Network Setup:

Set up WiFi functionality for the microcontrollers to connect to the local network.

Implement an HTTP or MQTT client to handle animation data transmission.

Playback Logic:

Write code to parse animation data and control the LEDs accordingly.

Implement a state machine for receiving and processing animation files.

Step 3: Synchronization and Distribution

Distributed Playback:

Implement MQTT communication to ensure all microcontrollers receive synchronized commands.

Use timestamps or coordinated triggers to ensure animations run in sync across sections.

## Example Scenario

To demonstrate how this system works, consider an animation where a purple light "bounces" around a triangular section and then moves to a square section:

Designer Application: The user selects the triangular section and defines a bounce effect along the edges. Then, they add a keyframe to move the light to the square section.

Microcontroller Control: The microcontroller controlling the triangular section runs the bounce effect and then passes control to another microcontroller responsible for the square, ensuring a seamless transition.

## Technology Choices

ESP32: Ideal for handling both LED control and WiFi communication due to its ample RAM and WiFi capabilities.

MQTT Protocol: Used for distributed animations to synchronize multiple microcontrollers in real-time.

JSON Data Format: Animation data will initially be stored in JSON format for easier development and debugging. A binary format may be used later for optimized performance.

## Future Improvements

Distributed Microcontroller System: Extend the system to use MQTT to control multiple microcontrollers.

Advanced Effects: Add more predefined effects and scripting capabilities to the Designer tool.

User-Friendly Interface: Improve the GUI to make the animation design process more intuitive and accessible to non-technical users.