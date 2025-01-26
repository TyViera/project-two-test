function fn() {
    // karate.log('auth: ', JSON.stringify(auth))
    var temp = auth.username + ':' + auth.password;
    var Base64 = Java.type('java.util.Base64');
    var encoded = Base64.getEncoder().encodeToString(temp.toString().getBytes());
    return 'Basic ' + encoded;
}