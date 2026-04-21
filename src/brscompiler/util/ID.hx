package brscompiler.util;

class ID {
    @:brs_global public static function create():String {
        return untyped __brs__('stri(int(timer() * 1000)) + stri(Rnd(2147483647)) + stri(Rnd(2147483647))');
    }
}