# Irradiance

The Irradiance package is a Swift translation of the spectrl2 C code from NREL's [Bird Simple Spectral Model](https://www.nrel.gov/grid/solar-resource/spectral.html).  It depends on [SolarPos](https://github.com/mchapman87501/SolarPos.git), which is a Swift implementation of NREL's Solar Position Algorithm for Solar Radiation Applications.

For most uses the main entity will be Irradiance, which calculates irradiance spectra for flat surfaces located/oriented on earth's surface.

The original NREL software is based on (and even listed in) [Simple Solar Spectral Model for Direct and Diffuse Irradiance on Horizontal and Tilted Planes at the Earth's Surface for Cloudless Atmospheres](https://www.nrel.gov/docs/legosti/old/2436.pdf).  This paper is available [in HTML format].(https://rredc.nrel.gov/solar/pubs/spectral/model/spectral_model_index.html)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Build Status](https://travis-ci.org/mchapman87501/Irradiance.svg?branch=master)](https://travis-ci.org/mchapman87501/Irradiance)