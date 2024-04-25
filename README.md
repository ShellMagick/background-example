# Creation of these backgrounds

See also the [README.md of icons](./icons/README.md).

## Generic notes

- _dark_ and _light_ do not refer to in which mode the icons "should be used", but rather the generic tone of the images themselves
    - thus _dark_ is usually the one to be used in light mode
    - thus _light_ is usually the one the be used in dark mode
- BUT the "useable" backgrounds, they refer correctly to the mode of expected usage
  - this corresponds to the [Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), as in the backgrounds postfixed with _dark_ have to be used with dark color schemes (e.g., solarized) and _light_ with light schemes (e.g., solarized light).
- `magick` refers to the [ImageMagick CLI](https://imagemagick.org/script/command-line-processing.php)
- `inkscape` refers to the [InkScape CLI](https://inkscape.org/doc/inkscape-man.html)

## Base images

### In the folder `backgrounds/src`

#### Gathered "sources"

| Picture     | Source      | License    |
|-------------|-------------|-----------:|
| `spock.png` | Screenshot¹ | Fair use?² |

¹ from the documentary film [For the Love of Spock](https://en.wikipedia.org/wiki/For_the_Love_of_Spock) by Adam Nimoy
² I’d argue the usage here falls under fair use, in case there is disagreement by the copyright holder, please reach out to me

#### Processed "sources"

| Picture | Source | Modifications |
|---------|--------|:--------------|
| `spock-transparent.png`       | `spock.png`                   | `magick src/spock.png -transparent black src/spock-transparent.png` |
| `spock-transparent-light.svg` | `spock-transparent.png`       | Created with https://www.freeconvert.com/                           |
| `spock-transparent-dark.svg`  | `spock-transparent-light.svg` | Inverted the colors with InkScape                                   |

## Background images in the folder `dst`

See the [Makefile](./Makefile) for all the details, but here is the gist of it:

1. Create pattern, which will be used as an effect mask for the background (think faux interlacing effects, like in the original [Red Alert cutscenes](https://www.youtube.com/watch?v=Nmsek2FGFG4))
2. Create "oversized" background image: "base", for dark and light modes.
3. Create composites of the "base" images with all "icons", matching the mode.
4. Create a mask out of each of the composites.
5. Combine the composites with the pattern based on the mask.
6. Create a meta-mask of the patterns composite.
7. Apply the meta-mask on each "base".
8. Finalize the effects.

Yes, the above is sub-optimal. The Makefile is hacky, and I am not a graphics guru, but it's good enough for demo purposes.

The demo Makefile is written with Cygwin in mind, whilst InkScape and ImageMagick are installed normally on the Windows host.

Of course, you can do whatever "effect" you would want on your backgrounds, including even moving pictures (Windows Terminal currently supports JPG, PNG, and GIF!).
