# Irradiance

The Irradiance package is a Swift translation of the spectrl2 C code from NREL's [Bird Simple Spectral Model](https://www.nrel.gov/grid/solar-resource/spectral.html).  It depends on [SolarPos](https://github.com/mchapman87501/SolarPos.git), which is a Swift implementation of NREL's Solar Position Algorithm for Solar Radiation Applications.

For most uses the main entity will be Irradiance, which calculates irradiance spectra for flat surfaces located/oriented on earth's surface.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Build Status](https://travis-ci.org/mchapman87501/Irradiance.svg?branch=master)](https://travis-ci.org/mchapman87501/Irradiance)