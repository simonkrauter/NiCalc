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
  * `sqrt()`
  * `ln()`
  * `sin()`
  * `cos()`
  * `tan()`
  * `round()`
  * `floor()`
  * `ceil()`
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

License
-------

NiCalc is FLOSS (free and open-source software) under the [GNU General Public License v3](http://www.gnu.de/documents/gpl-3.0.en.html).
