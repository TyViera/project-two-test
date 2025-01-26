function fn(arrayNames) {

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

    let authUser = getKarateProperty('auth.user', 'admin');
    karate.log('karate.auth.user has been set');

    let authPassword = getKarateProperty('auth.pass', 'admin');
    karate.log('karate.auth.pass has been set');


    const config = {
        baseUrl: host + ':' + port,
        auth: {
            username: authUser,
            password: authPassword
        },
        extraData: {}
    };
    if (typeof arrayNames === 'string') {
        config.extraData[arrayNames] = [];
    } else if (Array.isArray(arrayNames)) {
        arrayNames.forEach(arrayName => {
            config.extraData[arrayName] = [];
        });
    }
    karate.log('Arrays is being initialized with an empty array');

    return config;
}