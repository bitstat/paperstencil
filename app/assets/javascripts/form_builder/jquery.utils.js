// returns a unique id
$.fn.nextNumber = function () {
    var counter = 1;
    return  function () {
        return counter++;
    };
}();

$.fn.unique = function () {
    return  function () {
        return '_' + Math.random().toString(36).substr(2, 16) + "_" + Math.random().toString(36).substr(2, 16);
    };
}();


//if(String.prototype.capitalize) {
String.prototype.capitalize = function () {
    return this.charAt(0).toUpperCase() + this.substring(1).toLowerCase();
};
//}

$.ajaxSetup({
    cache:false
});

if (!Array.indexOf) {
    Array.prototype.indexOf = function (obj) {
        for (var i = 0; i < this.length; i++) {
            if (this[i] == obj) {
                return i;
            }
        }
        return -1;
    };
}
