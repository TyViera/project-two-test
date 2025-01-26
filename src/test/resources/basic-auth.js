function fn(operationName) {
    karate.log('Applying auth to: ', operationName)
    const mandatoryAuth = ['purchases', 'sales', 'reports'];
    const isMandatoryOperation = mandatoryAuth.findIndex(x => x === operationName) >= 0;
    if (isMandatoryOperation || auth.authInCrud) {
        var temp = auth.username + ':' + auth.password;
        var Base64 = Java.type('java.util.Base64');
        var encoded = Base64.getEncoder().encodeToString(temp.toString().getBytes());
        return 'Basic ' + encoded;
    }
    return null;
}