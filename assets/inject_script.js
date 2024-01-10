const LOCATION_ATTR = "data-ereader__location"; // located on each HTML tag
const NEXT_FILE_ATTR = "data-ereader__next"; // located on the <html> tag
const PREVIOUS_FILE_ATTR = "data-ereader__previous"; // located on the <html> tag
const INDEX_FILE_ATTR = "data-ereader__index";
const LOCATION_BOUND_START_ATTR = "data-ereader__location_start"; // located on the <html> tag
const LOCATION_BOUND_END_ATTR = "data-ereader__location_end"; // located on the <html> tag

class EReaderPage {
    constructor() {
        this.setVelocities(1, 0);
    }

    /**
     * Sets the direction of the page when scrolling
     * For instance, RTL languages like Arabic might require incrementing by -1 pages to go forward (x = -1, y = 0)
     * whereas top-down languages like traditional Japanese and Chinese may require moving vertically (x = 0, y = 1)
     * @param {number} x - The number of pages to move horizontally for each scroll (positive = right)
     * @param {number} y - The number of pages to move vertically for each scroll (positive = down)
     */
    setVelocities(x, y) {
        this.dX = Math.max(Math.min(x, 1), -1);
        this.dY = Math.max(Math.min(y, 1), -1);
        console.debug(`[ereader.page.setVelocities] Set page velocity to x = ${this.dX} and y = ${this.dY}`);
    }

    /**
     * Snaps the current scrolling to the nearest page
     * Occasionally, the page position will be
     * @returns {number} The new location number
     */
    snapToNearest() {
        // Snaps current scrolling to the nearest page
        console.debug(`[ereader.page.snapToNearest] Snapping to the nearest page`);
        this.incrementBy(0);
        return ereader.location.get();
    }

    /**
     * Increments the page count by the number of pages
     * Goes to the previous or next page if out of bounds, if possible
     * @param {number} quantity - The number of pages to flip by (positive = right)
     * @returns {number} The new location number, or -1 for end-of-book and -2 for start-of-book
     */
    incrementBy(quantity) {
        // goes to the next or previous file if flip out of range, but number of pages flipped is not guaranteed
        let before = this.get();
        this.jumpTo(this.get() + quantity);
        let after = this.get();

        console.debug(`[ereader.page.incrementBy] Flipping by ${quantity} pages`);

        if (before !== after || quantity === 0) {
            console.info(`[ereader.page.incrementBy] Page number is unchanged`);
            return ereader.location.get();
        }

        let params = ereader.parameter.get();
        let destination;
        if (quantity > 0) {
            // go to next
            console.debug(`[ereader.page.incrementBy] Going to the next file`);
            if (!document.documentElement.hasAttribute(NEXT_FILE_ATTR)) return -1;
            destination = document.documentElement.getAttribute(NEXT_FILE_ATTR);
            params.set("location", ereader.location.getBounds()[1].toString())
        } else {
            // go to previous
            console.debug(`[ereader.page.incrementBy] Going to the previous file`);
            if (!document.documentElement.hasAttribute(PREVIOUS_FILE_ATTR)) return -2;
            destination = document.documentElement.getAttribute(PREVIOUS_FILE_ATTR);
            params.set("location", (ereader.location.getBounds()[0] - 1).toString())
        }
        console.debug(`[ereader.page.incrementBy] Updated URL parameter`);
        window.location.replace(`${destination}?${params.toString()}`);
        return ereader.location.get();
    }

    /**
     * Jumps to a specific page number
     * Page numbers are dependent on document rendering and chapter-specific, so they aren't reliable
     * @param {number} page - The page to jump to
     * @returns {number} The new location number
     */
    jumpTo(page) {
        window.scroll({
            left: page * window.innerWidth * this.dX,
            top: page * window.innerHeight * this.dY,
        });
        console.debug(`[ereader.page.jumpTo] Attempted to jump to page ${page}}, results may vary`);

        let params = ereader.parameter.get();
        params.set("location", ereader.location.get().toString());
        ereader.parameter.set(params);
        console.debug(`[ereader.page.jumpTo] Updated URL parameter`);

        return this.get();
    }

    /**
     * Gets the current page number
     * Page numbers are dependent on document rendering and chapter-specific, so they aren't reliable
     * @returns {number} The current page number
     */
    get() {
        let horizontalPage = (window.scrollX * this.dX) / window.innerWidth;
        let verticalPage = (window.scrollY * this.dY) / window.innerHeight;
        let totalPageCount = Math.ceil(Math.max(document.documentElement.scrollHeight / window.innerHeight,
            document.documentElement.scrollWidth / window.innerWidth));
        let pageNumber = Math.max(Math.min(Math.round(horizontalPage + verticalPage), totalPageCount - 1), 0);
        console.debug(`[ereader.page.get] Currently on page ${pageNumber}`);
        return pageNumber;
    }
}

class EReaderLocation {
    /**
     * Jumps to a specific location number
     * @param {number} location - The location number to jump to
     */
    jumpTo(location) {
        // jump to a specific location number
        let selector = `*[${LOCATION_ATTR}="${location}"]`;
        console.debug(`[ereader.location.jumpTo] Attempting to jump to selector >${selector}<`);
        let able = ereader.jumpToSelector(selector);
        console.debug(`[ereader.location.jumpTo] Jumping ${able ? '' : 'un'}successful`);
        if (!able) {
            console.debug(`[ereader.location.jumpTo] Redirecting back to index`);
            let params = ereader.parameter.get();
            params.set("location", location.toString());
            let indexFile = document.documentElement.getAttribute(INDEX_FILE_ATTR);
            window.location.replace(`${indexFile}?${params.toString()}}`)
        }
    }

    /**
     * Gets the current location number
     * @returns {number} The location number
     */
    get() {
        // get the current location
        let max = -1;
        for (let e of document.querySelectorAll(`*[${LOCATION_ATTR}]`)) {
            let location = parseInt(e.attributes[LOCATION_ATTR].value);
            if (ereader.elementVisible(e)) {
                console.debug(`[ereader.location.get] Current location is ${location}`);
                return location;
            }
            max = Math.max(location, max);
        }
        console.error("[ereader.location.get] This should not have happened, no valid location was found, returning the max location")
        return max; // TODO i have no clue why i did this
    }

    /**
     * Gets whether the specified location is visible
     * @param {number} location The location to check
     */
    isVisible(location) {
        // TODO
    }

    /**
     * Gets the first (inclusive) and last (exclusive) locations of the document
     * @returns {number[]} The first and last locations (guaranteed length 2)
     */
    getBounds() {
        // gets the first and last locations of this
        let bounds = [
            parseInt(document.documentElement.getAttribute(LOCATION_BOUND_START_ATTR)),
            parseInt(document.documentElement.getAttribute(LOCATION_BOUND_END_ATTR))
        ];
        console.debug(`[ereader.location.getBounds] Page bounds are [${bounds[0]}, ${bounds[1]})`);
        return bounds;
    }
}

class EReaderParameter {
    /**
     * Commits the URL search parameters to the URL
     * @param {URLSearchParams} params - The URL parameters to set
     */
    set(params) {
        // replaces the URL parameters without reloading
        let url = `${location.protocol}//${location.host}${location.pathname}?${params.toString()}`;
        window.history.replaceState({}, document.title, url);
        console.debug(`[ereader.parameter.set] Setting parameters to ${decodeURI(params.toString())}`);
    }

    /**
     * Gets the URL search parameters from the URL
     * @returns {URLSearchParams} The URL search parameters
     */
    get() {
        // gets the current URL parameters
        let params = new URLSearchParams(window.location.search);
        console.debug(`[ereader.parameter.get] Retrieved parameters ${decodeURI(params.toString())}`);
        return params;
    }

    /**
     * Syncs the specified URL search parameter with the specified CSS variable
     * Sets the CSS variable to the URL search parameter if it exists
     * Applies the CSS variable to the URL search parameter if it is not found
     * @param {string} paramName - The name of the URL search parameter
     * @param {string} cssName - The name of the CSS variable
     */
    syncWithCSS(paramName, cssName) {
        let parameters = this.get();
        console.debug(`[ereader.parameter.syncWithCSS] Syncing parameter ${paramName} with ${cssName}`);
        if (parameters.has(paramName)) {
            console.debug(`[ereader.parameter.syncWithCSS] Parameter found, copying into CSS`);
            document.documentElement.style.setProperty(cssName, decodeURIComponent(parameters.get(paramName)));
        } else {
            console.debug(`[ereader.parameter.syncWithCSS] Parameter not found, copying from CSS`);
            parameters.set(paramName, encodeURIComponent(window.getComputedStyle(document.documentElement).getPropertyValue(cssName)));
            this.set(parameters);
        }
    }
}

class EReaderSelection {
    /**
     * Gets the text selection along with its context before and after
     * @returns {string[]|*[]} The selection in the format [before, selected, after] or [] if nothing is selected
     */
    get() {
        // gets the text selection as a 3-part array
        let selection = window.getSelection();
        if (selection.rangeCount === 0 || selection.toString() === "") {
            console.debug(`[ereader.selection.get] No selection found`);
            return [];
        }
        let range = selection.getRangeAt(0);

        let selectedText = selection.toString();
        let beforeText = range.startContainer.textContent.substring(0, range.startOffset);
        let afterText = range.endContainer.textContent.substring(range.endOffset);
        console.debug(`[ereader.selection.get] Found selection ${selectedText}`);
        return [beforeText.trimStart(), selectedText, afterText.trimEnd()];
    }

    /**
     * Gets the range of locations the selection spans
     * The end is exclusive
     * @returns {string[]} The range of locations in the format [start, end exclusive] or [] if nothing is selected
     */
    getRangeOfLocations() {
        // get the range of the selections
        let selection = window.getSelection();
        if (selection.rangeCount === 0 || selection.toString() === "") return [];
        let range = selection.getRangeAt(0);
        let startElement = range.startContainer.parentElement;
        let endElement = range.endContainer.parentElement;
        let locationRange = [
            startElement.attributes[LOCATION_ATTR].value,
            endElement.attributes[LOCATION_ATTR].value + 1,
        ]
        console.debug(`[ereader.selection.getRangeOfLocations] Selection was found to span locations [${locationRange[0]}, ${locationRange[1]}]`);
        return locationRange;
    }

    /**
     * Expands (or contracts) the selection by the specified number of characters on both ends
     * @param {number} start - The number of characters to expand the selection by on the left
     * @param {number} end - The number of characters to expand the selection by on the right
     * @returns {boolean} Whether the selection was successfully changed
     */
    expandSelectionBy(start, end) {
        let selection = window.getSelection();
        let range = selection.getRangeAt(0);

        let isContainerSame = range.startContainer.isSameNode(range.endContainer);
        console.debug(`[ereader.selection.expandSelectionBy] Current selection: ${range.startOffset}, ${range.endOffset} 
            spans ${isContainerSame ? "one container" : "many containers"}`);

        // Check invalid
        if (range.endOffset + end > range.endContainer.length) return false;
        if (range.startOffset - start > range.startContainer.length) return false;
        if (range.endOffset + end < 0) return false;
        if (range.startOffset - start < 0) return false;

        // Deselect
        if (isContainerSame && range.range.endOffset + end < range.startOffset - start) {
            selection.removeAllRanges();
            return true;
        }

        range.setStart(range.startContainer, range.startOffset - start);
        range.setEnd(range.endContainer, range.endOffset + end);
        return true;
        // TODO is this right?
    }
}

class EReader {
    constructor() {
        this.page = new EReaderPage();
        console.debug(`[ereader] Instantiated singleton at ereader.page`);
        this.location = new EReaderLocation();
        console.debug(`[ereader] Instantiated singleton at ereader.location`);
        this.parameter = new EReaderParameter();
        console.debug(`[ereader] Instantiated singleton at ereader.parameter`);
        this.selection = new EReaderSelection();
        console.debug(`[ereader] Instantiated singleton at ereader.selection`);
    }

    /**
     * Jumps to the first element with the specified CSS selector
     * @param {string} selector - The CSS selector to find the element to jump to
     * @returns {boolean} Whether the element was found
     */
    jumpToSelector(selector) {
        console.debug(`[ereader.jumpToSelector] Jumping to selector ${selector}`);
        let object = document.querySelector(selector);
        try {
            if (object === null) {
                console.debug(`[ereader.jumpToSelector] Failed to find element, aborting`);
                return false;
            }
            console.debug(`[ereader.jumpToSelector] Found element`);
            object.scrollIntoView({
                behavior: 'auto',
                block: 'center',
                inline: 'center'
            });
            return true;
        } finally {
            this.page.snapToNearest();
        }
    }

    /**
     * Gets whether the specified element is visible on the screen
     * @param {Element} element - The element to check
     * @returns {boolean} - Whether the element is visible
     */
    elementVisible(element) {
        if (getComputedStyle(element).display === "none" ||
            getComputedStyle(element).visibility === "hidden") {
            return false;
        }
        let position = element.getBoundingClientRect();
        let visible = (position.top >= 0 &&
            position.bottom <= window.innerHeight &&
            position.left >= 0 &&
            position.right <= window.innerWidth);
        return visible;
    }

    /**
     * Gets the horizontal direction that text moves
     * @returns {string} The text direction ("ltr" or "rtl")
     */
    getHorizontalDirection() {
        let writingMode = window.getComputedStyle(document.documentElement).writingMode; // horizontal-tb | vertical-rl | vertical-lr

        let direction;
        if (writingMode === "vertical-rl") {
            direction = "rtl";
        } else if (writingMode === "vertical-lr") {
            direction = "ltr";
        } else {
            direction = window.getComputedStyle(document.documentElement).direction;
        }
        console.debug(`[ereader.getHorizontalDirection] The writing mode is ${writingMode} the horizontal direction is ${direction}`);
        return direction;
    }
}


/**
 * Adds Google's WebFont loader script to the page
 * @param {Function} callback - The action to perform after WebFont loader is added
 */
function addWebFontLoaderScript(callback) {
    console.debug(`[addWebFontLoaderScript] Adding script`);
    let script = document.createElement("script");
    script.src = "https://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js";
    script.onload = () => {
        console.debug(`[addWebFontLoaderScript] Finished loading script`);
        callback();
    };
    document.head.prepend(script)
}

/**
 * Updates or adds the meta viewport element to ensure consistent rendering
 */
function setMetaViewport() {
    let viewport = document.querySelector("meta[name='viewport']")
    if (viewport !== null) {
        viewport.setAttribute("content", "width=device-width, initial-scale=1.0, height=device-height")
        console.debug(`[setMetaViewport] Updated existing viewport element`);
    } else {
        viewport = document.createElement("meta");
        viewport.setAttribute("name", "viewport")
        viewport.setAttribute("content", "width=device-width, initial-scale=1.0, height=device-height")
        document.head.prepend(viewport);
        console.debug(`[setMetaViewport] Created new viewport element`);
    }
}

/**
 * Updates the page turning velocities and rendering direction based on writing mode and direction
 */
function setDirection() {
    // Correct direction, support for RTL/vertical
    let direction = window.getComputedStyle(document.documentElement).direction; // ltr | rtl
    let writingMode = window.getComputedStyle(document.documentElement).writingMode; // horizontal-tb | vertical-rl | vertical-lr

    if (writingMode.startsWith("vertical")) {
        // ltr or rtl does not matter here, since pagination always goes downward
        ereader.page.setVelocities(0, 1);

        // axis must be flipped, however, due to different pagination direction
        document.documentElement.setAttribute("data-ereader__is_vertical", "true");
        console.debug(`[setWritingMode] Using Vertical text direction`);
    } else if (direction === "rtl") {
        // for rtl, pages are on the left instead of the right; this is the only change
        ereader.page.setVelocities(-1, 0);
        console.debug(`[setWritingMode] Using RTL text direction`);
    } else {
        console.debug(`[setWritingMode] Leaving text direction as default`);
    }
}

/**
 * Syncs the page location with the URL search parameter
 * REQUIRES the page to be loaded so that we can jump to the element
 */
function setLocation() {
    // Go to specified page/location
    let parameters = ereader.parameter.get();
    if (parameters.has("location")) {
        ereader.location.jumpTo(parseInt(parameters.get("location")));
    } else ereader.page.jumpTo(0);

    let location = ereader.location.get().toString();
    console.debug(`[setLocation] Set location to ${location}`);

    parameters.set("location", location);
    ereader.parameter.set(parameters);
}

/**
 * Syncs the CSS styles with the URL search parameters
 */
function setStyles() {
    console.debug(`[setStyles] Syncing background`);
    ereader.parameter.syncWithCSS("background", "--ereader-background-color");
    console.debug(`[setStyles] Syncing foreground`);
    ereader.parameter.syncWithCSS("foreground", "--ereader-foreground-color");

    console.debug(`[setStyles] Syncing scale`);
    ereader.parameter.syncWithCSS("scale", "--ereader-scale");

    console.debug(`[setStyles] Syncing main-axis padding`);
    ereader.parameter.syncWithCSS("main-padding", "--ereader-main-padding");
    console.debug(`[setStyles] Syncing cross-axis padding`);
    ereader.parameter.syncWithCSS("cross-padding", "--ereader-cross-padding");

    console.debug(`[setStyles] Syncing line height`);
    ereader.parameter.syncWithCSS("line-height", "--ereader-line-height");
}

/**
 * Sets the font based on the URL search parameter
 * REQUIRES WebFont loader to be active
 */
function setFonts() {
    let parameters = ereader.parameter.get();
    if (parameters.has("fonts")) {
        let fonts = decodeURIComponent(parameters.get("fonts"));
        console.debug(`[setFont] Font string: ${fonts}`);
        document.documentElement.style.setProperty("--ereader-fonts", fonts);
        for (let font of fonts.split(",")) {
            font = font.trim().replace(/['"]+/g, '');
            if (doesFontExist(font)) {
                console.debug(`[setFont] Font ${font} exists`)
            } else {
                console.debug(`[setFont] Font ${font} not found, adding from WebFont loader using Google Fonts: ${font}`);
                WebFont.load({
                    google: {families: [font]},
                    fontinactive: () => {
                        console.error(`[setFont] Could not load font ${font}`);
                    }
                });
            }
        }
    } else {
        console.debug(`[setFont] No fonts found, updating from default CSS`);
        parameters.set("fonts", encodeURIComponent(window.getComputedStyle(document.documentElement).getPropertyValue("--ereader-fonts")));
        ereader.parameter.set(parameters);
    }
}

/**
 * Checks if the specified font exists in the system
 * @param {string} fontName - The name of the font to check
 * @returns {boolean} Whether the font exists
 */
function doesFontExist(fontName) {
    let text = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let canvas = document.createElement("canvas");
    let context = canvas.getContext("2d");

    // Test monospace
    context.font = "144px monospace";
    let monospaceWidth = context.measureText(text).width;

    // Test font
    context.font = `144px ${fontName}, monospace`;
    let fontWidth = context.measureText(text).width;

    return fontWidth !== monospaceWidth;
}

/**
 * Runs when the page is loaded
 * Sets the location
 */
function onLoad() {
    console.debug(`[onLoad] Loading WebFont script and updating page location`);
    setLocation();
}

/**
 * Sets the onLoad listener disables scrolling/moving
 * For debugging: [ and ] keys are used to flip the page left and right
 */
function setListeners() {
    window.addEventListener("load", onLoad);

    // anonymous functions are required; the functions belong to classes and have their own scope
    console.debug(`[setListeners] Setting mouseup and resize listener to snap to nearest page`);
    window.addEventListener("mouseup", () => ereader.page.snapToNearest());
    window.addEventListener("resize", () => ereader.page.snapToNearest());
    console.debug(`[setListeners] Disabling the scroll wheel listener`);
    window.addEventListener("wheel", event => event.preventDefault(), {passive: false}); // prevent regular scrolling

    console.debug(`[setListeners] Setting "[" to previous page and "]" to next page for debugging purposes`);
    window.addEventListener("keydown", function (event) {
        if (event.code === "BracketRight") ereader.page.incrementBy(1);
        if (event.code === "BracketLeft") ereader.page.incrementBy(-1);
        if (["Space", "ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight"].includes(event.code)) event.preventDefault();
    }, {passive: false});
}

console.debug(`[.] LOADING PAGE at ${Date.now()}`);
window.ereader = new EReader();
setStyles();
setMetaViewport();
setDirection();
setListeners();
addWebFontLoaderScript(setFonts);

// TODO implement RTL and vertical text
//  - fix direction detection (could move setDirection and more into onLoad)
//  - differentiate between vertical-lr and vertical-rl
//  - adapt where books switch between vertical-* text and horizontal-tb images,
//      which means the control directions switch when the user encounters an image
