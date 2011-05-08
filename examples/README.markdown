# HotCocoa Examples

This directory contains a few demos of using the HotCocoa library.

To learn more about HotCocoa see:

  http://www.macruby.org/trac/wiki/HotCocoa

When you install HotCocoa you get a hotcocoa command which generates a
project directory from a template.

Usage:

```bash
hotcocoa <directory>
```

This will generate your directory structure. The sample apps in this
directory were generated with this command.  The basic HotCocoa
directory structure is:

./directory/Rakefile              #=> used with macrake to build the app
./directory/config/build.yml      #=> build options
./directory/lib/application.rb    #=> application template
./directory/lib/menu.rb           #=> menus used by the app
./resources/HotCocoa.icns         #=> hotcocoa icon

After generating the structure, cd into that directory and run
`macrake` to build.

## Examples

Examples can all be run by running `macrake` from inside the example
directory.

```bash
cd <example-directory>
macrake
```

* calculator

  A simple calculator example.

* demo

  Demo of many hotcocoa wrappers.

* layout\_view

  Demo of using the layout view system.

* round\_transparent_window

  Port of an Apple sample showing how to use hotcocoa with a nib files.

* round\_transparent\_window\_no\_nibs

  Same as round\_transparent\_window but without using any nibs.

* download\_and\_progress\_indicator

  Demo of downloading data, progress indicator and scroll view containing a text view.

* hotconsole

  An IRB-like console using WebKit.

## HotCocoa::Graphics Examples

There is also a set of examples showcasing some of the things you can
create using HotCocoa::Graphics. You can run the example app directly
by using `macruby`.

```bash
cd graphics
macruby demo.rb
```
