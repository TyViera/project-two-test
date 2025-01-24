function fn() {

    function getKarateProperty(propertyName, defaultValue) {
        return !!karate.properties['karate.' + propertyName] ? karate.properties['karate.' + propertyName] : defaultValue;
    }

    // don't waste time waiting for a connection or if servers don't respond within 5 seconds
    karate.configure('connectTimeout', 5000);
    karate.configure('readTimeout', 5000);

    karate.configure('report', {
        showLog: true,
        showAllSteps: true,
        showRequest: true,
        showResponse: true,
        logPrettyRequest: true,
        logPrettyResponse: true
    });
    karate.configure('retry', {count: 5, interval: 5000});

    let host = getKarateProperty('host', 'http://localhost');
    karate.log('karate.host set to ' + host);

    let port = getKarateProperty('port', '8080');
    karate.log('karate.port set to ' + port);
    return {
        baseUrl: host + ':' + port
    };
}
