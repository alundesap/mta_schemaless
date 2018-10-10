$.response.contentType = "text/html";
var body = "";

var hdrs = $.request.headers;
var host = "";
var hostname = "";

for (var i=0; i<hdrs.length; i++) {
	if (hdrs[i].name === "host") {
		host = hdrs[i].value;
		break;
	}	
}

console.log("Request: " + JSON.stringify($.request.cookies));

hostname = (host.split(":"))[0];

body += "<html>\n";
body += "<head>\n";
body += "</head>\n";
body += "<body style=\"font-family: Tahoma, Geneva, sans-serif\">\n";
body += "<a href=\"sensors.xsodata/$metadata\">Metadata</a><br />\n";
body += "<a href=\"sensors.xsodata/?$format=json\">Service Doc</a><br />\n";
body += "<a href=\"sensors.xsodata/temp/?$top=5&$format=json\">Top 5 Temps</a><br />\n";
body += "<a href=\"sensors.xsodata/temp(1)/?$format=json\">First Temp</a><br />\n";
body += "<a href=\"sensors.xsodata/temp/?$format=json\">All Temps</a><br />\n";
body += "<a href=\"sensors.xsodata/temp/?$format=json&$filter=tempVal gt 99\">Temps > 99</a><br />\n";
body += "<a href=\"sensors.xsodata/temp/?$format=json&$filter=tempVal gt 99&$select=tempId,tempVal\">Temps > 99 no Time Fields</a><br />\n";
body += "<!-- <a href=\"sensors.xsodata/tempNoTS/?$format=json\">Temps View no Timestamps( > 99 via structured privilege)</a><br /> -->\n";
body += "<a href=\"test_post.xsjs\" target=\"post\">Post Temp</a><br />\n";
body += "<br />\n";
body += "<a href=\"diabetes.xsodata/$metadata\">Metadata</a><br />\n";
body += "<a href=\"diabetes.xsodata/subject/?$top=5&$format=json\">Top 5 Subjects</a><br />\n";
body += "<br />\n";
body += "</body>\n";
body += "</html>\n";

$.response.setBody(body);
