executeAsyncMethod
TestHandle -> execute



function Main() as Object
	return {
		__hx_name__: "Main",
		__hx_fields__: ["efg", "abc2", "abc"],
		__hx_meta__: {"fields": {"efg": "TODO_ADD_META"}, "statics": {"main": {":keep": []}}},
		main: function () as Void
			Main().CreateInstance()
		end function,
		CreateInstance: function () as Object
			instance = {
				efg: 1,
				abc2: function () as Void

				end function,

				abc: function () as Void
					_gthis = m
					__sctx = {}
					xyz = function(__scope, __this) as Void
						x = 1
						__this.abc2()
						__this.efg = __this.efg + 1
						if __scope.ijk[0] = true then:
							p = 0
						end if
						__scope.ijk[0] = true
						Print "Done"
					end function
					__sctx.ijk = [false]

					xyz(__sctx, m)
					' __callFn0__(xyz)
				end function,

				constructor: function () as Void
					m.efg = 1
					m.efg = m.efg + 1
					m.abc()
				end function
			}

			instance.__static__ = m
			instance.constructor()
			return instance
		end function
	}
end function