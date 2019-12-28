NiCalc
======

NiCalc is a simple calculator written in [Nim](https://nim-lang.org/) using [NiGui](https://github.com/trustable-code/NiGui).

Supported elements
------------------

The input term may consist of:

* Rational numbers
  * Decimal point: `.`
  * Digit grouping: `,`, `_`
* Arithmetic operators: `+`, `-`, `*`, `/`, `^` (power)
* Brackets: `(`, `)`
* Functions:
  * `abs()`
  * `ceil()`
  * `cos()`
  * `floor()`
  * `ln()`
  * `log2()`
  * `round()`
  * `sin()`
  * `sqrt()`
  * `tan()`

* Constants:
  * `pi`
  * `e`

Example:

Input: `(2^16+2*3-sin(pi))/2`<br>
Result: `32,771`

Keyboard commands
-----------------

* Return - Add calculation to history
* Escape - Quit

Screenshots
-----------

<a href="https://github.com/trustable-code/NiCalc/blob/master/screenshot-windows.png"><img src="https://raw.githubusercontent.com/trustable-code/NiCalc/master/screenshot-windows.png" width="400"></a>

<a href="https://github.com/trustable-code/NiCalc/blob/master/screenshot-gtk.png"><img src="https://raw.githubusercontent.com/trustable-code/NiCalc/master/screenshot-gtk.png" width="400"></a>

Download
--------

* [Binary downloads for Windows and Linux](https://github.com/trustable-code/NiCalc/releases)
* macOS users can try the Gtk version or wait for native macOS support

History
-------

* Version 1.0 (2017-07-02) - First release
* Version 1.1 (2017-08-09) - Fixed handling of brackets, added "abs()" function
* Version 1.2 (2018-01-02) - Fixed handling of brackets

License
-------

NiCalc is FLOSS (free and open-source software).<br>
All files in this repository are licensed under the [GNU General Public License version 3](https://opensource.org/licenses/GPL-3.0) (GPLv3).<br>
Copyright 2017-2019 Simon Krauter
