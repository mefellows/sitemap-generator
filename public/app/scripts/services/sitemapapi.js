'use strict';

var sitemapServices = angular.module('sitemapServices', ['ngResource']);

sitemapServices.factory('Sitemap', ['$q', '$rootScope', function($q, $rootScope) {
    // We return this object to anything injecting our service
    var Service = {};
    // Keep all pending requests here until they get responses
    var callbacks = {};
    var callback = {};
    // Create a unique callback ID to map requests to responses
    var currentCallbackId = 0;
    // Create our websocket object with the address to the websocket
//    var url = 'ws://' + window.location.host + '/socket';
    var url = 'ws://localhost:8080/socket';
    var ws = new WebSocket(url);

    ws.onopen = function(){
        console.log("Socket has been opened!");
    };

    ws.onclose = function(){
        console.log("Socket has been closed!");
    };

    ws.onmessage = function(message) {
        listener(JSON.parse(message.data));
    };

    function sendRequest(request) {
        var defer = $q.defer();
        callback = {
            time: new Date(),
            cb:defer
        };
        console.log('Sending request', request);
        ws.send(JSON.stringify(request));
        return defer.promise;
    }

    function listener(data) {
        $rootScope.$apply(callback.cb.resolve(data.data));
    }

    // Define a "getter" for getting customer data
    Service.getSitemap = function(url) {
        // Storing in a variable for clarity on what sendRequest returns
         var promise = sendRequest({'url': url});
        return promise;
    }

    return Service;
}])

/**
 * Create a File Blob
 */
sitemapServices.factory('$blob', function() {
    return {
        csvToURL: function(content) {
            var blob;
            blob = new Blob([content], {type: 'text/csv'});
            return (window.URL || window.webkitURL).createObjectURL(blob);
        },
        sanitizeCSVName: function(name) {
            if (/^[A-Za-z0-9]+\.csv$/.test(name)) {
                return name;
            }
            if (/^[A-Za-z0-9]+/.test(name)) {
                return name + ".csv";
            }
            throw new Error("Invalid title fo CSV file : " + name);
        },
        revoke: function(url) {
            return (window.URL || window.webkitURL).revokeObjectURL(url);
        }
    };
});

/**
 * Emulate a user click on an element
 */
sitemapServices.factory('$click', function() {
    return {
        on: function(element) {
            var e = document.createEvent("MouseEvent");
            e.initMouseEvent("click", false, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
            element.dispatchEvent(e);
        }
    };
});

/**
 * Download CSV Directive.
 *
 * Apply to buttons etc., and pass in a function that returns {'title': 'Your Title', 'content': 'csv, content'}
 *
 * e.g. <button download-csv="getData()">Download CSV</button>
 */
sitemapServices.directive('downloadCsv', function($parse, $click, $blob, $log, $timeout) {
    return {
        compile: function($element, attr) {
            var fn = $parse(attr.downloadCsv);

            return function(scope, element, attr) {

                element.on('click', function(event) {
                    var a_href, content, title, url, _ref;
                    _ref = fn(scope), content = _ref.content, title = _ref.title;

                    if (!(content != null) && !(title != null)) {
                        $log.warn("Invalid content or title in download-csv : ", content, title);
                        return;
                    }

                    title = $blob.sanitizeCSVName(title);
                    url = $blob.csvToURL(content);

                    element.append("<a download=\"" + title + "\" href=\"" + url + "\"></a>");
                    a_href = element.find('a')[0];

                    $click.on(a_href);
                    $timeout(function() {$blob.revoke(url);});

                    element[0].removeChild(a_href);
                });
            };
        }
    };
});