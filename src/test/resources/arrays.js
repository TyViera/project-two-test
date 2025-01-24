function fn(arrayNames) {
    const config = {
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