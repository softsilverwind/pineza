var mymap;
var group;

var metadata;

function clearMap() {
    group.clearLayers();
}

function request(url, method, params, callback)
{
    var http = new XMLHttpRequest();

    http.open(method, url, true);

    if (params)
    {
        var params = JSON.stringify(params);
        http.setRequestHeader('Content-type', 'application/json; charset=utf-8');
        http.setRequestHeader('Content-length', params.length);
    }

    http.send(params);

    if (callback)
        http.onreadystatechange = function() {
            if (http.readyState == 4)
                callback(http.responseText, http.status);
        }
}

function createIcon(color)
{
	markerHtmlStyles = `
	  background-color: ${color};
	  width: 2rem;
	  height: 2rem;
	  display: block;
	  left: -1.0rem;
	  top: -1.0rem;
	  position: relative;
	  border-radius: 2rem 2rem 0;
	  transform: rotate(45deg);
	  border: 1px solid #FFFFFF`

	icon = L.divIcon({
	  className: "my-custom-pin",
	  iconAnchor: [0, 24],
	  labelAnchor: [-6, 0],
	  popupAnchor: [0, -36],
	  html: `<span style="${markerHtmlStyles}" />`
	});

	return icon
}

function addPoints(points)
{
    var i = 0;
    for (let point of points)
        L.marker([point.lat, point.lon], {id: i++, icon: createIcon(point.color)}).bindPopup(String(point.info)).on('click', click_marker).addTo(group);
}

function addLines(lines)
{
    for (let line of lines)
        L.polyline([
                [line.start.lat, line.start.lon],
                [line.finish.lat, line.finish.lon]
            ], { color: line.color }
        ).addTo(group);
}

function calcCenter(points)
{
    center = [0.0, 0.0];
    for (let point of points)
    {
        center[0] += point.lat
        center[1] += point.lon
    }

    center[0] /= points.length;
    center[1] /= points.length;

    return center;
}

function move(points, pan)
{
    mustmove = true;

    for (let point of points)
        mustmove = mustmove && !mymap.getBounds().contains([point.lat, point.lon]);

    if (mustmove)
        mymap.fitBounds(points);
}

function get_metadata()
{
    request('/metadata', 'GET', null, function(resp, status) {
        if (status == 200)
            metadata = JSON.parse(resp);
    });
}

function init_map(pan = true)
{
    request('/data', 'GET', null, function(resp, status) {
        if (status == 200)
        {
            clearMap();

            json = JSON.parse(resp);

            addPoints(json.points);
            addLines(json.lines);
            get_metadata();

            move(json.points, pan);
        }
    });
}

function keyPress(e)
{
    request('/keypress', 'POST', { 'character' : String.fromCharCode(e.keyCode || e.which) }, handle_status_and_redraw);
}

function click(e)
{
    request('/click', 'POST', { 'latlng' : [e.latlng.lat, e.latlng.lng] }, handle_status_and_redraw);
}

function click_marker(e)
{
    var marker_id = this.options.id;

    request('/marker_click', 'POST', { 'id' : marker_id }, handle_status_and_redraw);

    var buttonSubmit = L.DomUtil.get('button-submit');
    L.DomEvent.addListener(buttonSubmit, 'click', function (e) {
        var ret = {};
        for(let metadatum of metadata) {
            var value = L.DomUtil.get('inp_' + metadatum).value;
            ret[metadatum] = value;
        }

        request('/data', 'PUT', { 'id': marker_id, 'metadata': ret }, handle_status_and_redraw);
    });
}

function handle_status_and_redraw(resp, status)
{
    if (status == 200)
    {
        json = JSON.parse(resp);
        if (json['redraw']) {
            init_map();
        }
    }
}

function init()
{
    mymap = L.map('map').setView([0, 0], 8);

    L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'Nope!',
        maxZoom: 18,
    }).addTo(mymap);

    group = new L.FeatureGroup();
    group.addTo(mymap);

    mymap.on('click', click);

    init_map(false);
}

document.addEventListener("keypress", keyPress, false);
window.onload = init;
