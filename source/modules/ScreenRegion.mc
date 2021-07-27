module ScreenRegion {
    enum {
        LEFT = "LEFT",
        RIGHT = "RIGHT",
        TOP = "TOP",
        BOTTOM = "BOTTOM",
        MIDDLE = "MIDDLE",
        TOP_LEFT = "TOP_LEFT",
        TOP_RIGHT = "TOP_RIGHT",
        MIDDLE_LEFT = "MIDDLE_LEFT",
        MIDDLE_RIGHT = "MIDDLE_RIGHT",
        BOTTOM_LEFT = "BOTTOM_LEFT",
        BOTTOM_RIGHT = "BOTTOM_RIGHT"
    }

    var screenWidth;
    var screenHeight;

    function getRegion(coords, regions) {
        var x = coords[0];
        var y = coords[1];

        var vertical = getverticalRegion(y, regions);
        var horizontal = x <= screenWidth / 2 ? LEFT : RIGHT;
        var combined;

        if (horizontal == LEFT) {
            combined = vertical == TOP ? TOP_LEFT : vertical == BOTTOM ? BOTTOM_LEFT : MIDDLE_LEFT;
        }
        else {
            combined =  vertical == TOP ? TOP_RIGHT : vertical == BOTTOM ? BOTTOM_RIGHT : MIDDLE_RIGHT;
        }
        return {
            :x => horizontal,
            :y => vertical,
            :combi => combined
        };
    }

    function getverticalRegion(y, regions) {
        var regionSize = regions == 6 ? screenHeight / 3 : screenHeight / 2;
        if (regions == 6) {
            if (y <= regionSize) {
                return TOP;
            }
            else if (y <= regionSize * 2) {
                return MIDDLE;
            }
            return BOTTOM;
        }

        return y <= regionSize ? TOP : BOTTOM;
    }

    function setScreenDimensions(width, height) {
        screenWidth = width;
        screenHeight = height;
    }
}