const PATH_ATTR = "data-ereader__path";
const START_ATTR = "data-ereader__start";
const END_ATTR = "data-ereader__end";

function main() {
    let parameters = new URLSearchParams(window.location.search);
    console.debug(`[main] Retrieved parameters ${decodeURI(parameters.toString())}`);

    if (!parameters.has("location")) {
        return redirectToChapter(document.querySelector(`div[${PATH_ATTR}]`), parameters);
    }

    let location = parseInt(parameters.get("location"));
    let elements = document.querySelectorAll(`div[${PATH_ATTR}]`);
    if (elements.length === 0
        || location < elements[0].getAttribute(START_ATTR)
        || location >= elements[elements.length - 1].getAttribute(END_ATTR)) {
        return redirectToChapter(elements[0], parameters);
    }

    for (let element of elements) {
        let start = parseInt(element.getAttribute(START_ATTR));
        let end = parseInt(element.getAttribute(END_ATTR));
        if (location >= start && location < end) {
            return redirectToChapter(element, parameters);
        }
    }
    alert("ERROR: something went wrong")
}

function redirectToChapter(element, parameters) {
    let path = element.getAttribute(PATH_ATTR);
    window.location.replace(`${path}?${parameters.toString()}`);
}

main();