package brscompiler.config;

enum abstract Define(String) from String to String {
    public final Ctx = '_ctx_';
    public final NewCtx = '_ctx_ = {}';
    public final Function = 'function';
    public final EndFunction = 'end function';
    public static inline function FnCall(n:Int):Define {
        return '__callFn${n}__';
    }
}
