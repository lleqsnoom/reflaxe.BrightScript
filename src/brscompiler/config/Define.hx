package brscompiler.config;

enum abstract Define(String) from String to String {
    public final CreateInstance = 'CreateInstance';
    public final Instance = 'Instance';
    public final Constructor = 'constructor';
    public final InstanceId = '__id__';
    public final Ctx = '_ctx_';
    public final NewCtx = '_ctx_ = {}';
    public final Call = 'call';
    public final Function = 'function';
    public final EndFunction = 'end function';
    public static inline function FnCall(n:Int):Define {
        return '__callFn${n}__';
    }
}
